import 'dart:async';
import 'dart:io';
import 'package:astral/core/constants/magic_wall_configs.dart';
import 'package:astral/src/rust/api/magic_wall.dart' as rust_api;

/// 魔法墙后台自动管理服务
/// 根据固定配置自动检测进程并应用规则
class MagicWallAutoService {
  static final MagicWallAutoService _instance =
      MagicWallAutoService._internal();
  factory MagicWallAutoService() => _instance;
  MagicWallAutoService._internal();

  Timer? _processMonitorTimer;
  final Map<String, bool> _activeGroups = {}; // 记录哪些规则组当前激活
  bool _isRunning = false;
  bool _engineStarted = false;

  /// 启动魔法墙自动服务
  Future<void> start() async {
    if (!Platform.isWindows) {
      print('魔法墙仅支持 Windows 平台');
      return;
    }

    if (_isRunning) {
      print('魔法墙服务已在运行');
      return;
    }

    _isRunning = true;
    print('🔥 启动魔法墙自动服务...');

    try {
      // 启动魔法墙引擎
      await rust_api.startMagicWall();
      _engineStarted = true;
      print('✅ 魔法墙引擎已启动');

      // 初始化所有规则组
      await _initializeRules();

      // 开始监控进程
      _startProcessMonitor();
    } catch (e) {
      print('❌ 启动魔法墙失败: $e');
      _isRunning = false;
      _engineStarted = false;
    }
  }

  /// 停止魔法墙服务
  Future<void> stop() async {
    if (!_isRunning) {
      return;
    }

    print('🛑 停止魔法墙服务...');
    _processMonitorTimer?.cancel();
    _processMonitorTimer = null;

    if (_engineStarted) {
      try {
        await rust_api.stopMagicWall();
        _engineStarted = false;
        print('✅ 魔法墙引擎已停止');
      } catch (e) {
        print('❌ 停止魔法墙引擎失败: $e');
      }
    }

    _activeGroups.clear();
    _isRunning = false;
  }

  /// 初始化所有规则
  Future<void> _initializeRules() async {
    print('📋 初始化固定配置规则...');

    for (var i = 0; i < MagicWallConfigs.groups.length; i++) {
      final groupConfig = MagicWallConfigs.groups[i];

      // 为每个规则生成唯一ID
      for (var j = 0; j < groupConfig.rules.length; j++) {
        final ruleConfig = groupConfig.rules[j];
        final ruleId = 'rule_${i}_$j';

        try {
          final rule = rust_api.MagicWallRule(
            id: ruleId,
            name: '${groupConfig.name} - ${ruleConfig.name}',
            enabled: false, // 初始禁用，等待进程检测
            action: ruleConfig.action,
            protocol: ruleConfig.protocol,
            direction: ruleConfig.direction,
            appPath: ruleConfig.appPath,
            remoteIp: ruleConfig.remoteIp,
            localIp: ruleConfig.localIp,
            remotePort: ruleConfig.remotePort,
            localPort: ruleConfig.localPort,
            description: ruleConfig.description,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          );

          await rust_api.addMagicWallRule(rule: rule);
          print('  ✓ 添加规则: ${rule.name}');
        } catch (e) {
          print('  ✗ 添加规则失败 [${ruleConfig.name}]: $e');
        }
      }
    }

    print('✅ 规则初始化完成');
  }

  /// 开始监控进程
  void _startProcessMonitor() {
    print('👀 开始监控进程...');

    // 每5秒检查一次进程
    _processMonitorTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkProcesses(),
    );

