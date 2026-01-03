import 'package:astral/k/states/room_state.dart';
import 'package:astral/k/repositories/room_repository.dart';
import 'package:astral/k/models/room.dart';

/// 房间服务：协调RoomState和RoomRepository
class RoomService {
  final RoomState state;
  final RoomRepository _repository;

  RoomService(this.state, this._repository);

  // ========== 初始化 ==========

  Future<void> init() async {
    final rooms = await _repository.getAllRooms();
    state.setRooms(rooms);

    final selectedRoom = await _repository.getSelectedRoom();
    state.selectRoom(selectedRoom);
  }

  // ========== 业务方法 ==========

  Future<void> addRoom(Room room) async {
    await _repository.addRoom(room);
    await _refreshRooms();
  }

  Future<void> deleteRoom(int id) async {
    await _repository.deleteRoom(id);
    await _refreshRooms();
  }

  Future<void> updateRoom(Room room) async {
    await _repository.updateRoom(room);
    await _refreshRooms();
  }

  Future<void> reorderRooms(List<Room> reorderedRooms) async {
    await _repository.updateRoomsOrder(reorderedRooms);
    await _refreshRooms();
  }

  Future<void> setRoom(Room room) async {
    await _repository.setSelectedRoom(room);
    final selectedRoom = await _repository.getSelectedRoom();
    state.selectRoom(selectedRoom);
  }

  Future<Room?> getRoomById(int id) async {
    return await _repository.getRoomById(id);
  }

  Future<List<Room>> getAllRooms() async {
    final rooms = await _repository.getAllRooms();
    state.setRooms(rooms);
    return rooms;
  }

  // ========== 内部辅助方法 ==========

  Future<void> _refreshRooms() async {
    final rooms = await _repository.getAllRooms();
    state.setRooms(rooms);
  }
}
