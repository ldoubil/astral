import 'dart:io';

import 'package:astral/core/models/all_settings.dart';
import 'package:astral/core/models/room.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:isar_community/isar.dart';

class AllSettingsCz {
  final Isar _isar;

  AllSettingsCz(this._isar) {
    init();
  }
  Future<void> init() async {
    AllSettings? settings = await _isar.allSettings.get(1);

    if (settings == null) {
      // 如果是首次运行，创建新实例并使用默认值
      settings = AllSettings();
      // 只需要设置特殊的默认值（需要异步获取的）
      settings.playerName = await _getDeviceName();

      // 设置排序相关的默认值
      settings.sortOption = 0; // 默认排序选项
      settings.sortOrder = 0; // 默认升序
      settings.displayMode = 0; // 默认显示模式

      await _isar.writeTxn(() async {
        await _isar.allSettings.put(settings!);
      });
    } else {
      // 如果 settings 已存在，检查需要迁移的字段
      bool needsUpdate = false;

      // 检查 playerName
      if (settings.playerName == null || settings.playerName!.isEmpty) {
        settings.playerName = await _getDeviceName();
        needsUpdate = true;
      }

      if (needsUpdate) {
        await _isar.writeTxn(() async {
          await _isar.allSettings.put(settings!);
        });
      }
    }
  }

