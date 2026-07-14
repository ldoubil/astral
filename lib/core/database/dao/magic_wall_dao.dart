import 'package:isar_community/isar.dart';
import 'package:astral/core/models/magic_wall_model.dart';

class MagicWallDao {
  final Isar _isar;

  MagicWallDao(this._isar) {
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

/// 魔法墙 DAO 便捷别名（避免业务层重复长方法名）
extension MagicWallDaoApi on MagicWallDao {
  Future<int> addRule(MagicWallRuleModel model) => addMagicWallRule(model);

  Future<List<MagicWallRuleModel>> getAllRulesSorted() =>
      getAllMagicWallRulesSorted();

  Future<List<MagicWallRuleModel>> getRulesByGroup(String groupId) =>
      getMagicWallRulesByGroup(groupId);

  Future<int> updateRule(MagicWallRuleModel model) => updateMagicWallRule(model);

  Future<bool> deleteRule(int id) => deleteMagicWallRule(id);

  Future<bool> toggleRule(int id) => toggleMagicWallRule(id);

  Future<void> addRules(List<MagicWallRuleModel> rules) =>
      addMagicWallRules(rules);

  Future<int> addGroup(MagicWallGroupModel model) => addMagicWallGroup(model);

  Future<int> updateGroup(MagicWallGroupModel model) =>
      updateMagicWallGroup(model);

  Future<List<MagicWallGroupModel>> getAllGroupsSorted() =>
      getAllMagicWallGroupsSorted();

  Future<bool> toggleGroup(String groupId) => toggleMagicWallGroup(groupId);

  Future<bool> deleteGroup(String groupId) => deleteMagicWallGroup(groupId);

  Future<int> addEvent(MagicWallEventLogModel log) => addMagicWallEvent(log);
}
