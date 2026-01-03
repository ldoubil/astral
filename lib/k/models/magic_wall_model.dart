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
