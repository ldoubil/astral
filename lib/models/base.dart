import 'package:hive/hive.dart';

part 'base.g.dart';


@HiveType(typeId: 12)
class ConnectionInfo {
  @HiveField(0)
  late String bindAddr;
  @HiveField(1)
  late String dstAddr;
  @HiveField(2)
  late String proto;

  ConnectionInfo() {
    bindAddr = '';
    dstAddr = '';
    proto = '';
  }
}

@HiveType(typeId: 13)
class ConnectionManager {
  @HiveField(0)
  late String name; // 分组名称
  @HiveField(1)
  late List<ConnectionInfo> connections;
  @HiveField(2)
  late bool enabled;

  ConnectionManager() {
    name = '';
    connections = [];
    enabled = false;
  }
}

/// 协议开关枚举
@HiveType(typeId: 14)
enum ServerProtocolSwitch {
  @HiveField(0)
  tcp,   // tcp 开启
  @HiveField(1)
  udp,   // udp 开启
  @HiveField(2)
  ws,    // ws 开启
  @HiveField(3)
  wss,   // wss 开启
  @HiveField(4)
  quic,  // quic 开启
  @HiveField(5)
  wg,    // wg 开启
  @HiveField(6)
  txt,   // txt 开启
  @HiveField(7)
  srv,   // srv 开启
  @HiveField(8)
  http,  // http 开启
  @HiveField(9)
  https, // https 开启
}
