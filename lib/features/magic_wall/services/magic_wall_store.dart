import 'package:astral/core/database/dao/magic_wall_dao.dart';
import 'package:astral/core/models/magic_wall_model.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/features/magic_wall/models/magic_wall_group_bundle.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// Magic Wall 领域逻辑：加载/迁移、打包、事件、路径回写。
///
/// CRUD 请直接使用 [dao]，不要在此再包一层转发。
class MagicWallStore {
  MagicWallStore([MagicWallDao? dao])
    : dao = dao ?? ServiceManager().magicWall;

  final MagicWallDao dao;

  /// Load groups/rules, migrating orphan rules into groups when needed.
  Future<({List<MagicWallGroupModel> groups, List<MagicWallRuleModel> rules})>
  loadGroupsAndRules() async {
    final rules = await dao.getAllRulesSorted();
    final groupsList = await dao.getAllGroupsSorted();

    final hasOrphan = rules.any((rule) => rule.groupId.isEmpty);
    if (groupsList.isEmpty || hasOrphan) {
      await _migrateLegacyData(rules, groupsList);
      return (
        groups: await dao.getAllGroupsSorted(),
        rules: await dao.getAllRulesSorted(),
      );
    }

    return (groups: groupsList, rules: rules);
  }

  Future<void> _migrateLegacyData(
    List<MagicWallRuleModel> rules,
    List<MagicWallGroupModel> groupsList,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final orphanRules =
        rules.where((rule) => rule.groupId.isEmpty).toList(growable: false);
    if (orphanRules.isEmpty) {
      return;
    }

    final existingNames = groupsList.map((g) => g.name).toSet();
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
      await dao.addGroup(group);
    }

    await dao.addRules(orphanRules);
  }

  List<MagicWallGroupBundle> buildBundles(
    List<MagicWallGroupModel> groupsList,
    List<MagicWallRuleModel> rules,
  ) {
    final grouped = <String, List<MagicWallRuleModel>>{};
    for (final rule in rules) {
      grouped.putIfAbsent(rule.groupId, () => []).add(rule);
    }

    return groupsList
        .map(
          (group) => MagicWallGroupBundle(
            group: group,
            rules: List<MagicWallRuleModel>.unmodifiable(
              grouped[group.groupId] ?? const <MagicWallRuleModel>[],
            ),
          ),
        )
        .toList(growable: false);
  }

  Future<void> recordEvent({
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
      await dao.addEvent(log);
    } catch (e) {
      debugPrint('记录事件失败: $e');
    }
  }

  /// Persist complete [appPath] on rules that still store a bare process name.
  Future<void> persistAppPathsForGroup({
    required List<MagicWallRuleModel> rules,
    required String groupAppPath,
  }) async {
    for (final rule in rules) {
      final needsUpdate =
          rule.appPath == null ||
          rule.appPath!.isEmpty ||
          (!rule.appPath!.contains('\\') && !rule.appPath!.contains('/'));
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
        await dao.updateRule(updated);
      }
    }
  }
}
