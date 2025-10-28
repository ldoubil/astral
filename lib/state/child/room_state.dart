import 'package:astral/models/room_config.dart';
import 'package:hive/hive.dart';
import 'package:signals_flutter/signals_flutter.dart';

class RoomState {
  late Signal<List<RoomConfig>> roomConfig;

  RoomState() {
    roomConfig = signal<List<RoomConfig>>([]);
    loadRoomConfigs();
  }

  /// 加载房间配置到Signal
  void loadRoomConfigs() {
    final box = Hive.box<RoomConfig>('RoomConfigs');
    roomConfig.value = box.values.toList();
    print('[RoomState] 加载房间配置，当前数量: \\${roomConfig.value.length}');
    for (final room in roomConfig.value) {
      print(
        '[RoomState] 加载房间: uuid=\\${room.room_uuid}, name=\\${room.room_name}',
      );
    }
  }

  /// 添加房间配置
  void addRoomConfig(RoomConfig config) {
    final box = Hive.box<RoomConfig>('RoomConfigs');
    box.add(config);
    print(
      '[RoomState] 添加房间: uuid=\\${config.room_uuid}, name=\\${config.room_name}',
    );
    loadRoomConfigs();
  }

  /// 删除房间配置
  void removeRoomConfig(String roomUuid) {
    final box = Hive.box<RoomConfig>('RoomConfigs');
    final keys = box.keys.toList();
    for (final key in keys) {
      final room = box.get(key);
      if (room?.room_uuid == roomUuid) {
        box.delete(key);
        print(
          '[RoomState] 删除房间: uuid=\\${room?.room_uuid}, name=\\${room?.room_name}',
        );
        break;
      }
    }
    loadRoomConfigs();
  }

  /// 更新房间配置
  void updateRoomConfig(RoomConfig updatedConfig) {
    final box = Hive.box<RoomConfig>('RoomConfigs');
    final keys = box.keys.toList();
    for (final key in keys) {
      final room = box.get(key);
      if (room?.room_uuid == updatedConfig.room_uuid) {
        box.put(key, updatedConfig);
        print(
          '[RoomState] 更新房间: uuid=\\${updatedConfig.room_uuid}, name=\\${updatedConfig.room_name}',
        );
        break;
      }
    }
    loadRoomConfigs();
  }
}
