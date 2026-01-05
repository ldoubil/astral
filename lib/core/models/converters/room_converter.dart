import 'dart:math';
import 'package:isar_community/isar.dart';
import 'package:astral/core/models/room.dart'; // 添加 Room 模型的导入

class RoomCz {
  final Isar _isar;
  bool _initialized = false;

  RoomCz(this._isar);

  Future<void> init() async {
    if (_initialized) return;

    // 如果没有任何房间，随机创建一个默认房间
    if (await _isar.rooms.count() == 0) {
      final random = Random();
      final randomRoomId =
          random.nextInt(900000) + 100000; // 6位随机数字 (100000-999999)
      final randomPassword = random.nextInt(900000) + 100000; // 6位随机密码

      final defaultRoom = Room(
        name: "默认房间",
        roomName: randomRoomId.toString(),
        encrypted: true, // 默认使用加密
        password: randomPassword.toString(),
        messageKey: "",
        tags: [],
        sortOrder: 0,
        servers: [],
        customParam: "",
      );

      await _isar.writeTxn(() async {
        await _isar.rooms.put(defaultRoom);
      });
    }

    _initialized = true;
  }

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
    return await _isar.rooms
        .filter()
        .tagsElementEqualTo(tag)
        .sortBySortOrder()
        .findAll();
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
