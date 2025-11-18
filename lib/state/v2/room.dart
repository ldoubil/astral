import 'package:astral/models/room_info.dart';
import 'package:hive/hive.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 房间状态管理类
/// 提供房间的增删改查功能
class V2RoomState {
  /// 房间列表信号，初始为空列表
  late Signal<List<RoomInfo>> rooms;

  V2RoomState() {
    // 初始化信号，避免 LateInitializationError
    rooms = signal<List<RoomInfo>>([]);
    loadRooms();
  }

  /// 添加房间
  void addRoom(RoomInfo room) {
    // 数据库写入
    Hive.box<RoomInfo>('V2Rooms').add(room);
    // 通过赋值新列表触发信号刷新
    rooms.value = [...rooms.value, room];
  }

  /// 删除房间 - 使用uuid进行精确删除
  void removeRoom(String roomUuid) {
    final box = Hive.box<RoomInfo>('V2Rooms');

    // 从数据库中删除：使用key进行删除
    final keys = box.keys.toList();
    for (final key in keys) {
      final room = box.get(key);
      if (room?.uuid == roomUuid) {
        box.delete(key);
        break;
      }
    }

    // 从内存列表中删除并触发信号刷新
    rooms.value = rooms.value.where((room) => room.uuid != roomUuid).toList();
  }

  /// 更新房间 - 使用uuid进行精确匹配
  void updateRoom(RoomInfo updatedRoom) {
    final box = Hive.box<RoomInfo>('V2Rooms');

    // 更新数据库中的房间
    final keys = box.keys.toList();
    for (final key in keys) {
      final room = box.get(key);
      if (room?.uuid == updatedRoom.uuid) {
        box.put(key, updatedRoom);
        break;
      }
    }

    // 更新内存中的房间并触发信号刷新
    rooms.value =
        rooms.value
            .map((room) => room.uuid == updatedRoom.uuid ? updatedRoom : room)
            .toList();
  }

  /// 清空所有房间
  void clearRooms() {
    final box = Hive.box<RoomInfo>('V2Rooms');

    // 清空数据库
    box.clear();

    // 清空内存列表并触发信号刷新
    rooms.value = [];
  }

  /// 从数据库中加载所有房间
  void loadRooms() {
    final box = Hive.box<RoomInfo>('V2Rooms');
    rooms.value = box.values.toList();
  }
}
