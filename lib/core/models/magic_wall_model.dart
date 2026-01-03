import 'package:isar_community/isar.dart';

part 'magic_wall_model.g.dart';

/// 魔法墙规则配置模型
@collection
class MagicWallRuleModel {
  /// 主键自增
  Id id = Isar.autoIncrement;

  /// 规则唯一标识符
  @Index(unique: true)
  String ruleId = '';

  /// 所属规则组标识
  @Index()
  String groupId = '';

  /// 规则名称
  @Index()
  String name = '';

  /// 是否启用
  bool enabled = true;

  /// 动作 (allow/block)
  String action = 'block';

  /// 协议 (tcp/udp/both/any)
  String protocol = 'both';

  /// 方向 (inbound/outbound/both)
  String direction = 'both';

  /// 应用程序路径（可选）
  String? appPath;

  /// 远程 IP/CIDR（可选，如 "192.168.1.0/24"）
  String? remoteIp;

  /// 本地 IP/CIDR（可选）
  String? localIp;

  /// 远程端口或端口范围（如 "80" 或 "8000-9000"）
  String? remotePort;

  /// 本地端口或端口范围
  String? localPort;

  /// 规则描述
  String? description;

  /// 创建时间（时间戳）
  int? createdAt;

  /// 最后修改时间（时间戳）
  int? updatedAt;

  /// 优先级（数字越大优先级越高）
  int priority = 0;
}

/// 魔法墙规则组
@collection
class MagicWallGroupModel {
  /// 主键自增
  Id id = Isar.autoIncrement;

  /// 规则组唯一标识
  @Index(unique: true)
  String groupId = '';

  /// 配置名称
  @Index()
  String name = '';

  /// 绑定进程名称
  @Index()
  String processName = '';

  /// 组启用状态
  bool enabled = false;

  /// 是否自动随进程启动/关闭
  bool autoManage = true;

  /// 创建时间
  int? createdAt;

  /// 更新时间
  int? updatedAt;
}

/// 魔法墙事件日志
@collection
class MagicWallEventLogModel {
  /// 主键自增
  Id id = Isar.autoIncrement;

  /// 事件类型：engine/group
  @Index()
  String targetType = 'engine';

  /// 关联标识（如 groupId）
  @Index()
  String targetId = '';

  /// 动作（如 on/off/auto_on/auto_off）
  String action = '';

  /// 附加信息
  String? message;

  /// 时间戳
  int timestamp = 0;
}
