import 'package:isar_community/isar.dart';
import 'package:astral/k/models/magic_wall_model.dart';

class MagicWallModelCz {
  final Isar _isar;

  MagicWallModelCz(this._isar) {
    init();
  }

  Future<void> init() async {}

  // -------------- 规则操作 --------------

  // 添加规则
  Future<int> addMagicWallRule(MagicWallRuleModel model) async {
    return await _isar.writeTxn(() async {
      return await _isar.magicWallRuleModels.put(model);
    });
  }

  // 根据ID获取规则
  Future<MagicWallRuleModel?> getMagicWallRuleById(int id) async {
    return await _isar.magicWallRuleModels.get(id);
  }

  // 根据规则ID获取规则
  Future<MagicWallRuleModel?> getMagicWallRuleByRuleId(String ruleId) async {
    return await _isar.magicWallRuleModels
        .filter()
        .ruleIdEqualTo(ruleId)
        .findFirst();
  }

  // 获取所有规则
  Future<List<MagicWallRuleModel>> getAllMagicWallRules() async {
    return await _isar.magicWallRuleModels.where().findAll();
  }

  // 获取所有启用的规则
  Future<List<MagicWallRuleModel>> getEnabledMagicWallRules() async {
    return await _isar.magicWallRuleModels
        .filter()
        .enabledEqualTo(true)
        .findAll();
  }

  // 获取按优先级排序的规则
  Future<List<MagicWallRuleModel>> getAllMagicWallRulesSorted() async {
    return await _isar.magicWallRuleModels
        .where()
        .sortByPriorityDesc()
        .findAll();
  }

  // 根据组获取规则
  Future<List<MagicWallRuleModel>> getMagicWallRulesByGroup(
    String groupId,
  ) async {
    return await _isar.magicWallRuleModels
        .filter()
        .groupIdEqualTo(groupId)
        .sortByPriorityDesc()
        .findAll();
  }

  // 更新规则
  Future<int> updateMagicWallRule(MagicWallRuleModel model) async {
    model.updatedAt = DateTime.now().millisecondsSinceEpoch;
    return await _isar.writeTxn(() async {
      return await _isar.magicWallRuleModels.put(model);
    });
  }

  // 删除规则
  Future<bool> deleteMagicWallRule(int id) async {
    return await _isar.writeTxn(() async {
      return await _isar.magicWallRuleModels.delete(id);
    });
  }

  // 根据规则ID删除规则
  Future<bool> deleteMagicWallRuleByRuleId(String ruleId) async {
    return await _isar.writeTxn(() async {
      final rule = await getMagicWallRuleByRuleId(ruleId);
      if (rule != null) {
        return await _isar.magicWallRuleModels.delete(rule.id);
      }
      return false;
    });
  }

  // 根据名称查询规则
  Future<List<MagicWallRuleModel>> getMagicWallRulesByName(String name) async {
    return await _isar.magicWallRuleModels.filter().nameEqualTo(name).findAll();
  }

  // 切换规则启用状态
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

  // 批量添加规则
  Future<void> addMagicWallRules(List<MagicWallRuleModel> rules) async {
    await _isar.writeTxn(() async {
      await _isar.magicWallRuleModels.putAll(rules);
    });
  }

  // 清空所有规则
  Future<void> clearAllMagicWallRules() async {
    await _isar.writeTxn(() async {
      await _isar.magicWallRuleModels.clear();
    });
  }

  // 根据动作类型获取规则
  Future<List<MagicWallRuleModel>> getMagicWallRulesByAction(
    String action,
  ) async {
    return await _isar.magicWallRuleModels
        .filter()
        .actionEqualTo(action)
        .findAll();
  }

  // 根据协议类型获取规则
  Future<List<MagicWallRuleModel>> getMagicWallRulesByProtocol(
    String protocol,
  ) async {
    return await _isar.magicWallRuleModels
        .filter()
        .protocolEqualTo(protocol)
        .findAll();
  }

  // 根据方向获取规则
  Future<List<MagicWallRuleModel>> getMagicWallRulesByDirection(
    String direction,
  ) async {
    return await _isar.magicWallRuleModels
        .filter()
        .directionEqualTo(direction)
        .findAll();
  }

  // 统计规则数量
  Future<int> getMagicWallRulesCount() async {
    return await _isar.magicWallRuleModels.count();
  }

  // 统计启用的规则数量
  Future<int> getEnabledMagicWallRulesCount() async {
    return await _isar.magicWallRuleModels
        .filter()
        .enabledEqualTo(true)
        .count();
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

  Future<MagicWallGroupModel?> getMagicWallGroupByGroupId(
    String groupId,
  ) async {
    return await _isar.magicWallGroupModels
        .filter()
        .groupIdEqualTo(groupId)
        .findFirst();
  }

  Future<bool> toggleMagicWallGroup(String groupId) async {
    return await _isar.writeTxn(() async {
      final group = await getMagicWallGroupByGroupId(groupId);
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
      final group = await getMagicWallGroupByGroupId(groupId);
      if (group != null) {
        // 删除组下的所有规则
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

  Future<List<MagicWallEventLogModel>> getRecentMagicWallEvents(
    int limit,
  ) async {
    return await _isar.magicWallEventLogModels
        .where()
        .sortByTimestampDesc()
        .limit(limit)
        .findAll();
  }
}
