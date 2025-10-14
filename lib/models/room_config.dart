import 'package:astral/models/net_node.dart';
import 'package:astral/models/server_node.dart';
import 'package:hive/hive.dart';

part 'room_config.g.dart';

@HiveType(typeId: 16)
class RoomConfig {
  @HiveField(0)
  String room_uuid = ''; // 房间UUID
  @HiveField(1)
  String room_name = ''; // 房间名称
  // 房间保护
  @HiveField(2)
  bool room_protect = false; // 房间保护
  // 创建时间
  @HiveField(3)
  DateTime create_time = DateTime.now(); // 创建时间
  // 版本
  @HiveField(4)
  int version = 0; // 版本
  // 房间网络配置
  @HiveField(5)
  NetNode room_public = NetNode(); // 房间网络配置
  // 服务器配置
  @HiveField(6)
  List<ServerNode> server = []; // 服务器配置
  // 优先级 可用于排序
  @HiveField(7)
  int priority = 0; // 优先级
  // 房间描述
  @HiveField(8)
  String room_desc = ''; // 房间描述
}
