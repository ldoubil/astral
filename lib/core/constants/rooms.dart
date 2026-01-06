/// 房间配置常量
class RoomConfig {
  final String name; // 房间别名
  final String roomName; // 房间名称（network_name）
  final String password; // 房间密码（network_secret）
  final String messageKey; // 消息密钥
  final List<String> tags; // 标签
  final List<String> servers; // 服务器列表
  final String customParam; // 自定义参数
  final String networkConfigJson; // 网络配置JSON

  const RoomConfig({
    required this.name,
    required this.roomName,
    required this.password,
    this.messageKey = "",
    this.tags = const [],
    this.servers = const [],
    this.customParam = "",
    this.networkConfigJson = "",
  });
}

/// 固定的房间列表配置
/// 数据库只保存选中的房间索引（从0开始）
class RoomsConstants {
  static const List<RoomConfig> rooms = [
    RoomConfig(
      name: "房间1",
      roomName: "墌훍疊쭵ギữバὪ",
      password: "夔Ж黽Иネѷ몪ぱ뫫Ӄ",
      tags: ["默认"],
    ),
  ];

  /// 获取房间配置
  static RoomConfig getRoomByIndex(int index) {
    if (index < 0 || index >= rooms.length) {
      return rooms[0]; // 默认返回第一个房间
    }
    return rooms[index];
  }

  /// 获取房间索引
  static int getIndexByRoomName(String roomName) {
    for (int i = 0; i < rooms.length; i++) {
      if (rooms[i].roomName == roomName) {
        return i;
      }
    }
    return 0; // 未找到则返回第一个
  }

  /// 获取房间总数
  static int get count => rooms.length;
}
