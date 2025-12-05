import 'package:isar_community/isar.dart';
import 'package:astral/k/models/rule_group.dart';

/// 规则组仓库类
/// 负责管理和持久化规则组相关的设置
class RuleGroupCz {
  /// Isar数据库实例
  final Isar _isar;

  /// 构造函数
  /// @param _isar Isar数据库实例
  /// 创建实例时自动初始化数据
  RuleGroupCz(this._isar) {
    init();
  }

  /// 初始化
  Future<void> init() async {}

  /// 添加规则组
  /// @param ruleGroup 规则组对象
  /// @return 返回新添加的规则组ID
  Future<int> addRuleGroup(RuleGroup ruleGroup) async {
    return await _isar.writeTxn(() async {
      return await _isar.ruleGroups.put(ruleGroup);
    });
  }

  /// 根据ID获取规则组
  /// @param id 规则组ID
  /// @return 返回对应ID的规则组，如果不存在则返回null
  Future<RuleGroup?> getRuleGroupById(int id) async {
    return await _isar.ruleGroups.get(id);
  }

  /// 获取所有规则组
  /// @return 返回所有规则组列表
  Future<List<RuleGroup>> getAllRuleGroups() async {
    return await _isar.ruleGroups.where().findAll();
  }

  /// 更新规则组
  /// @param ruleGroup 规则组对象
  /// @return 返回更新后的规则组ID
  Future<int> updateRuleGroup(RuleGroup ruleGroup) async {
    return await _isar.writeTxn(() async {
      return await _isar.ruleGroups.put(ruleGroup);
    });
  }

  /// 删除规则组
  /// @param id 规则组ID
  /// @return 返回是否删除成功
  Future<bool> deleteRuleGroup(int id) async {
    return await _isar.writeTxn(() async {
      return await _isar.ruleGroups.delete(id);
    });
  }

  /// 根据名称查询规则组
  /// @param name 规则组名称
  /// @return 返回符合名称的规则组列表
  Future<List<RuleGroup>> getRuleGroupsByName(String name) async {
    return await _isar.ruleGroups.filter().nameEqualTo(name).findAll();
  }

  /// 根据正则表达式查询规则组
  /// @param regex 正则表达式
  /// @return 返回符合正则表达式的规则组列表
  Future<List<RuleGroup>> getRuleGroupsByRegex(String regex) async {
    return await _isar.ruleGroups.filter().regexEqualTo(regex).findAll();
  }

  /// 添加规则到规则组
  /// @param rule 规则对象
  /// @param ruleGroupId 规则组ID
  /// @return 返回更新后的规则组ID，如果规则组不存在则返回-1
  Future<int> addRuleToRuleGroup(Rule rule, int ruleGroupId) async {
    return await _isar.writeTxn(() async {
      final ruleGroup = await _isar.ruleGroups.get(ruleGroupId);
      if (ruleGroup != null) {
        // 创建一个可增长的列表副本，而不是使用固定长度列表
        final updatedRules = List<Rule>.from(ruleGroup.rules);
        updatedRules.add(rule);
        ruleGroup.rules = updatedRules;
        await _isar.ruleGroups.put(ruleGroup);
        return ruleGroupId;
      }
      return -1;
    });
  }

  /// 从规则组中删除规则
  /// @param ruleIndex 规则在规则组中的索引
  /// @param ruleGroupId 规则组ID
  /// @return 返回是否删除成功
  Future<bool> removeRuleFromRuleGroup(int ruleIndex, int ruleGroupId) async {
    return await _isar.writeTxn(() async {
      final ruleGroup = await _isar.ruleGroups.get(ruleGroupId);
      if (ruleGroup != null &&
          ruleIndex >= 0 &&
          ruleIndex < ruleGroup.rules.length) {
        // 创建一个可增长的列表副本，而不是使用固定长度列表
        final updatedRules = List<Rule>.from(ruleGroup.rules);
        updatedRules.removeAt(ruleIndex);
        ruleGroup.rules = updatedRules;
        await _isar.ruleGroups.put(ruleGroup);
        return true;
      }
      return false;
    });
  }

  /// 更新规则组中的规则
  /// @param rule 更新后的规则对象
  /// @param ruleIndex 规则在规则组中的索引
  /// @param ruleGroupId 规则组ID
  /// @return 返回是否更新成功
  Future<bool> updateRuleInRuleGroup(
    Rule rule,
    int ruleIndex,
    int ruleGroupId,
  ) async {
    return await _isar.writeTxn(() async {
      final ruleGroup = await _isar.ruleGroups.get(ruleGroupId);
      if (ruleGroup != null &&
          ruleIndex >= 0 &&
          ruleIndex < ruleGroup.rules.length) {
        ruleGroup.rules[ruleIndex] = rule;
        await _isar.ruleGroups.put(ruleGroup);
        return true;
      }
      return false;
    });
  }

  /// 根据操作类型查询规则组中的规则
  /// @param opType 操作类型
  /// @param ruleGroupId 规则组ID
  /// @return 返回符合操作类型的规则列表，如果规则组不存在则返回空列表
  Future<List<Rule>> getRulesByOperationType(
    OperationType opType,
    int ruleGroupId,
  ) async {
    final ruleGroup = await _isar.ruleGroups.get(ruleGroupId);
    if (ruleGroup != null) {
      return ruleGroup.rules.where((rule) => rule.op == opType).toList();
    }
    return [];
  }
}
