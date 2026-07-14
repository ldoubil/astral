import 'package:isar_community/isar.dart';
import 'package:astral/core/models/magic_wall_model.dart';

class MagicWallModelCz {
  final Isar _isar;

  MagicWallModelCz(this._isar) {
    init();
  }

  Future<void> init() async {}

  // -------------- 规则操作 --------------

  Future<int> addMagicWallRule(MagicWallRuleModel model) async {
    return await _isar.writeTxn(() async {
      return await _isar.magicWallRuleModels.put(model);
    });
  }

  Future<List<MagicWallRuleModel>> getAllMagicWallRulesSorted() async {
    return await _isar.magicWallRuleModels
        .where()
        .sortByPriorityDesc()
        .findAll();
  }

  Future<List<MagicWallRuleModel>> getMagicWallRulesByGroup(
    String groupId,
  ) async {
    return await _isar.magicWallRuleModels
        .filter()
        .groupIdEqualTo(groupId)
        .sortByPriorityDesc()
        .findAll();
  }

  Future<int> updateMagicWallRule(MagicWallRuleModel model) async {
    model.updatedAt = DateTime.now().millisecondsSinceEpoch;
    return await _isar.writeTxn(() async {
      return await _isar.magicWallRuleModels.put(model);
    });
  }

  Future<bool> deleteMagicWallRule(int id) async {
    return await _isar.writeTxn(() async {
      return await _isar.magicWallRuleModels.delete(id);
    });
  }

  Future<bool> toggleMagicWallRule(int id) async {
    return await _isar.writeTxn(() async {
      final rule = await _isar.magicWallRuleModels.get(id);
      if (rule != null) {
        rule.enabled = !rule.enabled;
        rule.updatedAt = DateTime.now().millisecondsSinceEpoch;
        await _isar.magicWallRuleModels.put(rule);
        return true;
      }
      return false;
    });
  }

  Future<void> addMagicWallRules(List<MagicWallRuleModel> rules) async {
    await _isar.writeTxn(() async {
      await _isar.magicWallRuleModels.putAll(rules);
    });
  }

  // -------------- 规则组操作 --------------

  Future<int> addMagicWallGroup(MagicWallGroupModel model) async {
    return await _isar.writeTxn(() async {
      return await _isar.magicWallGroupModels.put(model);
    });
  }

  Future<int> updateMagicWallGroup(MagicWallGroupModel model) async {
    model.updatedAt = DateTime.now().millisecondsSinceEpoch;
    return await _isar.writeTxn(() async {
      return await _isar.magicWallGroupModels.put(model);
    });
  }

  Future<List<MagicWallGroupModel>> getAllMagicWallGroupsSorted() async {
    return await _isar.magicWallGroupModels.where().sortByName().findAll();
  }

  Future<MagicWallGroupModel?> _getMagicWallGroupByGroupId(
    String groupId,
  ) async {
    return await _isar.magicWallGroupModels
        .filter()
        .groupIdEqualTo(groupId)
        .findFirst();
  }

  Future<bool> toggleMagicWallGroup(String groupId) async {
    return await _isar.writeTxn(() async {
      final group = await _getMagicWallGroupByGroupId(groupId);
      if (group != null) {
        group.enabled = !group.enabled;
        group.updatedAt = DateTime.now().millisecondsSinceEpoch;
        await _isar.magicWallGroupModels.put(group);
        return true;
      }
      return false;
    });
  }

  Future<bool> deleteMagicWallGroup(String groupId) async {
    return await _isar.writeTxn(() async {
      final group = await _getMagicWallGroupByGroupId(groupId);
      if (group != null) {
        final rules = await getMagicWallRulesByGroup(groupId);
        if (rules.isNotEmpty) {
          final ids = rules.map((r) => r.id).toList();
          await _isar.magicWallRuleModels.deleteAll(ids);
        }
        return await _isar.magicWallGroupModels.delete(group.id);
      }
      return false;
    });
  }

  // -------------- 事件日志 --------------

  Future<int> addMagicWallEvent(MagicWallEventLogModel log) async {
    return await _isar.writeTxn(() async {
      return await _isar.magicWallEventLogModels.put(log);
    });
  }
}