    // 立即执行一次检查
    _checkProcesses();
  }

  /// 检查进程并更新规则
  Future<void> _checkProcesses() async {
    if (!_engineStarted) {
      return;
    }

    try {
      // 获取所有正在运行的进程
      final result = await Process.run('tasklist', ['/FO', 'CSV', '/NH']);
      final output = result.stdout as String;
      final lines = output.split('\n');

      final runningProcesses = <String>{};
      for (var line in lines) {
        if (line.trim().isEmpty) continue;

        // CSV格式："进程名","PID","会话名","会话#","内存使用"
        final parts = line.split('","');
        if (parts.isNotEmpty) {
          var processName = parts[0].replaceAll('"', '').trim();
          if (processName.isNotEmpty) {
            runningProcesses.add(processName.toLowerCase());
          }
        }
      }

      // 检查每个规则组
      for (var i = 0; i < MagicWallConfigs.groups.length; i++) {
        final groupConfig = MagicWallConfigs.groups[i];

        // 跳过没有绑定进程的规则组（通用规则）
        if (groupConfig.processName.isEmpty) {
          continue;
        }

        final processName = groupConfig.processName.toLowerCase();
        final groupKey = 'group_$i';
        final isProcessRunning = runningProcesses.contains(processName);
        final wasActive = _activeGroups[groupKey] ?? false;

        // 进程状态发生变化
        if (isProcessRunning && !wasActive) {
          // 进程启动 - 启用规则
          await _enableGroupRules(i, groupConfig);
          _activeGroups[groupKey] = true;
          print(
            '🟢 检测到进程启动: ${groupConfig.processName} - 已启用规则组 [${groupConfig.name}]',
          );
        } else if (!isProcessRunning && wasActive) {
          // 进程关闭 - 禁用规则
          if (groupConfig.autoManage) {
            await _disableGroupRules(i, groupConfig);
            _activeGroups[groupKey] = false;
            print(
              '🔴 检测到进程关闭: ${groupConfig.processName} - 已禁用规则组 [${groupConfig.name}]',
            );
          }
        }
      }
    } catch (e) {
      print('⚠️ 检查进程失败: $e');
    }
  }

  /// 启用规则组的所有规则
  Future<void> _enableGroupRules(
    int groupIndex,
    MagicWallGroupConfig groupConfig,
  ) async {
    for (var j = 0; j < groupConfig.rules.length; j++) {
      final ruleConfig = groupConfig.rules[j];
      final ruleId = 'rule_${groupIndex}_$j';

      try {
        final rule = rust_api.MagicWallRule(
          id: ruleId,
          name: '${groupConfig.name} - ${ruleConfig.name}',
          enabled: true, // 启用规则
          action: ruleConfig.action,
          protocol: ruleConfig.protocol,
          direction: ruleConfig.direction,
          appPath: ruleConfig.appPath,
          remoteIp: ruleConfig.remoteIp,
          localIp: ruleConfig.localIp,
          remotePort: ruleConfig.remotePort,
          localPort: ruleConfig.localPort,
          description: ruleConfig.description,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );

        await rust_api.updateMagicWallRule(rule: rule);
      } catch (e) {
        print('  ✗ 启用规则失败 [${ruleConfig.name}]: $e');
      }
    }
  }

  /// 禁用规则组的所有规则
  Future<void> _disableGroupRules(
    int groupIndex,
    MagicWallGroupConfig groupConfig,
  ) async {
    for (var j = 0; j < groupConfig.rules.length; j++) {
      final ruleConfig = groupConfig.rules[j];
      final ruleId = 'rule_${groupIndex}_$j';

      try {
        final rule = rust_api.MagicWallRule(
          id: ruleId,
          name: '${groupConfig.name} - ${ruleConfig.name}',
          enabled: false, // 禁用规则
          action: ruleConfig.action,
          protocol: ruleConfig.protocol,
          direction: ruleConfig.direction,
          appPath: ruleConfig.appPath,
          remoteIp: ruleConfig.remoteIp,
          localIp: ruleConfig.localIp,
          remotePort: ruleConfig.remotePort,
          localPort: ruleConfig.localPort,
          description: ruleConfig.description,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );

        await rust_api.updateMagicWallRule(rule: rule);
      } catch (e) {
        print('  ✗ 禁用规则失败 [${ruleConfig.name}]: $e');
      }
    }
  }

  /// 获取服务运行状态
  bool get isRunning => _isRunning;

  /// 获取引擎状态
  bool get engineStarted => _engineStarted;
}
