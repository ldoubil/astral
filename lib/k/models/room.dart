import 'package:isar_community/isar.dart';
part 'room.g.dart';

@collection
class Room {
  /// 主键自增
  Id id = Isar.autoIncrement;
  String name = ""; // 房间别名
  // 是否加密
  bool encrypted = false;
  //房间名称
  String roomName = "";
  // 房间密码
  String password = "";
  // 消息密钥
  String messageKey = "";
  // 房间标签
  List<String> tags = [];
  // 排序字段
  int sortOrder = 0;

  //构造
  Room({
    this.id = Isar.autoIncrement,
    this.name = "",
    this.encrypted = false,
    this.roomName = "",
    this.messageKey = "",
    this.password = "",
    this.tags = const [],
    this.sortOrder = 0,
  });
}
