import 'package:astral/k/database/app_data.dart';
import 'package:astral/k/models/room.dart';

/// 房间管理的数据持久化
class RoomRepository {
  final AppDatabase _db;

  RoomRepository(this._db);

  // ========== 查询操作 ==========

  Future<List<Room>> getAllRooms() async {
    final rooms = await _db.RoomSetting.getAllRooms();
    rooms.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return rooms;
  }

  Future<Room?> getRoomById(int id) async {
    return await _db.RoomSetting.getRoomById(id);
  }

  Future<Room?> getSelectedRoom() async {
    return await _db.AllSettings.getRoom();
  }

  // ========== 写入操作 ==========

  Future<void> addRoom(Room room) async {
    await _db.RoomSetting.addRoom(room);
  }

  Future<void> updateRoom(Room room) async {
    await _db.RoomSetting.updateRoom(room);
  }

  Future<void> deleteRoom(int id) async {
    await _db.RoomSetting.deleteRoom(id);
  }

  Future<void> updateRoomsOrder(List<Room> rooms) async {
    await _db.RoomSetting.updateRoomsOrder(rooms);
  }

  Future<void> setSelectedRoom(Room room) async {
    await _db.AllSettings.updateRoom(room);
  }

  // ========== 批量操作 ==========

  Future<void> batchUpdate(List<Room> rooms) async {
    for (final room in rooms) {
      await _db.RoomSetting.updateRoom(room);
    }
  }

  Future<void> batchDelete(List<int> ids) async {
    for (final id in ids) {
      await _db.RoomSetting.deleteRoom(id);
    }
  }
}
