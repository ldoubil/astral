import 'package:isar_community/isar.dart';
import 'package:astral/k/models/room.dart'; // 添加 Room 模型的导入

class RoomCz {
  final Isar _isar;

  RoomCz(this._isar) {
    init();
  }

  Future<void> init() async {}

  // 添加房间
  Future<int> addRoom(Room room) async {
    return await _isar.writeTxn(() async {
      return await _isar.rooms.put(room);
    });
  }

  // 根据ID获取房间
  Future<Room?> getRoomById(int id) async {
    return await _isar.rooms.get(id);
  }

  // 获取所有房间（按排序字段排序）
  Future<List<Room>> getAllRooms() async {
    return await _isar.rooms.where().sortBySortOrder().findAll();
  }

  // 更新房间
  Future<int> updateRoom(Room room) async {
    return await _isar.writeTxn(() async {
      return await _isar.rooms.put(room); // Isar 的 put 方法会自动处理更新
    });
  }

  // 删除房间
  Future<bool> deleteRoom(int id) async {
    return await _isar.writeTxn(() async {
      return await _isar.rooms.delete(id);
    });
  }

  // 根据标签查询房间（按排序字段排序）
  Future<List<Room>> getRoomsByTag(String tag) async {
    return await _isar.rooms.filter().tagsElementEqualTo(tag).sortBySortOrder().findAll();
  }

  // 更新房间排序
  Future<void> updateRoomOrder(int roomId, int newOrder) async {
    await _isar.writeTxn(() async {
      final room = await _isar.rooms.get(roomId);
      if (room != null) {
        room.sortOrder = newOrder;
        await _isar.rooms.put(room);
      }
    });
  }

  // 批量更新房间排序
  Future<void> updateRoomsOrder(List<Room> rooms) async {
    await _isar.writeTxn(() async {
      for (int i = 0; i < rooms.length; i++) {
        rooms[i].sortOrder = i;
      }
      await _isar.rooms.putAll(rooms);
    });
  }
}
