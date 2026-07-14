import 'dart:async';
import 'dart:io';

import 'package:astral/core/database/dao/magic_wall_dao.dart';
import 'package:astral/core/models/magic_wall_model.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/features/magic_wall/models/magic_wall_group_bundle.dart';
import 'package:astral/features/magic_wall/services/process_path_resolver.dart';
import 'package:astral/src/rust/api/magic_wall.dart' as rust_api;
import 'package:flutter/foundation.dart';

/// Process monitoring and auto-manage lifecycle for Magic Wall.
///
/// UI-agnostic: holds process-active maps and a timer.
/// Path resolution lives in [ProcessPathResolver].
/// Callers supply engine/group state via [MagicWallProcessMonitorCallbacks].
class MagicWallProcessMonitor {
  MagicWallProcessMonitor({required this.callbacks})
    : _pathResolver = ProcessPathResolver();

  final MagicWallProcessMonitorCallbacks callbacks;
  final ProcessPathResolver _pathResolver;

  Timer? _timer;
  bool _isCheckingProcesses = false;
  final Map<String, bool> processActive = {};

  Map<String, String> get processExecutablePaths =>
      _pathResolver.processExecutablePaths;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => checkProcesses(),
    );
    checkProcesses();
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  void pruneCaches(Set<String> validGroupIds) {
    processActive.removeWhere((key, value) => !validGroupIds.contains(key));
    _pathResolver.prune(validGroupIds);
  }

  /// 修复数据库中不完整的应用路径（仅进程名而非完整路径）
  Future<void> fixIncompleteAppPaths() => _pathResolver.fixIncompleteAppPaths(
    getGroups: callbacks.getGroups,
    reloadData: callbacks.reloadData,
  );

  /// 更新单个规则的应用路径为完整路径（如果需要）
  Future<MagicWallRuleModel> ensureRuleHasCompletePath(
    MagicWallRuleModel rule,
    String? groupAppPath,
  ) => _pathResolver.ensureRuleHasCompletePath(
    rule,
    groupAppPath,
    getGroups: callbacks.getGroups,
  );

  Future<String?> resolveGroupAppPath(MagicWallGroupModel group) =>
      _pathResolver.resolveGroupAppPath(group, callbacks.getGroups);

  Future<String?> getProcessExecutablePath(String processName) =>
      _pathResolver.getProcessExecutablePath(processName);

  Future<void> checkProcesses() async {
    if (!Platform.isWindows) {
      return;
    }

    if (_isCheckingProcesses) {
      return;
    }

    final targets = callbacks
        .getGroups()
        .where(
          (bundle) =>
              bundle.group.autoManage && bundle.group.processName.isNotEmpty,
        )
        .toList(growable: false);

    if (targets.isEmpty) {
      processActive.clear();
      _pathResolver.clear();
      return;
    }

    _isCheckingProcesses = true;
    var requireReload = false;
    try {
      for (final bundle in targets) {
        final executable = await getProcessExecutablePath(
          bundle.group.processName,
        );
        final isRunning = executable != null && executable.isNotEmpty;
        final wasRunning = processActive[bundle.group.groupId] ?? false;

        if (isRunning) {
          processExecutablePaths[bundle.group.groupId] = executable;
        } else {
          processExecutablePaths.remove(bundle.group.groupId);
        }

        if (isRunning && !wasRunning) {
          final changed = await handleProcessStarted(bundle);
          requireReload = requireReload || changed;
          processActive[bundle.group.groupId] = true;
        } else if (!isRunning && wasRunning) {
          final changed = await handleProcessStopped(bundle);
          requireReload = requireReload || changed;
          processActive[bundle.group.groupId] = false;
        }
      }
    } finally {
      _isCheckingProcesses = false;
    }

    if (requireReload) {
      await callbacks.reloadData();
    }
  }

  Future<bool> handleProcessStarted(MagicWallGroupBundle bundle) async {
    var stateChanged = false;
    final group = bundle.group;

    if (!callbacks.isEngineRunning()) {
      try {
        await callbacks.startEngineAndSyncRules();
        await callbacks.recordEvent(
          targetType: 'engine',
          targetId: 'engine',
          action: 'auto_on',
          message: '进程 ${group.processName}',
        );
      } catch (e) {
        callbacks.onError('自动启动魔法墙失败: $e');
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
      await ServiceManager().magicWall.updateGroup(updatedGroup);
      stateChanged = true;
    }

    final rules = await ServiceManager().magicWall.getRulesByGroup(
      group.groupId,
    );
    final executablePath = await resolveGroupAppPath(group);

    // 更新规则的 appPath 为完整可执行文件路径
    if (executablePath != null && executablePath.isNotEmpty) {
      final repo = ServiceManager().magicWall;
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
          await repo.updateRule(updated);
        }
      }
    }

    // 重新加载更新后的规则
    final updatedRules = await ServiceManager().magicWall.getRulesByGroup(
      group.groupId,
    );

    // 使用 Set 去重，避免重复添加
    final addedRuleIds = <String>{};
    for (final rule in updatedRules.where((rule) => rule.enabled)) {
      if (addedRuleIds.contains(rule.ruleId)) {
        continue;
      }
      addedRuleIds.add(rule.ruleId);

      try {
        await rust_api.addMagicWallRule(
          rule: callbacks.convertToRustRule(
            rule,
            fallbackAppPath: executablePath,
          ),
        );
      } catch (e) {
        debugPrint('⚠️  添加规则失败: ${rule.name}, 错误: $e');
        // 如果规则已存在，忽略错误继续
        if (!e.toString().contains('已存在')) {
          rethrow;
        }
      }
    }

    await callbacks.recordEvent(
      targetType: 'group',
      targetId: group.groupId,
      action: 'auto_on',
      message: '进程 ${group.processName}',
    );

    return stateChanged;
  }

  Future<bool> handleProcessStopped(MagicWallGroupBundle bundle) async {
    var stateChanged = false;
    final group = bundle.group;

    final rules = await ServiceManager().magicWall.getRulesByGroup(
      group.groupId,
    );

    // 使用 Set 去重
    final uniqueRuleIds = <String>{};
    for (final rule in rules) {
      if (uniqueRuleIds.contains(rule.ruleId)) {
        continue;
      }
      uniqueRuleIds.add(rule.ruleId);

      try {
        await rust_api.removeMagicWallRule(ruleId: rule.ruleId);
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
      await ServiceManager().magicWall.updateGroup(updatedGroup);
      stateChanged = true;
    }

    await callbacks.recordEvent(
      targetType: 'group',
      targetId: group.groupId,
      action: 'auto_off',
      message: '进程 ${group.processName}',
    );

    var otherGroupEnabled = false;
    for (final item in callbacks.getGroups()) {
      if (item.group.groupId == group.groupId) {
        continue;
      }
      if (item.group.enabled) {
        otherGroupEnabled = true;
        break;
      }
    }

    if (!otherGroupEnabled && callbacks.isEngineRunning()) {
      try {
        await rust_api.stopMagicWall();
        callbacks.setIsRunning(false);
        await callbacks.recordEvent(
          targetType: 'engine',
          targetId: 'engine',
          action: 'auto_off',
          message: '进程 ${group.processName}',
        );
      } catch (e) {
        callbacks.onError('自动停止魔法墙失败: $e');
      }
    }

    return stateChanged;
  }
}

class MagicWallProcessMonitorCallbacks {
  const MagicWallProcessMonitorCallbacks({
    required this.isEngineRunning,
    required this.setIsRunning,
    required this.getGroups,
    required this.convertToRustRule,
    required this.startEngineAndSyncRules,
    required this.recordEvent,
    required this.onError,
    required this.reloadData,
  });

  final bool Function() isEngineRunning;
  final void Function(bool value) setIsRunning;
  final List<MagicWallGroupBundle> Function() getGroups;
  final rust_api.MagicWallRule Function(
    MagicWallRuleModel model, {
    String? fallbackAppPath,
  })
  convertToRustRule;
  final Future<void> Function() startEngineAndSyncRules;
  final Future<void> Function({
    required String targetType,
    required String targetId,
    required String action,
    String? message,
  })
  recordEvent;
  final void Function(String message) onError;
  final Future<void> Function() reloadData;
}
