import 'package:astral/core/states/room_state.dart';
import 'package:astral/core/repositories/room_repository.dart';
import 'package:astral/core/models/room.dart';
import 'package:astral/shared/utils/data/duplicate_name_detection.dart';

/// 房间服务：协调RoomState和RoomRepository
class RoomService {
  final RoomState state;
  final RoomRepository _repository;

  RoomService(this.state, this._repository);

  // ========== 初始化 ==========

  Future<void> init() async {
    final rooms = await _repository.getAllRooms();
    
    // 确保所有房间都有正确的modifiedAt字段（处理从旧版本升级的情况）
    final updatedRooms = await Future.wait(rooms.map((room) async {
      if (room.modifiedAt.millisecondsSinceEpoch <= 0) {
        final updatedRoom = Room(
          id: room.id,
          name: room.name,
          encrypted: room.encrypted,
          roomName: room.roomName,
          messageKey: room.messageKey,
          password: room.password,
          tags: room.tags,
          sortOrder: room.sortOrder,
          servers: room.servers,
          customParam: room.customParam,
          networkConfigJson: room.networkConfigJson,
        );
        await _repository.updateRoom(updatedRoom);
        return updatedRoom;
      }
      return room;
    }));
    
    state.setRooms(updatedRooms);

    final selectedRoom = await _repository.getSelectedRoom();
    state.selectRoom(selectedRoom);
  }

  // ========== 业务方法 ==========

  Future<void> addRoom(Room room) async {
    // 获取所有现有房间
    final existingRooms = await _repository.getAllRooms();
    
    // 检测并处理重复名称
    final uniqueName = DuplicateNameDetection.detectAndHandleDuplicateName(
      room.name,
      existingRooms,
    );
    
    // 更新房间名称和修改时间
    final updatedRoom = Room(
      id: room.id,
      name: uniqueName,
      encrypted: room.encrypted,
      roomName: room.roomName,
      messageKey: room.messageKey,
      password: room.password,
      tags: room.tags,
      sortOrder: room.sortOrder,
      servers: room.servers,
      customParam: room.customParam,
      networkConfigJson: room.networkConfigJson,
    );
    
    // 添加房间
    await _repository.addRoom(updatedRoom);
    await _refreshRooms();
  }

  Future<void> deleteRoom(int id) async {
    await _repository.deleteRoom(id);
    await _refreshRooms();
  }

  Future<void> updateRoom(Room room) async {
    // 获取所有现有房间
    final existingRooms = await _repository.getAllRooms();
    
    // 检测并处理重复名称，排除当前房间
    final uniqueName = DuplicateNameDetection.detectAndHandleDuplicateName(
      room.name,
      existingRooms,
      excludedRoomId: room.id,
    );
    
    // 更新房间名称
    final updatedRoom = Room(
      id: room.id,
      name: uniqueName,
      encrypted: room.encrypted,
      roomName: room.roomName,
      messageKey: room.messageKey,
      password: room.password,
      tags: room.tags,
      sortOrder: room.sortOrder,
      servers: room.servers,
      customParam: room.customParam,
      networkConfigJson: room.networkConfigJson,
    );
    
    // 更新房间
    await _repository.updateRoom(updatedRoom);
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