  /// 设置轮播图开关
  Future<void> setEnableBannerCarousel(bool enable) async {
    AllSettings? settings = await _isar.allSettings.get(1);
    if (settings != null) {
      settings.enableBannerCarousel = enable;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(settings);
      });
    }
  }

  /// 获取轮播图开关
  Future<bool> getEnableBannerCarousel() async {
    AllSettings? settings = await _isar.allSettings.get(1);
    return settings?.enableBannerCarousel ?? true;
  }

  /// 设置是否已显示轮播图提示
  Future<void> setHasShownBannerTip(bool hasShown) async {
    AllSettings? settings = await _isar.allSettings.get(1);
    if (settings != null) {
      settings.hasShownBannerTip = hasShown;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(settings);
      });
    }
  }

  /// 获取是否已显示轮播图提示
  Future<bool> getHasShownBannerTip() async {
    AllSettings? settings = await _isar.allSettings.get(1);
    return settings?.hasShownBannerTip ?? false;
  }

  /// 设置用户简约模式
  /// @param isMinimal 是否启用简约模式
  /// 将新的简约模式设置保存到数据库中
  Future<void> setUserMinimal(bool isMinimal) async {
    AllSettings? settings = await _isar.allSettings.get(1);
    if (settings != null) {
      settings.userListSimple = isMinimal;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(settings);
      });
    }
  }

  /// 获取用户简约模式
  /// @return 是否启用简约模式
  Future<bool> getUserMinimal() async {
    AllSettings? settings = await _isar.allSettings.get(1);
    if (settings != null) {
      return settings.userListSimple;
    }
    return false;
  }

  // getListenList
  Future<List<String>> getListenList() async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config?.listenList == null || config!.listenList!.isEmpty) {
      // 返回默认值并保存到数据库
      final defaultList = ["tcp://0.0.0.0:0", "udp://0.0.0.0:0"];
      if (config != null) {
        config.listenList = defaultList;
        await _isar.writeTxn(() async {
          await _isar.allSettings.put(config);
        });
      }
      return defaultList;
    }
    return config.listenList!;
  }

  ///closeMinimize
  /// @param isClose 是否关闭最小化到托盘
  /// 将新的最小化到托盘设置保存到数据库中
  Future<void> closeMinimize(bool isClose) async {
    AllSettings? settings = await _isar.allSettings.get(1);
    if (settings != null) {
      settings.closeMinimize = isClose;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(settings);
      });
    }
  }

  ///getCloseMinimize
  /// @return 是否关闭最小化到托盘
  Future<bool> getCloseMinimize() async {
    AllSettings? settings = await _isar.allSettings.get(1);
    if (settings != null) {
      return settings.closeMinimize;
    }
    return false;
  }

  // 设置监听列表
  Future<void> setListenList(List<String> listenList) async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      config.listenList = listenList;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(config);
      });
    }
  }

  // 删除监听列表
  Future<void> deleteListenList(int index) async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      config.listenList!.removeAt(index);
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(config);
      });
    }
  }

  // 添加监听列表
  Future<void> addListenList(String listen) async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      config.listenList!.add(listen);
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(config);
      });
    }
  }

  // 修改监听列表
  Future<void> updateListenList(int index, String listen) async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      config.listenList![index] = listen;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(config);
      });
    }
  }

  // 设置房间
  Future<void> updateRoom(Room room) async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      config.room = room.id;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(config);
      });
    }
  }

  // 获取当前房间ID
  Future<Room?> getRoom() async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config?.room == null) return null;
    return await _isar.rooms.get(config!.room!);
  }

  // 获取所有设置
  Future<AllSettings?> getAllSettings() async {
    return await _isar.allSettings.get(1);
  }

  // 设定玩家名称
  Future<void> setPlayerName(String name) async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      config.playerName = name;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(config);
      });
    }
  }

  // 获取玩家名称
  Future<String> getPlayerName() async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config?.playerName == null) {
      String deviceName = await _getDeviceName();
      await setPlayerName(deviceName);
      return deviceName;
    }
    return config!.playerName!;
  }

  // 设置自定义VPN网段
  Future<void> setCustomVpn(List<String> customVpn) async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      config.customVpn = customVpn;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(config);
      });
    }
  }

  // 删除自定义VPN网段
  Future<void> deleteCustomVpn(int index) async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      config.customVpn.removeAt(index);
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(config);
      });
    }
  }

  // 添加自定义VPN网段
  Future<void> addCustomVpn(String vpn) async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      config.customVpn.add(vpn);
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(config);
      });
    }
  }

  // 修改自定义VPN网段
  Future<void> updateCustomVpn(int index, String vpn) async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      config.customVpn[index] = vpn;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(config);
      });
    }
  }

  // 获取自定义VPN网段
  Future<List<String>> getCustomVpn() async {
    AllSettings? config = await _isar.allSettings.get(1);
    return config?.customVpn ?? [];
  }

  /// 设置开机自启
  Future<void> setStartup(bool isStartup) async {
    AllSettings? settings = await _isar.allSettings.get(1);
    if (settings != null) {
      settings.startup = isStartup;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(settings);
      });
    }
  }

  /// 获取开机自启状态
  Future<bool> getStartup() async {
    AllSettings? settings = await _isar.allSettings.get(1);
    if (settings != null) {
      return settings.startup;
    }
    return false;
  }

  /// 设置启动后最小化
  Future<void> setStartupMinimize(bool isMinimize) async {
    AllSettings? settings = await _isar.allSettings.get(1);
    if (settings != null) {
      settings.startupMinimize = isMinimize;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(settings);
      });
    }
  }

  /// 获取启动后最小化状态
  Future<bool> getStartupMinimize() async {
    AllSettings? settings = await _isar.allSettings.get(1);
    if (settings != null) {
      return settings.startupMinimize;
    }
    return false;
  }

  /// 设置启动后自动连接
  Future<void> setStartupAutoConnect(bool isAutoConnect) async {
    AllSettings? settings = await _isar.allSettings.get(1);
    if (settings != null) {
      settings.startupAutoConnect = isAutoConnect;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(settings);
      });
    }
  }

  /// 获取启动后自动连接状态
  Future<bool> getStartupAutoConnect() async {
    AllSettings? settings = await _isar.allSettings.get(1);
    if (settings != null) {
      return settings.startupAutoConnect;
    }
    return false;
  }
  //autoSetMTU

  /// 设置自动设置网卡跃点
  Future<void> setAutoSetMTU(bool isAutoSet) async {
    AllSettings? settings = await _isar.allSettings.get(1);
    if (settings != null) {
      settings.autoSetMTU = isAutoSet;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(settings);
      });
    }
  }

  /// 获取自动设置网卡跃点状态
  Future<bool> getAutoSetMTU() async {
    AllSettings? settings = await _isar.allSettings.get(1);
    if (settings != null) {
      return settings.autoSetMTU;
    }
    return true;
  }

  /// 设置参与测试版
  Future<void> setBeta(bool isBeta) async {
    AllSettings? settings = await _isar.allSettings.get(1);
    if (settings != null) {
      settings.beta = isBeta;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(settings);
      });
    }
  }

  /// 获取参与测试版状态
  Future<bool> getBeta() async {
    AllSettings? settings = await _isar.allSettings.get(1);
    return settings?.beta ?? AllSettings().beta;
  }

  /// 设置自动检查更新
  Future<void> setAutoCheckUpdate(bool isAutoCheck) async {
    AllSettings? settings = await _isar.allSettings.get(1);
    if (settings != null) {
      settings.autoCheckUpdate = isAutoCheck;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(settings);
      });
    }
  }

  /// 获取自动检查更新状态
  Future<bool> getAutoCheckUpdate() async {
    AllSettings? settings = await _isar.allSettings.get(1);
    return settings?.autoCheckUpdate ?? AllSettings().autoCheckUpdate;
  }

  /// 设置下载加速地址
  Future<void> setDownloadAccelerate(String accelerateUrl) async {
    AllSettings? settings = await _isar.allSettings.get(1);
    if (settings != null) {
      settings.downloadAccelerate = accelerateUrl;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(settings);
      });
    }
  }

  /// 获取下载加速地址
  Future<String> getDownloadAccelerate() async {
    AllSettings? settings = await _isar.allSettings.get(1);
    return settings?.downloadAccelerate ?? AllSettings().downloadAccelerate;
  }

  /// 设置服务器排序字段
  Future<void> setServerSortField(String field) async {
    AllSettings? settings = await _isar.allSettings.get(1);
    if (settings != null) {
      settings.serverSortField = field;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(settings);
      });
    }
  }

  /// 获取服务器排序字段
  Future<String> getServerSortField() async {
    AllSettings? settings = await _isar.allSettings.get(1);
    return settings?.serverSortField ?? AllSettings().serverSortField;
  }

  /// 获取用户ID
  Future<String?> getUserId() async {
    AllSettings? settings = await _isar.allSettings.get(1);
    return settings?.userId;
  }

  /// 设置用户ID
  Future<void> setUserId(String userId) async {
    AllSettings? settings = await _isar.allSettings.get(1);
    if (settings != null) {
      settings.userId = userId;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(settings);
      });
    }
  }

  /// 设置最新版本号
  Future<void> setLatestVersion(String version) async {
    AllSettings? settings = await _isar.allSettings.get(1);
    if (settings != null) {
      settings.latestVersion = version;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(settings);
      });
    }
  }

  /// 获取最新版本号
  Future<String?> getLatestVersion() async {
    AllSettings? settings = await _isar.allSettings.get(1);
    return settings?.latestVersion;
  }

  /// 设置排序选项
  Future<void> setSortOption(int option) async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      config.sortOption = option;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(config);
      });
    }
  }

  /// 获取排序选项
  Future<int> getSortOption() async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      return config.sortOption;
    }
    return 0;
  }

  /// 设置排序方式
  Future<void> setSortOrder(int order) async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      config.sortOrder = order;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(config);
      });
    }
  }

  /// 获取排序方式
  Future<int> getSortOrder() async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      return config.sortOrder;
    }
    return 0;
  }

  /// 设置显示模式
  Future<void> setDisplayMode(int mode) async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      config.displayMode = mode;
      await _isar.writeTxn(() async {
        await _isar.allSettings.put(config);
      });
    }
  }

  /// 获取显示模式
  Future<int> getDisplayMode() async {
    AllSettings? config = await _isar.allSettings.get(1);
    if (config != null) {
      return config.displayMode;
    }
    return 0;
  }

  Future<String> _getDeviceName() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.name;
      } else if (Platform.isWindows) {
        WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
        return windowsInfo.computerName;
      } else if (Platform.isMacOS) {
        MacOsDeviceInfo macOSInfo = await deviceInfo.macOsInfo;
        return macOSInfo.computerName;
      } else if (Platform.isLinux) {
        LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
        return linuxInfo.name;
      }

      return "Default Player"; // 如果无法获取设备名称，则使用默认名称
    } catch (e) {
      return "Default Player"; // 错误处理，返回默认名称
    }
  }
}
