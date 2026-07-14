import 'package:astral/core/database/dao/magic_wall_dao.dart';
import 'package:astral/core/models/magic_wall_model.dart';
import 'package:astral/features/magic_wall/models/magic_wall_group_bundle.dart';
import 'package:astral/features/magic_wall/services/magic_wall_engine.dart';
import 'package:astral/features/magic_wall/services/magic_wall_store.dart';
import 'package:astral/features/magic_wall/services/process_monitor.dart';
import 'package:flutter/foundation.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Magic Wall orchestration facade used by the page.
///
/// Dialogs and SnackBars stay in the page; call these methods with the
/// models returned from dialogs (or after user confirmation).
class MagicWallController {
  MagicWallController({
    this.onSuccess,
    this.onError,
    this.onValidGroupIdsChanged,
    MagicWallStore? store,
    MagicWallEngine? engine,
  }) : store = store ?? MagicWallStore() {
    this.engine = engine ?? MagicWallEngine(store: this.store);
  }

  final void Function(String message)? onSuccess;
  final void Function(String message)? onError;

  /// Invoked after group data is applied so UI can prune collapse state.
  final void Function(Set<String> validGroupIds)? onValidGroupIdsChanged;

  final MagicWallStore store;
  late final MagicWallEngine engine;

  final isRunning = signal(false);
  final groups = signal<List<MagicWallGroupBundle>>([]);
  final activeRulesCount = signal(0);

  late final MagicWallProcessMonitor processMonitor;

  void init() {
    processMonitor = MagicWallProcessMonitor(
      callbacks: MagicWallProcessMonitorCallbacks(
        isEngineRunning: () => isRunning.value,
        setIsRunning: (value) => isRunning.value = value,
        getGroups: () => groups.value,
        convertToRustRule: engine.convertToRustRule,
        startEngineAndSyncRules: startEngineAndSyncRules,
        recordEvent: recordEvent,
        onError: (message) => onError?.call(message),
        reloadData: loadData,
      ),
    );
  }

  void dispose() {
    processMonitor.dispose();
  }

  Future<void> loadData() async {
    try {
      final loaded = await store.loadGroupsAndRules();
      applyGroupData(loaded.groups, loaded.rules);
    } catch (e) {
      onError?.call('加载配置失败: $e');
    }
  }

  void applyGroupData(
    List<MagicWallGroupModel> groupsList,
    List<MagicWallRuleModel> rules,
  ) {
    final bundles = store.buildBundles(groupsList, rules);

    groups.value = bundles;
    final validGroupIds = bundles.map((bundle) => bundle.group.groupId).toSet();
    processMonitor.pruneCaches(validGroupIds);
    onValidGroupIdsChanged?.call(validGroupIds);
    updateActiveCount();
  }

  Future<void> recordEvent({
    required String targetType,
    required String targetId,
    required String action,
    String? message,
  }) => store.recordEvent(
    targetType: targetType,
    targetId: targetId,
    action: action,
    message: message,
  );

  Future<void> checkStatus() async {
    try {
      final status = await engine.getStatus();
      isRunning.value = status.isRunning;
      activeRulesCount.value = status.activeRules;
    } catch (e) {
      debugPrint('检查状态失败: $e');
    }
  }

  void updateActiveCount() {
    final bundles = groups.value;
    final count = bundles.fold<int>(
      0,
      (acc, bundle) =>
          bundle.group.enabled
              ? acc + bundle.rules.where((rule) => rule.enabled).length
              : acc,
    );
    activeRulesCount.value = count;
  }

  Future<void> startEngineAndSyncRules() async {
    await engine.startAndSyncRules(
      bundles: groups.value,
      resolveGroupAppPath: processMonitor.resolveGroupAppPath,
    );
    isRunning.value = true;
  }

  Future<void> toggleEngine() async {
    try {
      if (isRunning.value) {
        await engine.stop();
        isRunning.value = false;
        await recordEvent(
          targetType: 'engine',
          targetId: 'engine',
          action: 'off',
          message: '手动操作',
        );
        onSuccess?.call('魔法墙已停止');
      } else {
        await startEngineAndSyncRules();
        await recordEvent(
          targetType: 'engine',
          targetId: 'engine',
          action: 'on',
          message: '手动操作',
        );
        onSuccess?.call('魔法墙已启动');
      }
    } catch (e) {
      onError?.call('操作失败: $e');
      checkStatus(); // 发生错误时刷新状态，避免 UI 状态不同步
    }
  }

