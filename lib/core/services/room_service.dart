import 'package:astral/core/states/room_state.dart';
import 'package:astral/core/repositories/room_repository.dart';
import 'package:astral/core/constants/rooms.dart';

/// 房间服务：协调RoomState和RoomRepository
/// 现在使用固定的房间常量列表，只管理房间索引的选择
class RoomService {
  final RoomState state;
  final RoomRepository _repository;

  RoomService(this.state, this._repository);

  // ========== 初始化 ==========

  Future<void> init() async {
    // 从数据库读取选中的房间索引
    final selectedIndex = await _repository.getSelectedRoomIndex();
    state.selectRoomByIndex(selectedIndex);
  }

  // ========== 业务方法 ==========

  /// 获取所有房间配置（固定常量列表）
  List<RoomConfig> getAllRooms() {
    return state.allRooms;
  }

  /// 通过索引选择房间
  Future<void> selectRoomByIndex(int index) async {
    await _repository.setSelectedRoomIndex(index);
    state.selectRoomByIndex(index);
  }

  /// 通过房间名称选择房间
  Future<void> selectRoomByName(String roomName) async {
    await _repository.setSelectedRoomByName(roomName);
    state.selectRoomByName(roomName);
  }

  /// 获取当前选中的房间配置
  RoomConfig getSelectedRoom() {
    return state.selectedRoom;
  }

  /// 获取当前选中的房间索引
  int getSelectedRoomIndex() {
    return state.selectedRoomIndex.value;
  }

  /// 根据索引获取房间配置
  RoomConfig getRoomByIndex(int index) {
    return RoomsConstants.getRoomByIndex(index);
  }

  /// 获取房间总数
  int getRoomCount() {
    return state.roomCount;
  }
}
