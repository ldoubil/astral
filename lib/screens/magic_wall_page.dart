import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:astral/core/models/magic_wall_model.dart';
import 'package:astral/core/database/app_data.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'dart:io';
import 'package:astral/src/rust/api/magic_wall.dart' as rust_api;

class MagicWallGroupBundle {
  MagicWallGroupBundle({required this.group, required this.rules});

  final MagicWallGroupModel group;
  final List<MagicWallRuleModel> rules;
}

/// 魔法墙主页面
class MagicWallPage extends StatefulWidget {
  const MagicWallPage({super.key});

  @override
  State<MagicWallPage> createState() => _MagicWallPageState();
}

class _MagicWallPageState extends State<MagicWallPage> {
  final _isRunning = signal(false);
  final _groups = signal<List<MagicWallGroupBundle>>([]);
  final _activeRulesCount = signal(0);
  Timer? _processMonitorTimer;
  final Map<String, bool> _processActive = {};
  final Map<String, String> _processExecutablePaths = {};
  bool _isCheckingProcesses = false;
  final Set<String> _collapsedGroups = <String>{};

  @override
  void initState() {
    super.initState();
    _loadData().then((_) => _fixIncompleteAppPaths());
    _checkStatus();
    if (Platform.isWindows) {
      _startProcessMonitor();
    }
  }

