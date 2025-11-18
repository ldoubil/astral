import 'package:astral/models/server_node.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'room_info.g.dart';

@HiveType(typeId: 37)
class RoomInfo {
  @HiveField(0)
  late String name;
  @HiveField(1)
  late String uuid;
  @HiveField(2)
  late List<ServerNode> servers;
  RoomInfo() {
    name = '';
    uuid = const Uuid().v4();
    servers = [];
  }
}
