import 'package:astral/models/base.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'server_node.g.dart';

@HiveType(typeId: 15)
class ServerNode {
  @HiveField(0)
  late String id; // 服务器节点唯一标识符
  @HiveField(1)
  late String host; // 服务器节点地址
  @HiveField(2)
  late int port; // 服务器节点端口
  @HiveField(3)
  late ServerProtocolSwitch protocolSwitch; // 服务器协议类型

  /// 默认构造函数
  /// 初始化所有必需的字段以避免 LateInitializationError
  ServerNode() {
    id = const Uuid().v4();
    host = '';
    port = 0;
    protocolSwitch = ServerProtocolSwitch.tcp;
  }

  /// 命名构造函数 - 创建新的服务器节点
  ServerNode.create({
    required this.id,
    required this.host,
    required this.port,
    required this.protocolSwitch,
  });

  /// 工厂构造函数 - 从现有数据创建
  factory ServerNode.fromData({
    String? id,
    required String host,
    required int port,
    required ServerProtocolSwitch protocolSwitch,
  }) {
    return ServerNode.create(
      id: id ?? const Uuid().v4(),
      host: host,
      port: port,
      protocolSwitch: protocolSwitch,
    );
  }

  /// 重写 equals 方法，基于所有关键属性进行比较
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ServerNode) return false;

    return id == other.id &&
        host == other.host &&
        port == other.port &&
        protocolSwitch == other.protocolSwitch;
  }

  /// 重写 hashCode 方法，基于所有关键属性生成哈希值
  @override
  int get hashCode {
    return Object.hash(id, host, port, protocolSwitch);
  }
}
