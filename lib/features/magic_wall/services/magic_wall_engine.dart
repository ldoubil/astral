import 'package:astral/core/database/dao/magic_wall_dao.dart';
import 'package:astral/core/models/magic_wall_model.dart';
import 'package:astral/features/magic_wall/models/magic_wall_group_bundle.dart';
import 'package:astral/features/magic_wall/services/magic_wall_store.dart';
import 'package:astral/src/rust/api/magic_wall.dart' as rust_api;
import 'package:flutter/foundation.dart';

/// Rust Magic Wall engine sync: convert models, start/stop, add/remove/update.
class MagicWallEngine {
  MagicWallEngine({required this.store});

  final MagicWallStore store;

  rust_api.MagicWallRule convertToRustRule(
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

  Future<({bool isRunning, int activeRules})> getStatus() async {
    final status = await rust_api.getMagicWallStatus();
    return (
      isRunning: status.isRunning,
      activeRules: status.activeRules.toInt(),
    );
  }

  Future<void> start() => rust_api.startMagicWall();

  Future<void> stop() => rust_api.stopMagicWall();

  Future<void> addRuleToEngine(
    MagicWallRuleModel rule, {
    String? fallbackAppPath,
  }) => rust_api.addMagicWallRule(
    rule: convertToRustRule(rule, fallbackAppPath: fallbackAppPath),
  );

  Future<void> updateRuleInEngine(
    MagicWallRuleModel rule, {
    String? fallbackAppPath,
  }) => rust_api.updateMagicWallRule(
    rule: convertToRustRule(rule, fallbackAppPath: fallbackAppPath),
  );

  Future<void> removeRuleFromEngine(String ruleId) =>
      rust_api.removeMagicWallRule(ruleId: ruleId);

  /// Sync enabled rules for all enabled groups, then start the engine.
  Future<void> startAndSyncRules({
    required List<MagicWallGroupBundle> bundles,
    required Future<String?> Function(MagicWallGroupModel group)
    resolveGroupAppPath,
  }) async {
    // 先同步所有启用的规则到 Rust 层
    for (final bundle in bundles.where((b) => b.group.enabled)) {
      final groupExecutable = await resolveGroupAppPath(bundle.group);

      // 更新规则的 appPath 为完整路径
      if (groupExecutable != null && groupExecutable.isNotEmpty) {
        await store.persistAppPathsForGroup(
          rules: bundle.rules,
          groupAppPath: groupExecutable,
        );
      }

      // 重新加载更新后的规则
      final updatedRules = await store.dao.getRulesByGroup(bundle.group.groupId);
      for (final rule in updatedRules.where((r) => r.enabled)) {
        try {
          await addRuleToEngine(rule, fallbackAppPath: groupExecutable);
        } catch (e) {
          debugPrint('⚠️  应用规则失败: ${rule.name}, 错误: $e');
        }
      }
    }

    // 启动魔法墙引擎，Rust 层会自动应用 RULE_STORE 中的所有规则
    await start();
  }

  /// Apply or remove enabled rules for a single enabled group.
  Future<void> syncEnabledGroupToEngine({
    required MagicWallGroupBundle bundle,
    required Future<String?> Function(MagicWallGroupModel group)
    resolveGroupAppPath,
  }) async {
    final groupAppPath = await resolveGroupAppPath(bundle.group);

    // 更新规则的 appPath 为完整路径
    if (groupAppPath != null && groupAppPath.isNotEmpty) {
      await store.persistAppPathsForGroup(
        rules: bundle.rules,
        groupAppPath: groupAppPath,
      );
    }

    // 重新加载更新后的规则
    final updatedRules = await store.dao.getRulesByGroup(bundle.group.groupId);
    for (final rule in updatedRules.where((rule) => rule.enabled)) {
      try {
        await addRuleToEngine(rule, fallbackAppPath: groupAppPath);
      } catch (e) {
        debugPrint('⚠️  添加规则失败: ${rule.name}, 错误: $e');
      }
    }
  }

  /// Remove all rules for a group from the engine (deduped by ruleId).
  Future<void> removeGroupRulesFromEngine(MagicWallGroupBundle bundle) async {
    // 使用 Set 去重，避免重复删除同一规则
    final uniqueRuleIds = <String>{};
    for (final rule in bundle.rules) {
      if (uniqueRuleIds.contains(rule.ruleId)) {
        continue;
      }
      uniqueRuleIds.add(rule.ruleId);

      try {
        await removeRuleFromEngine(rule.ruleId);
      } catch (e) {
        debugPrint('⚠️  移除规则失败: ${rule.name}, 错误: $e');
      }
    }
  }

  Future<void> removeRuleQuietly(
    String ruleId, {
    required String ruleName,
    String contextLabel = '移除规则失败',
  }) async {
    try {
      await removeRuleFromEngine(ruleId);
    } catch (e) {
      debugPrint('⚠️  $contextLabel: $ruleName, 错误: $e');
    }
  }

  bool isGroupEnabled(List<MagicWallGroupBundle> bundles, String groupId) =>
      bundles.any((b) => b.group.groupId == groupId && b.group.enabled);

  MagicWallGroupBundle? findBundle(
    List<MagicWallGroupBundle> bundles,
    String groupId,
  ) {
    for (final item in bundles) {
      if (item.group.groupId == groupId) return item;
    }
    return null;
  }

  MagicWallGroupModel? findGroup(
    List<MagicWallGroupModel> groupsList,
    String groupId,
  ) {
    for (final group in groupsList) {
      if (group.groupId == groupId) return group;
    }
    return null;
  }

  /// After add: push to engine when running + group enabled + rule enabled.
  Future<void> syncAfterAddRule({
    required bool isRunning,
    required List<MagicWallGroupBundle> bundles,
    required String groupId,
    required MagicWallRuleModel updatedRule,
    String? groupAppPath,
  }) async {
    final groupEnabled = isGroupEnabled(bundles, groupId);
    if (isRunning && groupEnabled && updatedRule.enabled) {
      try {
        await addRuleToEngine(updatedRule, fallbackAppPath: groupAppPath);
      } catch (e) {
        debugPrint('⚠️  添加规则到防火墙失败: ${updatedRule.name}, 错误: $e');
        rethrow;
      }
    }
  }

  /// After update: update or remove in engine when running.
  Future<void> syncAfterUpdateRule({
    required bool isRunning,
    required List<MagicWallGroupBundle> bundles,
    required MagicWallRuleModel updatedRule,
    String? groupAppPath,
  }) async {
    if (!isRunning) return;

    final groupEnabled = isGroupEnabled(bundles, updatedRule.groupId);
    if (updatedRule.enabled && groupEnabled) {
      await updateRuleInEngine(
        updatedRule,
        fallbackAppPath: groupAppPath ?? updatedRule.appPath,
      );
    } else {
      await removeRuleQuietly(updatedRule.ruleId, ruleName: updatedRule.name);
    }
  }

  /// Before DB delete: remove from engine if running and active.
  Future<void> syncBeforeDeleteRule({
    required bool isRunning,
    required List<MagicWallGroupBundle> bundles,
    required MagicWallRuleModel rule,
  }) async {
    final groupEnabled = isGroupEnabled(bundles, rule.groupId);
    if (isRunning && rule.enabled && groupEnabled) {
      await removeRuleQuietly(
        rule.ruleId,
        ruleName: rule.name,
        contextLabel: '从防火墙删除规则失败',
      );
      // 继续删除数据库记录
    }
  }

  /// After toggle: add or remove rule in engine when running.
  Future<void> syncAfterToggleRule({
    required bool isRunning,
    required List<MagicWallGroupBundle> bundles,
    required MagicWallRuleModel rule,
    required Future<String?> Function(MagicWallGroupModel group)
    resolveGroupAppPath,
    required Future<MagicWallRuleModel> Function(
      MagicWallRuleModel rule,
      String? groupAppPath,
    )
    ensureRuleHasCompletePath,
  }) async {
    if (!isRunning) return;

    final bundle = findBundle(bundles, rule.groupId);
    if (bundle == null) return;

    MagicWallRuleModel? updatedRule;
    for (final item in bundle.rules) {
      if (item.ruleId == rule.ruleId) {
        updatedRule = item;
        break;
      }
    }
    updatedRule ??= rule;

    if (bundle.group.enabled && updatedRule.enabled) {
      final groupAppPath = await resolveGroupAppPath(bundle.group);

      // 确保规则有完整路径
      updatedRule = await ensureRuleHasCompletePath(updatedRule, groupAppPath);

      await addRuleToEngine(updatedRule, fallbackAppPath: groupAppPath);
    } else {
      await removeRuleQuietly(updatedRule.ruleId, ruleName: updatedRule.name);
      // 即使删除失败也继续，可能规则已经不存在了
    }
  }

  /// After toggle group: sync add/remove when engine running.
  Future<void> syncAfterToggleGroup({
    required bool isRunning,
    required List<MagicWallGroupBundle> bundles,
    required String groupId,
    required Future<String?> Function(MagicWallGroupModel group)
    resolveGroupAppPath,
    required Future<void> Function({
      required String targetType,
      required String targetId,
      required String action,
      String? message,
    })
    recordEvent,
  }) async {
    if (!isRunning) return;

    final bundle = findBundle(bundles, groupId);
    if (bundle == null) return;

    if (bundle.group.enabled) {
      await recordEvent(
        targetType: 'group',
        targetId: bundle.group.groupId,
        action: 'on',
        message: '手动操作',
      );
      await syncEnabledGroupToEngine(
        bundle: bundle,
        resolveGroupAppPath: resolveGroupAppPath,
      );
    } else {
      await recordEvent(
        targetType: 'group',
        targetId: bundle.group.groupId,
        action: 'off',
        message: '手动操作',
      );
      await removeGroupRulesFromEngine(bundle);
    }
  }

  /// Before deleting a group: remove its rules from engine if active.
  Future<void> syncBeforeDeleteGroup({
    required bool isRunning,
    required List<MagicWallGroupBundle> bundles,
    required String groupId,
  }) async {
    final bundle = findBundle(bundles, groupId);
    if (isRunning && bundle != null && bundle.group.enabled) {
      for (final rule in bundle.rules) {
        await removeRuleFromEngine(rule.ruleId);
      }
    }
  }
}
