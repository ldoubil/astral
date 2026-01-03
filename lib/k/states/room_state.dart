import 'package:astral/k/models/room.dart';
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

  void addRoom(Room room) {
    final list = List<Room>.from(rooms.value);
    list.add(room);
    rooms.value = list;
  }

  void removeRoom(int id) {
    final list = rooms.value.where((r) => r.id != id).toList();
    rooms.value = list;
  }

  void updateRoom(Room updatedRoom) {
    final list =
        rooms.value.map((r) {
          return r.id == updatedRoom.id ? updatedRoom : r;
        }).toList();
    rooms.value = list;
  }

  void reorderRooms(List<Room> reordered) {
    rooms.value = reordered;
  }

  // 查询方法
  Room? getRoomById(int id) {
    try {
      return rooms.value.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }
}
