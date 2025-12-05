import 'package:isar_community/isar.dart';
part 'rule_group.g.dart';

// 操作类型枚举
enum OperationType { connect, bind, sendto, recvfrom, all }

// 规则类
@embedded
class Rule {
  // 操作类型
  @enumerated
  OperationType op = OperationType.all; // Default value instead of nullable

  // 匹配条件
  String? matchIp;
  int? matchPort;

  // 替换目标
  String? replaceIp;
  int? replacePort;

  // 网卡绑定相关
  String? bindNic;
  bool? enableAutoNic;
  String? nicNameFilter;
  // 构造函数
  Rule({
    this.op = OperationType.all, // Default value instead of nullable
    this.matchIp,
    this.matchPort,
    this.replaceIp,
    this.replacePort,
    this.bindNic,
    this.enableAutoNic,
    this.nicNameFilter,
  });
}

// 规则组类
@collection
class RuleGroup {
  Id id = Isar.autoIncrement;

  // 规则组名称
  String? name;

  // 匹配窗口标题的正则表达式
  String? regex;

  // 规则列表
  List<Rule> rules = [];

  // 实现实例化
  RuleGroup({this.name, this.regex = '', this.rules = const []});
}
