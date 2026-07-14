import 'package:astral/core/database/app_data.dart';
import 'package:astral/core/states/room_state.dart';
import 'package:astral/core/models/room.dart';

/// 房间服务：协调 State 与持久化
class RoomService {
  final RoomState state;
  final AppDatabase _db;

  RoomService(this.state, this._db);

  Future<void> init() async {
    state.setRooms(await _db.rooms.getAllRooms());
    state.selectRoom(await _db.allSettings.getRoom());
  }

  Future<void> addRoom(Room room) async {
    await _db.rooms.addRoom(room);
    await _refreshRooms();
  }

  Future<void> deleteRoom(int id) async {
    await _db.rooms.deleteRoom(id);
    await _refreshRooms();
  }

  Future<void> updateRoom(Room room) async {
    await _db.rooms.updateRoom(room);
    await _refreshRooms();
  }

  Future<void> reorderRooms(List<Room> reorderedRooms) async {
    await _db.rooms.updateRoomsOrder(reorderedRooms);
    await _refreshRooms();
  }

  Future<void> setRoom(Room room) async {
    await _db.allSettings.setSelectedRoom(room);
    state.selectRoom(await _db.allSettings.getRoom());
  }

  Future<List<Room>> getAllRooms() async {
    final rooms = await _db.rooms.getAllRooms();
    state.setRooms(rooms);
    return rooms;
  }

  Future<void> _refreshRooms() async {
    state.setRooms(await _db.rooms.getAllRooms());
  }
}
