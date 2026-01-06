import 'package:astral/core/database/app_data.dart';
import 'package:astral/core/constants/rooms.dart';

/// 房间管理的数据持久化
/// 现在只管理房间索引的保存和读取
class RoomRepository {
  final AppDatabase _db;

  RoomRepository(this._db);

  // ========== 查询操作 ==========

  /// 获取所有房间配置（固定常量列表）
  List<RoomConfig> getAllRooms() {
    return RoomsConstants.rooms;
  }

  /// 根据索引获取房间配置
  RoomConfig getRoomByIndex(int index) {
    return RoomsConstants.getRoomByIndex(index);
  }

  /// 获取当前选中的房间索引
  Future<int> getSelectedRoomIndex() async {
    return await _db.allSettings.getRoomIndex();
  }

  /// 获取当前选中的房间配置
  Future<RoomConfig> getSelectedRoom() async {
    return await _db.allSettings.getRoomConfig();
  }

  // ========== 写入操作 ==========

  /// 设置选中的房间（通过索引）
  Future<void> setSelectedRoomIndex(int index) async {
    await _db.allSettings.updateRoomIndex(index);
  }

  /// 设置选中的房间（通过房间名称）
  Future<void> setSelectedRoomByName(String roomName) async {
    final index = RoomsConstants.getIndexByRoomName(roomName);
    await _db.allSettings.updateRoomIndex(index);
  }
}