  /// Persist and optionally sync a newly created rule (dialog already shown).
  Future<void> addRule(
    MagicWallRuleModel rule, {
    required String targetGroupId,
    required List<MagicWallGroupModel> groupsList,
  }) async {
    try {
      final resolvedGroupId =
          rule.groupId.isEmpty ? targetGroupId : rule.groupId;
      rule.groupId = resolvedGroupId;
      final targetGroup = engine.findGroup(groupsList, resolvedGroupId);
      final groupAppPath =
          targetGroup != null
              ? await processMonitor.resolveGroupAppPath(targetGroup)
              : null;
      rule.appPath = groupAppPath;
      await store.dao.addRule(rule);

      // 确保规则有完整路径
      final updatedRule = await processMonitor.ensureRuleHasCompletePath(
        rule,
        groupAppPath,
      );
      await loadData();
      await engine.syncAfterAddRule(
        isRunning: isRunning.value,
        bundles: groups.value,
        groupId: resolvedGroupId,
        updatedRule: updatedRule,
        groupAppPath: groupAppPath,
      );

      onSuccess?.call('规则已添加');
    } catch (e) {
      onError?.call('添加规则失败: $e');
    }
  }

  Future<void> updateRule(
    MagicWallRuleModel updated, {
    required List<MagicWallGroupModel> groupsList,
  }) async {
    try {
      final targetGroup = engine.findGroup(groupsList, updated.groupId);
      final groupAppPath =
          targetGroup != null
              ? await processMonitor.resolveGroupAppPath(targetGroup)
              : null;
      if (groupAppPath != null && groupAppPath.isNotEmpty) {
        updated.appPath = groupAppPath;
      }
      await store.dao.updateRule(updated);

      // 确保规则有完整路径
      final updatedRuleWithPath =
          await processMonitor.ensureRuleHasCompletePath(
            updated,
            groupAppPath,
          );
      await loadData();
      await engine.syncAfterUpdateRule(
        isRunning: isRunning.value,
        bundles: groups.value,
        updatedRule: updatedRuleWithPath,
        groupAppPath: groupAppPath,
      );

      onSuccess?.call('规则已更新');
    } catch (e) {
      onError?.call('更新规则失败: $e');
    }
  }

  Future<void> deleteRule(MagicWallRuleModel rule) async {
    try {
      await engine.syncBeforeDeleteRule(
        isRunning: isRunning.value,
        bundles: groups.value,
        rule: rule,
      );

      await store.dao.deleteRule(rule.id);
      await loadData();
      onSuccess?.call('规则已删除');
    } catch (e) {
      onError?.call('删除规则失败: $e');
    }
  }

  Future<void> toggleRule(MagicWallRuleModel rule) async {
    try {
      await store.dao.toggleRule(rule.id);
      await loadData();
      await engine.syncAfterToggleRule(
        isRunning: isRunning.value,
        bundles: groups.value,
        rule: rule,
        resolveGroupAppPath: processMonitor.resolveGroupAppPath,
        ensureRuleHasCompletePath: processMonitor.ensureRuleHasCompletePath,
      );
    } catch (e) {
      onError?.call('切换规则状态失败: $e');
    }
  }

  Future<void> toggleGroup(MagicWallGroupModel group) async {
    try {
      await store.dao.toggleGroup(group.groupId);
      await loadData();
      await engine.syncAfterToggleGroup(
        isRunning: isRunning.value,
        bundles: groups.value,
        groupId: group.groupId,
        resolveGroupAppPath: processMonitor.resolveGroupAppPath,
        recordEvent: recordEvent,
      );
    } catch (e) {
      onError?.call('切换规则组失败: $e');
    }
  }

  Future<void> addGroup(MagicWallGroupModel group) async {
    try {
      await store.dao.addGroup(group);
      await loadData();
      onSuccess?.call('规则组已添加');
    } catch (e) {
      onError?.call('添加规则组失败: $e');
    }
  }

  Future<void> updateGroup(MagicWallGroupModel group) async {
    try {
      await store.dao.updateGroup(group);
      await loadData();
      onSuccess?.call('规则组已更新');
    } catch (e) {
      onError?.call('更新规则组失败: $e');
    }
  }

  Future<void> deleteGroup(MagicWallGroupModel group) async {
    try {
      await engine.syncBeforeDeleteGroup(
        isRunning: isRunning.value,
        bundles: groups.value,
        groupId: group.groupId,
      );

      await store.dao.deleteGroup(group.groupId);
      await loadData();
      onSuccess?.call('规则组已删除');
    } catch (e) {
      onError?.call('删除规则组失败: $e');
    }
  }
}
