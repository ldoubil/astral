import 'package:astral/core/constants/rooms.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 房间状态（纯Signal）
/// 使用固定的房间常量列表，只保存选中的索引
class RoomState {
  // 当前选中的房间索引（对应 RoomsConstants.rooms 列表）
  final selectedRoomIndex = signal<int>(0);

  // 获取所有房间配置（固定常量列表）
  List<RoomConfig> get allRooms => RoomsConstants.rooms;

  // 获取当前选中的房间配置
  RoomConfig get selectedRoom =>
      RoomsConstants.getRoomByIndex(selectedRoomIndex.value);

  // 选择房间（通过索引）
  void selectRoomByIndex(int index) {
    if (index >= 0 && index < RoomsConstants.count) {
      selectedRoomIndex.value = index;
    }
  }

  // 选择房间（通过房间名称）
  void selectRoomByName(String roomName) {
    final index = RoomsConstants.getIndexByRoomName(roomName);
    selectedRoomIndex.value = index;
  }

  // 获取房间总数
  int get roomCount => RoomsConstants.count;
}
