import 'dart:io';

import 'package:astral/core/models/all_settings.dart';
import 'package:astral/core/models/room.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:isar_community/isar.dart';

/// 单例 [AllSettings] 的 Isar 访问（id 固定为 1）。
class AllSettingsDao {
  static const int _id = 1;
  static const defaultListenList = ['tcp://0.0.0.0:0', 'udp://0.0.0.0:0'];

  final Isar _isar;

  AllSettingsDao(this._isar) {
    init();
  }

  Future<AllSettings?> getOrNull() => _isar.allSettings.get(_id);

  Future<AllSettings> get() async {
    final settings = await getOrNull();
    if (settings == null) {
      throw StateError('AllSettings not initialized');
    }
    return settings;
  }

  Future<void> save(AllSettings settings) async {
    settings.id = _id;
    await _isar.writeTxn(() async {
      await _isar.allSettings.put(settings);
    });
  }

  Future<void> update(void Function(AllSettings settings) mutate) async {
    final settings = await getOrNull();
    if (settings == null) return;
    mutate(settings);
    await save(settings);
  }

  Future<void> init() async {
    var settings = await getOrNull();

    if (settings == null) {
      settings = AllSettings();
      settings.playerName = await _getDeviceName();
      settings.sortOption = 0;
      settings.sortOrder = 0;
      settings.displayMode = 0;
      await save(settings);
      return;
    }

    if (settings.playerName == null || settings.playerName!.isEmpty) {
      settings.playerName = await _getDeviceName();
      await save(settings);
    }
  }

  Future<List<String>> getListenList() async {
    final config = await getOrNull();
    if (config?.listenList == null || config!.listenList!.isEmpty) {
      if (config != null) {
        config.listenList = List<String>.from(defaultListenList);
        await save(config);
      }
      return List<String>.from(defaultListenList);
    }
    return config.listenList!;
  }

  Future<void> setSelectedRoom(Room room) =>
      update((config) => config.room = room.id);

  Future<Room?> getRoom() async {
    final config = await getOrNull();
    if (config?.room == null) return null;
    return _isar.rooms.get(config!.room!);
  }

  Future<String> getPlayerName() async {
    final config = await getOrNull();
    if (config?.playerName == null || config!.playerName!.isEmpty) {
      final deviceName = await _getDeviceName();
      await update((s) => s.playerName = deviceName);
      return deviceName;
    }
    return config.playerName!;
  }

  Future<String> _getDeviceName() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        return (await deviceInfo.androidInfo).model;
      } else if (Platform.isIOS) {
        return (await deviceInfo.iosInfo).name;
      } else if (Platform.isWindows) {
        return (await deviceInfo.windowsInfo).computerName;
      } else if (Platform.isMacOS) {
        return (await deviceInfo.macOsInfo).computerName;
      } else if (Platform.isLinux) {
        return (await deviceInfo.linuxInfo).name;
      }

      return 'Default Player';
    } catch (_) {
      return 'Default Player';
    }
  }
}
