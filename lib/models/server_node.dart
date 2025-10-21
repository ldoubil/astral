import 'package:astral/models/base.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'server_node.g.dart';

@HiveType(typeId: 15)
class ServerNode {
  @HiveField(0)
  late String id; // 唯一标识符
  @HiveField(1)
  late String name; // 服务器节点名称
  @HiveField(2)
  late String host; // 服务器节点地址
  @HiveField(3)
  late int port; // 服务器节点端口
  @HiveField(4)
  late ServerProtocolSwitch protocolSwitch; // 服务器协议类型
  // 描述
  @HiveField(5)
  late String description;
  // 版本号
  @HiveField(6)
  late String version;
  // 是否允许中继
  @HiveField(7)
  late bool allowRelay;
  // 负载百分比
  @HiveField(8)
  late double usagePercentage;
  // 是否公共节点
  @HiveField(9)
  late bool isPublic;

  /// 默认构造函数
  /// 初始化所有必需的字段以避免 LateInitializationError
  ServerNode() {
    id = const Uuid().v4();
    name = '';
    host = '';
    port = 0;
    protocolSwitch = ServerProtocolSwitch.tcp;
    description = '';
    version = '';
    allowRelay = false;
    usagePercentage = 0.0;
    isPublic = false;
  }

  /// 命名构造函数 - 创建新的服务器节点
  ServerNode.create({
    required this.name,
    required this.host,
    required this.port,
    required this.protocolSwitch,
    this.description = '',
    this.version = '',
    this.allowRelay = false,
    this.usagePercentage = 0.0,
    this.isPublic = false,
  }) : id = const Uuid().v4();

  /// 工厂构造函数 - 从现有数据创建
  factory ServerNode.fromData({
    String? id,
    required String name,
    required String host,
    required int port,
    required ServerProtocolSwitch protocolSwitch,
    String description = '',
    String version = '',
    bool allowRelay = false,
    double usagePercentage = 0.0,
    bool isPublic = false,
  }) {
    return ServerNode.create(
      name: name,
      host: host,
      port: port,
      protocolSwitch: protocolSwitch,
      description: description,
      version: version,
      allowRelay: allowRelay,
      usagePercentage: usagePercentage,
      isPublic: isPublic,
    )..id = id ?? const Uuid().v4();
  }

  /// 重写 equals 方法，基于所有关键属性进行比较
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ServerNode) return false;
    
    return id == other.id &&
           name == other.name &&
           host == other.host &&
           port == other.port &&
           protocolSwitch == other.protocolSwitch &&
           description == other.description &&
           version == other.version &&
           allowRelay == other.allowRelay &&
           usagePercentage == other.usagePercentage &&
           isPublic == other.isPublic;
  }

  /// 重写 hashCode 方法，基于所有关键属性生成哈希值
  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      host,
      port,
      protocolSwitch,
      description,
      version,
      allowRelay,
      usagePercentage,
      isPublic,
    );
  }
}