  @override
  void dispose() {
    _processMonitorTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final repo = AppDatabase().MagicWallSetting;
      final rules = await repo.getAllMagicWallRulesSorted();
      final groups = await repo.getAllMagicWallGroupsSorted();

      final hasOrphan = rules.any((rule) => rule.groupId.isEmpty);
      if (groups.isEmpty || hasOrphan) {
        await _migrateLegacyData(rules, groups);
        final refreshedRules = await repo.getAllMagicWallRulesSorted();
        final refreshedGroups = await repo.getAllMagicWallGroupsSorted();
        _applyGroupData(refreshedGroups, refreshedRules);
        return;
      }

      _applyGroupData(groups, rules);
    } catch (e) {
      _showError('加载配置失败: $e');
    }
  }

  Future<void> _migrateLegacyData(
    List<MagicWallRuleModel> rules,
    List<MagicWallGroupModel> groups,
  ) async {
    final repo = AppDatabase().MagicWallSetting;
    final now = DateTime.now().millisecondsSinceEpoch;

    final orphanRules = rules
        .where((rule) => rule.groupId.isEmpty)
        .toList(growable: false);
    if (orphanRules.isEmpty) {
      return;
    }

    final existingNames = groups.map((g) => g.name).toSet();
    final createdGroups = <MagicWallGroupModel>[];
    final provisionalGroups = <String, MagicWallGroupModel>{};

    String deriveName(MagicWallRuleModel rule) {
      if (rule.name.isNotEmpty) {
        return rule.name;
      }
      final appPath = rule.appPath;
      if (appPath != null && appPath.isNotEmpty) {
        final sanitized = appPath.split(RegExp(r'[\\/]')).last;
        if (sanitized.isNotEmpty) {
          return sanitized;
        }
      }
      return '导入规则组';
    }

    String ensureUniqueName(String baseName, Set<String> usedNames) {
      var name = baseName;
      var index = 1;
      while (usedNames.contains(name)) {
        index += 1;
        name = '$baseName($index)';
      }
      usedNames.add(name);
      return name;
    }

    final usedNames = {...existingNames};

    MagicWallGroupModel obtainGroup(String baseName) {
      final existing = provisionalGroups[baseName];
      if (existing != null) {
        return existing;
      }
      final uniqueName = ensureUniqueName(baseName, usedNames);
      final group =
          MagicWallGroupModel()
            ..groupId = const Uuid().v4()
            ..name = uniqueName
            ..processName = ''
            ..enabled = false
            ..autoManage = false
            ..createdAt = now
            ..updatedAt = now;
      provisionalGroups[baseName] = group;
      createdGroups.add(group);
      return group;
    }

    for (final rule in orphanRules) {
      final baseName = deriveName(rule);
      final group = obtainGroup(baseName);
      rule.groupId = group.groupId;
      rule.createdAt ??= now;
      rule.updatedAt = now;
    }

    for (final group in createdGroups) {
      await repo.addMagicWallGroup(group);
    }

    await repo.addMagicWallRules(orphanRules);
  }

  void _applyGroupData(
    List<MagicWallGroupModel> groups,
    List<MagicWallRuleModel> rules,
  ) {
    final grouped = <String, List<MagicWallRuleModel>>{};
    for (final rule in rules) {
      grouped.putIfAbsent(rule.groupId, () => []).add(rule);
    }

    final bundles = groups
        .map(
          (group) => MagicWallGroupBundle(
            group: group,
            rules: List<MagicWallRuleModel>.unmodifiable(
              grouped[group.groupId] ?? const <MagicWallRuleModel>[],
            ),
          ),
        )
        .toList(growable: false);

    _groups.value = bundles;
    final validGroupIds = bundles.map((bundle) => bundle.group.groupId).toSet();
    _processActive.removeWhere((key, value) => !validGroupIds.contains(key));
    _processExecutablePaths.removeWhere(
      (key, value) => !validGroupIds.contains(key),
    );
    final toRemove =
        _collapsedGroups.where((id) => !validGroupIds.contains(id)).toList();
    if (toRemove.isNotEmpty && mounted) {
      setState(() {
        _collapsedGroups.removeAll(toRemove);
      });
    }
    _updateActiveCount();
  }

  void _toggleGroupCollapse(String groupId) {
    if (!mounted) {
      return;
    }
    setState(() {
      if (_collapsedGroups.contains(groupId)) {
        _collapsedGroups.remove(groupId);
      } else {
        _collapsedGroups.add(groupId);
      }
    });
  }

  /// 修复数据库中不完整的应用路径（仅进程名而非完整路径）
  Future<void> _fixIncompleteAppPaths() async {
    if (!Platform.isWindows) {
      return;
    }

    try {
      final repo = AppDatabase().MagicWallSetting;
      bool anyUpdated = false;

      for (final bundle in _groups.value) {
        if (bundle.group.processName.trim().isEmpty) {
          continue;
        }

        // 检查组内规则是否需要修复
        bool needsFix = false;
        for (final rule in bundle.rules) {
          final path = rule.appPath;
          if (path == null ||
              path.isEmpty ||
              (!path.contains('\\') && !path.contains('/'))) {
            needsFix = true;
            break;
          }
        }

        if (!needsFix) {
          continue;
        }

        // 尝试解析完整路径
        final executablePath = await _getProcessExecutablePath(
          bundle.group.processName,
        );
        if (executablePath == null || executablePath.isEmpty) {
          continue;
        }

        // 更新所有不完整的规则
        for (final rule in bundle.rules) {
          final path = rule.appPath;
          if (path == null ||
              path.isEmpty ||
              (!path.contains('\\') && !path.contains('/'))) {
            final updated =
                MagicWallRuleModel()
                  ..id = rule.id
                  ..ruleId = rule.ruleId
                  ..groupId = rule.groupId
                  ..name = rule.name
                  ..enabled = rule.enabled
                  ..action = rule.action
                  ..protocol = rule.protocol
                  ..direction = rule.direction
                  ..appPath = executablePath
                  ..remoteIp = rule.remoteIp
                  ..localIp = rule.localIp
                  ..remotePort = rule.remotePort
                  ..localPort = rule.localPort
                  ..description = rule.description
                  ..createdAt = rule.createdAt
                  ..updatedAt = DateTime.now().millisecondsSinceEpoch;
            await repo.updateMagicWallRule(updated);
            anyUpdated = true;
          }
        }
      }

      if (anyUpdated) {
        await _loadData();
      }
    } catch (e) {
      debugPrint('修复应用路径失败: $e');
    }
  }

  /// 更新单个规则的应用路径为完整路径（如果需要）
  Future<MagicWallRuleModel> _ensureRuleHasCompletePath(
    MagicWallRuleModel rule,
    String? groupAppPath,
  ) async {
    // 如果已经有完整路径，不需要更新
    final currentPath = rule.appPath;
    if (currentPath != null &&
        currentPath.isNotEmpty &&
        (currentPath.contains('\\') || currentPath.contains('/'))) {
      return rule;
    }

    // 如果没有提供 groupAppPath，尝试从组中解析
    String? resolvedPath = groupAppPath;
    if (resolvedPath == null || resolvedPath.isEmpty) {
      for (final bundle in _groups.value) {
        if (bundle.group.groupId == rule.groupId) {
          resolvedPath = await _resolveGroupAppPath(bundle.group);
          break;
        }
      }
    }

    // 如果仍然没有路径，返回原规则
    if (resolvedPath == null || resolvedPath.isEmpty) {
      return rule;
    }

    // 更新规则的路径
    final updated =
        MagicWallRuleModel()
          ..id = rule.id
          ..ruleId = rule.ruleId
          ..groupId = rule.groupId
          ..name = rule.name
          ..enabled = rule.enabled
          ..action = rule.action
          ..protocol = rule.protocol
          ..direction = rule.direction
          ..appPath = resolvedPath
          ..remoteIp = rule.remoteIp
          ..localIp = rule.localIp
          ..remotePort = rule.remotePort
          ..localPort = rule.localPort
          ..description = rule.description
          ..createdAt = rule.createdAt
          ..updatedAt = DateTime.now().millisecondsSinceEpoch;

    await AppDatabase().MagicWallSetting.updateMagicWallRule(updated);
    return updated;
  }

  Future<void> _recordEvent({
    required String targetType,
    required String targetId,
    required String action,
    String? message,
  }) async {
    try {
      final log =
          MagicWallEventLogModel()
            ..targetType = targetType
            ..targetId = targetId
            ..action = action
            ..message = message
            ..timestamp = DateTime.now().millisecondsSinceEpoch;
      await AppDatabase().MagicWallSetting.addMagicWallEvent(log);
    } catch (e) {
      debugPrint('记录事件失败: $e');
    }
  }

  Future<String?> _resolveGroupAppPath(MagicWallGroupModel group) async {
    if (group.processName.trim().isEmpty) {
      return null;
    }

    final cached = _processExecutablePaths[group.groupId];
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    for (final bundle in _groups.value) {
      if (bundle.group.groupId == group.groupId) {
        for (final rule in bundle.rules) {
          final candidate = rule.appPath;
          if (candidate != null && candidate.isNotEmpty) {
            _processExecutablePaths[group.groupId] = candidate;
            return candidate;
          }
        }
        break;
      }
    }

    final path = await _getProcessExecutablePath(group.processName);
    if (path != null && path.isNotEmpty) {
      _processExecutablePaths[group.groupId] = path;
      return path;
    }
    return null;
  }

  Future<String?> _getProcessExecutablePath(String processName) async {
    final trimmed = processName.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    if (trimmed.contains('\\') || trimmed.contains('/')) {
      final file = File(trimmed);
      if (await file.exists()) {
        return file.path;
      }
    }

    final sanitized = trimmed.replaceAll(
      RegExp(r'\.exe$', caseSensitive: false),
      '',
    );
    if (sanitized.isEmpty) {
      return null;
    }

    final escaped = sanitized.replaceAll("'", "''");
    final command =
        "Get-Process -Name '$escaped' -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Path";

    try {
      final result = await Process.run('powershell', [
        '-NoProfile',
        '-Command',
        command,
      ]);
      if (result.exitCode != 0) {
        return null;
      }
      final output = (result.stdout as String?)?.trim() ?? '';
      if (output.isEmpty) {
        return null;
      }
      return output;
    } catch (e) {
      debugPrint('解析进程路径失败: $e');
      return null;
    }
  }

  void _startProcessMonitor() {
    _processMonitorTimer?.cancel();
    _processMonitorTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkProcesses(),
    );
    _checkProcesses();
  }

  Future<void> _checkProcesses() async {
    if (!Platform.isWindows) {
      return;
    }

    if (_isCheckingProcesses) {
      return;
    }

    final targets = _groups.value
        .where(
          (bundle) =>
              bundle.group.autoManage && bundle.group.processName.isNotEmpty,
        )
        .toList(growable: false);

    if (targets.isEmpty) {
      _processActive.clear();
      _processExecutablePaths.clear();
      return;
    }

    _isCheckingProcesses = true;
    var requireReload = false;
    try {
      for (final bundle in targets) {
        final executable = await _getProcessExecutablePath(
          bundle.group.processName,
        );
        final isRunning = executable != null && executable.isNotEmpty;
        final wasRunning = _processActive[bundle.group.groupId] ?? false;

        if (isRunning) {
          _processExecutablePaths[bundle.group.groupId] = executable;
        } else {
          _processExecutablePaths.remove(bundle.group.groupId);
        }

        if (isRunning && !wasRunning) {
          final changed = await _handleProcessStarted(bundle);
          requireReload = requireReload || changed;
          _processActive[bundle.group.groupId] = true;
        } else if (!isRunning && wasRunning) {
          final changed = await _handleProcessStopped(bundle);
          requireReload = requireReload || changed;
          _processActive[bundle.group.groupId] = false;
        }
      }
    } finally {
      _isCheckingProcesses = false;
    }

    if (requireReload) {
      await _loadData();
    }
  }

  Future<bool> _handleProcessStarted(MagicWallGroupBundle bundle) async {
    var stateChanged = false;
    final group = bundle.group;

    if (!_isRunning.value) {
      try {
        await rust_api.startMagicWall();
        _isRunning.value = true;
        await _recordEvent(
          targetType: 'engine',
          targetId: 'engine',
          action: 'auto_on',
          message: '进程 ${group.processName}',
        );
      } catch (e) {
        _showError('自动启动魔法墙失败: $e');
      }
    }

    if (!group.enabled) {
      final updatedGroup =
          MagicWallGroupModel()
            ..id = group.id
            ..groupId = group.groupId
            ..name = group.name
            ..processName = group.processName
            ..autoManage = group.autoManage
            ..enabled = true
            ..createdAt = group.createdAt
            ..updatedAt = DateTime.now().millisecondsSinceEpoch;
      await AppDatabase().MagicWallSetting.updateMagicWallGroup(updatedGroup);
      stateChanged = true;
    }

    final rules = await AppDatabase().MagicWallSetting.getMagicWallRulesByGroup(
      group.groupId,
    );
    final executablePath = await _resolveGroupAppPath(group);

    // 更新规则的 appPath 为完整可执行文件路径
    if (executablePath != null && executablePath.isNotEmpty) {
      final repo = AppDatabase().MagicWallSetting;
      for (final rule in rules) {
        final needsUpdate =
            rule.appPath == null ||
            rule.appPath!.isEmpty ||
            !rule.appPath!.contains('\\') && !rule.appPath!.contains('/');
        if (needsUpdate) {
          final updated =
              MagicWallRuleModel()
                ..id = rule.id
                ..ruleId = rule.ruleId
                ..groupId = rule.groupId
                ..name = rule.name
                ..enabled = rule.enabled
                ..action = rule.action
                ..protocol = rule.protocol
                ..direction = rule.direction
                ..appPath = executablePath
                ..remoteIp = rule.remoteIp
                ..localIp = rule.localIp
                ..remotePort = rule.remotePort
                ..localPort = rule.localPort
                ..description = rule.description
                ..createdAt = rule.createdAt
                ..updatedAt = DateTime.now().millisecondsSinceEpoch;
          await repo.updateMagicWallRule(updated);
        }
      }
    }

    // 重新加载更新后的规则
    final updatedRules = await AppDatabase().MagicWallSetting
        .getMagicWallRulesByGroup(group.groupId);

    debugPrint('📊 组 ${group.name} 共有 ${updatedRules.length} 条规则');

    // 使用 Set 去重，避免重复添加
    final addedRuleIds = <String>{};
    for (final rule in updatedRules.where((rule) => rule.enabled)) {
      debugPrint('🔍 检查规则: ${rule.name} (${rule.ruleId})');
      if (addedRuleIds.contains(rule.ruleId)) {
        debugPrint('⚠️  跳过重复添加规则: ${rule.name} (${rule.ruleId})');
        continue;
      }
      addedRuleIds.add(rule.ruleId);

      try {
        await rust_api.addMagicWallRule(
          rule: _convertToRustRule(rule, fallbackAppPath: executablePath),
        );
        debugPrint('✅ 进程启动，规则已添加: ${rule.name}');
      } catch (e) {
        debugPrint('⚠️  添加规则失败: ${rule.name}, 错误: $e');
        // 如果规则已存在，忽略错误继续
        if (!e.toString().contains('已存在')) {
          rethrow;
        }
      }
    }

    await _recordEvent(
      targetType: 'group',
      targetId: group.groupId,
      action: 'auto_on',
      message: '进程 ${group.processName}',
    );

    return stateChanged;
  }

  Future<bool> _handleProcessStopped(MagicWallGroupBundle bundle) async {
    var stateChanged = false;
    final group = bundle.group;

    final rules = await AppDatabase().MagicWallSetting.getMagicWallRulesByGroup(
      group.groupId,
    );

    // 使用 Set 去重
    final uniqueRuleIds = <String>{};
    for (final rule in rules) {
      if (uniqueRuleIds.contains(rule.ruleId)) {
        debugPrint('⚠️  跳过重复的规则: ${rule.name} (${rule.ruleId})');
        continue;
      }
      uniqueRuleIds.add(rule.ruleId);

      try {
        await rust_api.removeMagicWallRule(ruleId: rule.ruleId);
        debugPrint('✅ 进程停止，规则已移除: ${rule.name}');
      } catch (e) {
        debugPrint('⚠️  移除规则失败: ${rule.name}, 错误: $e');
        // 继续移除其他规则
      }
    }

    if (group.enabled) {
      final updatedGroup =
          MagicWallGroupModel()
            ..id = group.id
            ..groupId = group.groupId
            ..name = group.name
            ..processName = group.processName
            ..autoManage = group.autoManage
            ..enabled = false
            ..createdAt = group.createdAt
            ..updatedAt = DateTime.now().millisecondsSinceEpoch;
      await AppDatabase().MagicWallSetting.updateMagicWallGroup(updatedGroup);
      stateChanged = true;
    }

    await _recordEvent(
      targetType: 'group',
      targetId: group.groupId,
      action: 'auto_off',
      message: '进程 ${group.processName}',
    );

    var otherGroupEnabled = false;
    for (final item in _groups.value) {
      if (item.group.groupId == group.groupId) {
        continue;
      }
      if (item.group.enabled) {
        otherGroupEnabled = true;
        break;
      }
    }

    if (!otherGroupEnabled && _isRunning.value) {
      try {
        await rust_api.stopMagicWall();
        _isRunning.value = false;
        await _recordEvent(
          targetType: 'engine',
          targetId: 'engine',
          action: 'auto_off',
          message: '进程 ${group.processName}',
        );
      } catch (e) {
        _showError('自动停止魔法墙失败: $e');
      }
    }

    return stateChanged;
  }

  Future<void> _checkStatus() async {
    try {
      final status = await rust_api.getMagicWallStatus();
      _isRunning.value = status.isRunning;
      _activeRulesCount.value = status.activeRules.toInt();
    } catch (e) {
      debugPrint('检查状态失败: $e');
    }
  }

  void _updateActiveCount() {
    final bundles = _groups.value;
    final count = bundles.fold<int>(
      0,
      (acc, bundle) =>
          bundle.group.enabled
              ? acc + bundle.rules.where((rule) => rule.enabled).length
              : acc,
    );
    _activeRulesCount.value = count;
  }

  rust_api.MagicWallRule _convertToRustRule(
    MagicWallRuleModel model, {
    String? fallbackAppPath,
  }) {
    String? resolvedAppPath;
    // 优先使用 fallbackAppPath（解析出的完整路径）
    if (fallbackAppPath != null && fallbackAppPath.isNotEmpty) {
      resolvedAppPath = fallbackAppPath;
    } else if (model.appPath != null && model.appPath!.isNotEmpty) {
      resolvedAppPath = model.appPath;
    }

    return rust_api.MagicWallRule(
      id: model.ruleId,
      name: model.name,
      enabled: model.enabled,
      action: model.action,
      protocol: model.protocol,
      direction: model.direction,
      appPath: resolvedAppPath,
      remoteIp: model.remoteIp,
      localIp: model.localIp,
      remotePort: model.remotePort,
      localPort: model.localPort,
      description: model.description,
      createdAt: model.createdAt,
    );
  }

  Future<void> _toggleEngine() async {
    try {
      if (_isRunning.value) {
        await rust_api.stopMagicWall();
        _isRunning.value = false;
        await _recordEvent(
          targetType: 'engine',
          targetId: 'engine',
          action: 'off',
          message: '手动操作',
        );
        _showSuccess('魔法墙已停止');
      } else {
        await rust_api.startMagicWall();
        // 应用所有启用的规则
        final repo = AppDatabase().MagicWallSetting;
        for (final bundle in _groups.value.where((b) => b.group.enabled)) {
          final groupExecutable = await _resolveGroupAppPath(bundle.group);

          // 更新规则的 appPath 为完整路径
          if (groupExecutable != null && groupExecutable.isNotEmpty) {
            for (final rule in bundle.rules) {
              final needsUpdate =
                  rule.appPath == null ||
                  rule.appPath!.isEmpty ||
                  !rule.appPath!.contains('\\') && !rule.appPath!.contains('/');
              if (needsUpdate) {
                final updated =
                    MagicWallRuleModel()
                      ..id = rule.id
                      ..ruleId = rule.ruleId
                      ..groupId = rule.groupId
                      ..name = rule.name
                      ..enabled = rule.enabled
                      ..action = rule.action
                      ..protocol = rule.protocol
                      ..direction = rule.direction
                      ..appPath = groupExecutable
                      ..remoteIp = rule.remoteIp
                      ..localIp = rule.localIp
                      ..remotePort = rule.remotePort
                      ..localPort = rule.localPort
                      ..description = rule.description
                      ..createdAt = rule.createdAt
                      ..updatedAt = DateTime.now().millisecondsSinceEpoch;
                await repo.updateMagicWallRule(updated);
              }
            }
          }

          // 重新加载更新后的规则
          final updatedRules = await repo.getMagicWallRulesByGroup(
            bundle.group.groupId,
          );
          for (final rule in updatedRules.where((r) => r.enabled)) {
            await rust_api.addMagicWallRule(
              rule: _convertToRustRule(rule, fallbackAppPath: groupExecutable),
            );
          }
        }
        _isRunning.value = true;
        await _recordEvent(
          targetType: 'engine',
          targetId: 'engine',
          action: 'on',
          message: '手动操作',
        );
        _showSuccess('魔法墙已启动');
      }
    } catch (e) {
      _showError('操作失败: $e');
    }
  }

  Future<void> _addRule({String? groupId, bool allowGroupChange = true}) async {
    final groups = _groups.value.map((bundle) => bundle.group).toList();
    if (groups.isEmpty) {
      _showError('请先创建规则组');
      return;
    }

    final targetGroupId = groupId ?? groups.first.groupId;

    final rule = await showDialog<MagicWallRuleModel>(
      context: context,
      builder:
          (context) => MagicWallRuleDialog(
            groups: groups,
            selectedGroupId: targetGroupId,
            allowGroupChange: allowGroupChange,
          ),
    );

    if (rule != null) {
      try {
        final resolvedGroupId =
            rule.groupId.isEmpty ? targetGroupId : rule.groupId;
        rule.groupId = resolvedGroupId;
        MagicWallGroupModel? targetGroup;
        for (final group in groups) {
          if (group.groupId == resolvedGroupId) {
            targetGroup = group;
            break;
          }
        }
        final groupAppPath =
            targetGroup != null
                ? await _resolveGroupAppPath(targetGroup)
                : null;
        rule.appPath = groupAppPath;
        await AppDatabase().MagicWallSetting.addMagicWallRule(rule);

        // 确保规则有完整路径
        final updatedRule = await _ensureRuleHasCompletePath(
          rule,
          groupAppPath,
        );
        await _loadData();

        final isGroupEnabled = _groups.value.any(
          (bundle) =>
              bundle.group.groupId == resolvedGroupId && bundle.group.enabled,
        );

        if (_isRunning.value && isGroupEnabled && updatedRule.enabled) {
          try {
            await rust_api.addMagicWallRule(
              rule: _convertToRustRule(
                updatedRule,
                fallbackAppPath: groupAppPath,
              ),
            );
            debugPrint('✅ 新规则已添加到防火墙: ${updatedRule.name}');
          } catch (e) {
            debugPrint('⚠️  添加规则到防火墙失败: ${updatedRule.name}, 错误: $e');
            rethrow;
          }
        }

        _showSuccess('规则已添加');
      } catch (e) {
        _showError('添加规则失败: $e');
      }
    }
  }

  Future<void> _editRule(MagicWallRuleModel rule) async {
    final groups = _groups.value.map((bundle) => bundle.group).toList();
    if (groups.isEmpty) {
      _showError('请先创建规则组');
      return;
    }

    final updated = await showDialog<MagicWallRuleModel>(
      context: context,
      builder:
          (context) => MagicWallRuleDialog(
            rule: rule,
            groups: groups,
            selectedGroupId: rule.groupId,
          ),
    );

    if (updated != null) {
      try {
        MagicWallGroupModel? targetGroup;
        for (final group in groups) {
          if (group.groupId == updated.groupId) {
            targetGroup = group;
            break;
          }
        }
        final groupAppPath =
            targetGroup != null
                ? await _resolveGroupAppPath(targetGroup)
                : null;
        if (groupAppPath != null && groupAppPath.isNotEmpty) {
          updated.appPath = groupAppPath;
        }
        await AppDatabase().MagicWallSetting.updateMagicWallRule(updated);

        // 确保规则有完整路径
        final updatedRuleWithPath = await _ensureRuleHasCompletePath(
          updated,
          groupAppPath,
        );
        await _loadData();

        // 如果引擎正在运行,更新 Rust 中的规则
        if (_isRunning.value) {
          final isGroupEnabled = _groups.value.any(
            (bundle) =>
                bundle.group.groupId == updatedRuleWithPath.groupId &&
                bundle.group.enabled,
          );

          if (updatedRuleWithPath.enabled && isGroupEnabled) {
            await rust_api.updateMagicWallRule(
              rule: _convertToRustRule(
                updatedRuleWithPath,
                fallbackAppPath: groupAppPath ?? updatedRuleWithPath.appPath,
              ),
            );
          } else {
            try {
              await rust_api.removeMagicWallRule(
                ruleId: updatedRuleWithPath.ruleId,
              );
              debugPrint(
                '✅ 规则已移除: ${updatedRuleWithPath.name} (${updatedRuleWithPath.ruleId})',
              );
            } catch (e) {
              debugPrint('⚠️  移除规则失败: ${updatedRuleWithPath.name}, 错误: $e');
            }
          }
        }

        _showSuccess('规则已更新');
      } catch (e) {
        _showError('更新规则失败: $e');
      }
    }
  }

  Future<void> _deleteRule(MagicWallRuleModel rule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认删除'),
            content: Text('确定要删除规则 "${rule.name}" 吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('删除'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        // 如果引擎正在运行且规则启用,从 Rust 中删除
        final isGroupEnabled = _groups.value.any(
          (bundle) =>
              bundle.group.groupId == rule.groupId && bundle.group.enabled,
        );
        if (_isRunning.value && rule.enabled && isGroupEnabled) {
          try {
            await rust_api.removeMagicWallRule(ruleId: rule.ruleId);
            debugPrint('✅ 规则已从防火墙删除: ${rule.name}');
          } catch (e) {
            debugPrint('⚠️  从防火墙删除规则失败: ${rule.name}, 错误: $e');
            // 继续删除数据库记录
          }
        }

        await AppDatabase().MagicWallSetting.deleteMagicWallRule(rule.id);
        await _loadData();
        _showSuccess('规则已删除');
      } catch (e) {
        _showError('删除规则失败: $e');
      }
    }
  }

  Future<void> _toggleRule(MagicWallRuleModel rule) async {
    try {
      await AppDatabase().MagicWallSetting.toggleMagicWallRule(rule.id);
      await _loadData();

      // 如果引擎正在运行,应用/移除规则
      if (_isRunning.value) {
        MagicWallGroupBundle? bundle;
        for (final item in _groups.value) {
          if (item.group.groupId == rule.groupId) {
            bundle = item;
            break;
          }
        }

        if (bundle == null) {
          return;
        }

        MagicWallRuleModel? updatedRule;
        for (final item in bundle.rules) {
          if (item.ruleId == rule.ruleId) {
            updatedRule = item;
            break;
          }
        }

        updatedRule ??= rule;

        if (bundle.group.enabled && updatedRule.enabled) {
          final groupAppPath = await _resolveGroupAppPath(bundle.group);

          // 确保规则有完整路径
          updatedRule = await _ensureRuleHasCompletePath(
            updatedRule,
            groupAppPath,
          );

          await rust_api.addMagicWallRule(
            rule: _convertToRustRule(
              updatedRule,
              fallbackAppPath: groupAppPath,
            ),
          );
        } else {
          try {
            await rust_api.removeMagicWallRule(ruleId: updatedRule.ruleId);
            debugPrint('✅ 规则已移除: ${updatedRule.name} (${updatedRule.ruleId})');
          } catch (e) {
            debugPrint('⚠️  移除规则失败: ${updatedRule.name}, 错误: $e');
            // 即使删除失败也继续，可能规则已经不存在了
          }
        }
      }
    } catch (e) {
      _showError('切换规则状态失败: $e');
    }
  }

  Future<void> _toggleGroup(MagicWallGroupModel group) async {
    try {
      await AppDatabase().MagicWallSetting.toggleMagicWallGroup(group.groupId);
      await _loadData();

      if (_isRunning.value) {
        MagicWallGroupBundle? bundle;
        for (final item in _groups.value) {
          if (item.group.groupId == group.groupId) {
            bundle = item;
            break;
          }
        }

        if (bundle == null) {
          return;
        }

        if (bundle.group.enabled) {
          await _recordEvent(
            targetType: 'group',
            targetId: bundle.group.groupId,
            action: 'on',
            message: '手动操作',
          );
          final groupAppPath = await _resolveGroupAppPath(bundle.group);

          // 更新规则的 appPath 为完整路径
          if (groupAppPath != null && groupAppPath.isNotEmpty) {
            final repo = AppDatabase().MagicWallSetting;
            for (final rule in bundle.rules) {
              final needsUpdate =
                  rule.appPath == null ||
                  rule.appPath!.isEmpty ||
                  !rule.appPath!.contains('\\') && !rule.appPath!.contains('/');
              if (needsUpdate) {
                final updated =
                    MagicWallRuleModel()
                      ..id = rule.id
                      ..ruleId = rule.ruleId
                      ..groupId = rule.groupId
                      ..name = rule.name
                      ..enabled = rule.enabled
                      ..action = rule.action
                      ..protocol = rule.protocol
                      ..direction = rule.direction
                      ..appPath = groupAppPath
                      ..remoteIp = rule.remoteIp
                      ..localIp = rule.localIp
                      ..remotePort = rule.remotePort
                      ..localPort = rule.localPort
                      ..description = rule.description
                      ..createdAt = rule.createdAt
                      ..updatedAt = DateTime.now().millisecondsSinceEpoch;
                await repo.updateMagicWallRule(updated);
              }
            }
          }

          // 重新加载更新后的规则
          final updatedRules = await AppDatabase().MagicWallSetting
              .getMagicWallRulesByGroup(bundle.group.groupId);
          for (final rule in updatedRules.where((rule) => rule.enabled)) {
            try {
              await rust_api.addMagicWallRule(
                rule: _convertToRustRule(rule, fallbackAppPath: groupAppPath),
              );
              debugPrint('✅ 组启用，规则已添加: ${rule.name}');
            } catch (e) {
              debugPrint('⚠️  添加规则失败: ${rule.name}, 错误: $e');
            }
          }
        } else {
          await _recordEvent(
            targetType: 'group',
            targetId: bundle.group.groupId,
            action: 'off',
            message: '手动操作',
          );

          debugPrint('📊 组 ${bundle.group.name} 共有 ${bundle.rules.length} 条规则');

          // 使用 Set 去重，避免重复删除同一规则
          final uniqueRuleIds = <String>{};
          for (final rule in bundle.rules) {
            debugPrint('🔍 检查删除规则: ${rule.name} (${rule.ruleId})');
            if (uniqueRuleIds.contains(rule.ruleId)) {
              debugPrint('⚠️  跳过重复的规则: ${rule.name} (${rule.ruleId})');
              continue;
            }
            uniqueRuleIds.add(rule.ruleId);

            try {
              await rust_api.removeMagicWallRule(ruleId: rule.ruleId);
              debugPrint('✅ 组禁用，规则已移除: ${rule.name}');
            } catch (e) {
              debugPrint('⚠️  移除规则失败: ${rule.name}, 错误: $e');
            }
          }
        }
      }
    } catch (e) {
      _showError('切换规则组失败: $e');
    }
  }

  Future<void> _addGroup() async {
    final group = await showDialog<MagicWallGroupModel>(
      context: context,
      builder: (context) => const MagicWallGroupDialog(),
    );

    if (group != null) {
      try {
        await AppDatabase().MagicWallSetting.addMagicWallGroup(group);
        await _loadData();
        _showSuccess('规则组已添加');
      } catch (e) {
        _showError('添加规则组失败: $e');
      }
    }
  }

  Future<void> _editGroup(MagicWallGroupModel group) async {
    final updated = await showDialog<MagicWallGroupModel>(
      context: context,
      builder: (context) => MagicWallGroupDialog(group: group),
    );

    if (updated != null) {
      try {
        await AppDatabase().MagicWallSetting.updateMagicWallGroup(updated);
        await _loadData();
        _showSuccess('规则组已更新');
      } catch (e) {
        _showError('更新规则组失败: $e');
      }
    }
  }

  Future<void> _deleteGroup(MagicWallGroupModel group) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认删除'),
            content: Text('确定要删除规则组 "${group.name}" 吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('删除'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        MagicWallGroupBundle? bundle;
        for (final item in _groups.value) {
          if (item.group.groupId == group.groupId) {
            bundle = item;
            break;
          }
        }

        if (_isRunning.value && bundle != null && bundle.group.enabled) {
          for (final rule in bundle.rules) {
            await rust_api.removeMagicWallRule(ruleId: rule.ruleId);
          }
        }

        await AppDatabase().MagicWallSetting.deleteMagicWallGroup(
          group.groupId,
        );
        await _loadData();
        _showSuccess('规则组已删除');
      } catch (e) {
        _showError('删除规则组失败: $e');
      }
    }
  }

  Future<void> _showCreationMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.layers),
                  title: const Text('添加规则组'),
                  onTap: () {
                    Navigator.pop(context);
                    _addGroup();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.playlist_add),
                  title: const Text('添加规则'),
                  enabled: _groups.value.isNotEmpty,
                  onTap:
                      _groups.value.isEmpty
                          ? null
                          : () {
                            Navigator.pop(context);
                            _addRule();
                          },
                ),
              ],
            ),
          ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('魔法墙'),
        actions: [
          // 状态指示器
          Watch(
            (context) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isRunning.value ? Icons.shield : Icons.shield_outlined,
                      color: _isRunning.value ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_activeRulesCount.value} 条规则',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 控制面板
          _buildControlPanel(),

          const Divider(height: 1),

          // 规则列表
          Expanded(
            child: Watch((context) {
              if (_groups.value.isEmpty) {
                return _buildEmptyState();
              }
              return _buildGroupList();
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreationMenu,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Watch(
      (context) => Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '魔法墙引擎',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isRunning.value ? '运行中' : '已停止',
                          style: TextStyle(
                            color:
                                _isRunning.value ? Colors.green : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isRunning.value,
                    onChanged: (value) => _toggleEngine(),
                  ),
                ],
              ),
              if (!Platform.isWindows) ...[
                const SizedBox(height: 8),
                const Text(
                  '⚠️ 魔法墙仅支持 Windows 平台',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '还没有规则组',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮创建规则组',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _groups.value.length,
      itemBuilder: (context, index) {
        final bundle = _groups.value[index];
        return _buildGroupCard(bundle);
      },
    );
  }

  Widget _buildGroupCard(MagicWallGroupBundle bundle) {
    final group = bundle.group;
    final rules = bundle.rules;
    final enabledCount = rules.where((rule) => rule.enabled).length;
    final isCollapsed = _collapsedGroups.contains(group.groupId);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            onTap: () => _toggleGroupCollapse(group.groupId),
            leading: CircleAvatar(
              backgroundColor: group.enabled ? Colors.blue : Colors.grey,
              child: Icon(
                group.enabled ? Icons.layers : Icons.layers_outlined,
                color: Colors.white,
              ),
            ),
            title: Text(
              group.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: group.enabled ? null : Colors.grey,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '进程: ${group.processName.isEmpty ? '未绑定' : group.processName}',
                ),
                Text(
                  '规则: ${rules.length} 项 · 已启用 $enabledCount 项',
                  style: const TextStyle(fontSize: 12),
                ),
                if (group.autoManage)
                  const Text(
                    '自动监听进程',
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isCollapsed ? Icons.expand_more : Icons.expand_less,
                  ),
                  onPressed: () => _toggleGroupCollapse(group.groupId),
                ),
                Switch(
                  value: group.enabled,
                  onChanged: (value) => _toggleGroup(group),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'addRule') {
                      _addRule(groupId: group.groupId, allowGroupChange: false);
                    } else if (value == 'edit') {
                      _editGroup(group);
                    } else if (value == 'delete') {
                      _deleteGroup(group);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'addRule',
                          child: Row(
                            children: [
                              Icon(Icons.add, size: 20),
                              SizedBox(width: 8),
                              Text('添加规则'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('编辑规则组'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                '删除规则组',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),
          if (!isCollapsed && rules.isNotEmpty) const Divider(height: 1),
          if (!isCollapsed)
            for (var i = 0; i < rules.length; i++) ...[
              _buildRuleTile(group, rules[i]),
              if (i != rules.length - 1)
                const Divider(indent: 72, endIndent: 16, height: 1),
            ],
          if (!isCollapsed)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(72, 8, 16, 12),
                child: TextButton.icon(
                  onPressed:
                      () => _addRule(
                        groupId: group.groupId,
                        allowGroupChange: false,
                      ),
                  icon: const Icon(Icons.add),
                  label: const Text('添加规则'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRuleTile(MagicWallGroupModel group, MagicWallRuleModel rule) {
    final activeColor =
        rule.enabled && group.enabled ? Colors.green : Colors.grey;

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 72, right: 16),
      leading: CircleAvatar(
        backgroundColor:
            rule.action == 'allow' ? activeColor : Colors.red.shade400,
        child: Icon(
          rule.action == 'allow' ? Icons.check : Icons.block,
          color: Colors.white,
        ),
      ),
      title: Text(
        rule.name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: rule.enabled ? null : Colors.grey,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(_buildRuleDescription(rule)),
          if (rule.description != null && rule.description!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              rule.description!,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(value: rule.enabled, onChanged: (value) => _toggleRule(rule)),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _editRule(rule);
              } else if (value == 'delete') {
                _deleteRule(rule);
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('编辑'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('删除', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      isThreeLine: true,
    );
  }

  String _buildRuleDescription(MagicWallRuleModel rule) {
    final parts = <String>[];

    parts.add(rule.action == 'allow' ? '允许' : '阻止');
    parts.add(rule.protocol.toUpperCase());

    if (rule.direction != 'both') {
      parts.add(rule.direction == 'inbound' ? '入站' : '出站');
    }

    if (rule.remoteIp != null) {
      parts.add('从 ${rule.remoteIp}');
    }

    if (rule.remotePort != null) {
      parts.add('端口 ${rule.remotePort}');
    }

    return parts.join(' · ');
  }
}

/// 规则组编辑对话框
class MagicWallGroupDialog extends StatefulWidget {
  final MagicWallGroupModel? group;

  const MagicWallGroupDialog({super.key, this.group});

  @override
  State<MagicWallGroupDialog> createState() => _MagicWallGroupDialogState();
}

class _MagicWallGroupDialogState extends State<MagicWallGroupDialog> {
  late TextEditingController _nameController;
  late TextEditingController _processController;
  late bool _autoManage;
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    final group = widget.group;
    _nameController = TextEditingController(text: group?.name ?? '');
    _processController = TextEditingController(text: group?.processName ?? '');
    _autoManage = group?.autoManage ?? true;
    _enabled = group?.enabled ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _processController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final process = _processController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入规则组名称')));
      return;
    }

    if (_autoManage && process.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('启用自动监听时需填写进程名称')));
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final group =
        MagicWallGroupModel()
          ..id = widget.group?.id ?? 0
          ..groupId = widget.group?.groupId ?? const Uuid().v4()
          ..name = name
          ..processName = process
          ..autoManage = _autoManage
          ..enabled = _enabled
          ..createdAt = widget.group?.createdAt ?? now
          ..updatedAt = now;

    Navigator.pop(context, group);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.group == null ? '添加规则组' : '编辑规则组'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '规则组名称 *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.layers),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _processController,
                decoration: const InputDecoration(
                  labelText: '绑定进程名称',
                  hintText: '如: game.exe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.memory),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('自动监听进程'),
                subtitle: const Text('进程启动启用规则组, 进程结束关闭规则组'),
                value: _autoManage,
                onChanged: (value) => setState(() => _autoManage = value),
              ),
              SwitchListTile(
                title: const Text('启用规则组'),
                value: _enabled,
                onChanged: (value) => setState(() => _enabled = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('保存')),
      ],
    );
  }
}

/// 规则编辑对话框
class MagicWallRuleDialog extends StatefulWidget {
  final MagicWallRuleModel? rule;
  final List<MagicWallGroupModel> groups;
  final String? selectedGroupId;
  final bool allowGroupChange;

  const MagicWallRuleDialog({
    super.key,
    this.rule,
    required this.groups,
    this.selectedGroupId,
    this.allowGroupChange = true,
  });

  @override
  State<MagicWallRuleDialog> createState() => _MagicWallRuleDialogState();
}

class _MagicWallRuleDialogState extends State<MagicWallRuleDialog> {
  late TextEditingController _nameController;
  late TextEditingController _remoteIpController;
  late TextEditingController _localIpController;
  late TextEditingController _remotePortController;
  late TextEditingController _localPortController;

  late String _action;
  late String _protocol;
  late String _direction;
  late bool _enabled;
  late String _groupId;

  @override
  void initState() {
    super.initState();

    final rule = widget.rule;
    _nameController = TextEditingController(text: rule?.name ?? '');
    _remoteIpController = TextEditingController(text: rule?.remoteIp ?? '');
    _localIpController = TextEditingController(text: rule?.localIp ?? '');
    _remotePortController = TextEditingController(text: rule?.remotePort ?? '');
    _localPortController = TextEditingController(text: rule?.localPort ?? '');

    _action = rule?.action ?? 'block';
    _protocol = rule?.protocol ?? 'both';
    _direction = rule?.direction ?? 'both';
    _enabled = rule?.enabled ?? true;
    _groupId =
        rule?.groupId ??
        widget.selectedGroupId ??
        (widget.groups.isNotEmpty ? widget.groups.first.groupId : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _remoteIpController.dispose();
    _localIpController.dispose();
    _remotePortController.dispose();
    _localPortController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入规则名称')));
      return;
    }

    if (_groupId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择规则组')));
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final existingAppPath = widget.rule?.appPath;

    final rule =
        MagicWallRuleModel()
          ..id = widget.rule?.id ?? 0
          ..ruleId = widget.rule?.ruleId ?? const Uuid().v4()
          ..groupId = _groupId
          ..name = _nameController.text.trim()
          ..enabled = _enabled
          ..action = _action
          ..protocol = _protocol
          ..direction = _direction
          ..appPath =
              existingAppPath != null && existingAppPath.isNotEmpty
                  ? existingAppPath
                  : null
          ..remoteIp =
              _remoteIpController.text.trim().isEmpty
                  ? null
                  : _remoteIpController.text.trim()
          ..localIp =
              _localIpController.text.trim().isEmpty
                  ? null
                  : _localIpController.text.trim()
          ..remotePort =
              _remotePortController.text.trim().isEmpty
                  ? null
                  : _remotePortController.text.trim()
          ..localPort =
              _localPortController.text.trim().isEmpty
                  ? null
                  : _localPortController.text.trim()
          ..createdAt = widget.rule?.createdAt ?? now
          ..updatedAt = now
          ..priority = widget.rule?.priority ?? 0;

    Navigator.pop(context, rule);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.rule == null ? '添加规则' : '编辑规则'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.groups.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  initialValue:
                      _groupId.isEmpty ? widget.groups.first.groupId : _groupId,
                  decoration: const InputDecoration(
                    labelText: '所属规则组',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.layers),
                  ),
                  items:
                      widget.groups
                          .map(
                            (group) => DropdownMenuItem(
                              value: group.groupId,
                              child: Text(group.name),
                            ),
                          )
                          .toList(),
                  onChanged:
                      widget.allowGroupChange
                          ? (value) => setState(() => _groupId = value ?? '')
                          : null,
                ),
                const SizedBox(height: 16),
              ],
              // 规则名称
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '规则名称 *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
              ),
              const SizedBox(height: 16),

              // 基本配置：动作、协议、方向
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _action,
                      decoration: const InputDecoration(
                        labelText: '动作',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'allow', child: Text('允许')),
                        DropdownMenuItem(value: 'block', child: Text('阻止')),
                      ],
                      onChanged: (value) => setState(() => _action = value!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _protocol,
                      decoration: const InputDecoration(
                        labelText: '协议',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'tcp', child: Text('TCP')),
                        DropdownMenuItem(value: 'udp', child: Text('UDP')),
                        DropdownMenuItem(value: 'both', child: Text('TCP+UDP')),
                        DropdownMenuItem(value: 'any', child: Text('任意')),
                      ],
                      onChanged: (value) => setState(() => _protocol = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 方向
              DropdownButtonFormField<String>(
                initialValue: _direction,
                decoration: const InputDecoration(
                  labelText: '方向',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.swap_horiz),
                ),
                items: const [
                  DropdownMenuItem(value: 'inbound', child: Text('⬇️ 入站')),
                  DropdownMenuItem(value: 'outbound', child: Text('⬆️ 出站')),
                  DropdownMenuItem(value: 'both', child: Text('↕️ 双向')),
                ],
                onChanged: (value) => setState(() => _direction = value!),
              ),
              const SizedBox(height: 16),

              // 远程配置
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _remoteIpController,
                      decoration: const InputDecoration(
                        labelText: '远程 IP（可选）',
                        hintText: '192.168.1.1 或 192.168.0.0/16',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _remotePortController,
                      decoration: const InputDecoration(
                        labelText: '远程端口（可选）',
                        hintText: '80 或 8000-9000',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 本地配置
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _localIpController,
                      decoration: const InputDecoration(
                        labelText: '本地 IP（可选）',
                        hintText: '192.168.1.1 或 192.168.0.0/16',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _localPortController,
                      decoration: const InputDecoration(
                        labelText: '本地端口（可选）',
                        hintText: '80 或 8000-9000',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('启用规则'),
                value: _enabled,
                onChanged: (value) => setState(() => _enabled = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('保存')),
      ],
    );
  }
}
