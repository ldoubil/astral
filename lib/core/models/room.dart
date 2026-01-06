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
  // 携带的服务器列表（JSON格式存储）
  List<String> servers = [];
  // 自定义参数（用于标识房间是否有自定义服务器，如为空则表示无自定义参数）
  String customParam = "";

  // ========== 网络配置携带 ==========
  /// 携带的网络配置 JSON（序列化的 NetworkConfigShare 对象）
  String networkConfigJson = "";

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
    this.servers = const [],
    this.customParam = "",
    this.networkConfigJson = "",
  });
}
