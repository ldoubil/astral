import 'package:astral/core/models/room.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 房间状态（纯Signal）
class RoomState {
  // 房间列表
  final rooms = signal<List<Room>>([]);

  // 当前选中的房间
  final selectedRoom = signal<Room?>(null);

  // 状态更新方法
  void setRooms(List<Room> roomList) {
    rooms.value = roomList;
  }

  void selectRoom(Room? room) {
    selectedRoom.value = room;
  }
}
