import 'package:astral/core/database/app_data.dart';

/// 应用通用设置的数据持久化
class AppSettingsRepository {
  final AppDatabase _db;

  AppSettingsRepository(this._db);

  // ========== 玩家设置 ==========

  Future<String> getPlayerName() => _db.allSettings.getPlayerName();
  Future<void> setPlayerName(String name) =>
      _db.allSettings.setPlayerName(name);

  // ========== 监听列表 ==========

  Future<List<String>> getListenList() => _db.allSettings.getListenList();
  Future<void> setListenList(List<String> list) =>
      _db.allSettings.setListenList(list);
  Future<void> updateListenList(int index, String value) =>
      _db.allSettings.updateListenList(index, value);

  // ========== 排序与显示 ==========

  Future<bool> getUserMinimal() => _db.allSettings.getUserMinimal();
  Future<void> setUserMinimal(bool value) =>
      _db.allSettings.setUserMinimal(value);
  Future<int> getSortOption() => _db.allSettings.getSortOption();
  Future<void> setSortOption(int value) => _db.allSettings.setSortOption(value);
  Future<int> getSortOrder() => _db.allSettings.getSortOrder();
  Future<void> setSortOrder(int value) => _db.allSettings.setSortOrder(value);
  Future<int> getDisplayMode() => _db.allSettings.getDisplayMode();
  Future<void> setDisplayMode(int value) =>
      _db.allSettings.setDisplayMode(value);

  // ========== 启动设置 ==========

  Future<bool> getStartup() => _db.allSettings.getStartup();
  Future<void> setStartup(bool value) => _db.allSettings.setStartup(value);
  Future<bool> getStartupMinimize() => _db.allSettings.getStartupMinimize();
  Future<void> setStartupMinimize(bool value) =>
      _db.allSettings.setStartupMinimize(value);
  Future<bool> getStartupAutoConnect() =>
      _db.allSettings.getStartupAutoConnect();
  Future<void> setStartupAutoConnect(bool value) =>
      _db.allSettings.setStartupAutoConnect(value);

  // ========== 更新设置 ==========

  Future<bool> getBeta() => _db.allSettings.getBeta();
  Future<void> setBeta(bool value) => _db.allSettings.setBeta(value);
  Future<bool> getAutoCheckUpdate() => _db.allSettings.getAutoCheckUpdate();
  Future<void> setAutoCheckUpdate(bool value) =>
      _db.allSettings.setAutoCheckUpdate(value);
  Future<String> getDownloadAccelerate() =>
      _db.allSettings.getDownloadAccelerate();
  Future<void> setDownloadAccelerate(String value) =>
      _db.allSettings.setDownloadAccelerate(value);
  Future<String?> getLatestVersion() => _db.allSettings.getLatestVersion();
  Future<void> setLatestVersion(String value) =>
      _db.allSettings.setLatestVersion(value);

  // ========== 窗口设置 ==========

  Future<bool> getCloseMinimize() => _db.allSettings.getCloseMinimize();
  Future<void> setCloseMinimize(bool value) =>
      _db.allSettings.closeMinimize(value);

  // ========== 自定义VPN ==========

  Future<List<String>> getCustomVpn() => _db.allSettings.getCustomVpn();
  Future<void> setCustomVpn(List<String> value) =>
      _db.allSettings.setCustomVpn(value);
  Future<void> updateCustomVpn(int index, String value) =>
      _db.allSettings.updateCustomVpn(index, value);

  // ========== MTU设置 ==========

  Future<bool> getAutoSetMTU() => _db.allSettings.getAutoSetMTU();
  Future<void> setAutoSetMTU(bool value) =>
      _db.allSettings.setAutoSetMTU(value);

  // ========== 批量操作 ==========

  Future<AppSettings> loadAll() async {
    return AppSettings(
      playerName: await getPlayerName(),
      listenList: await getListenList(),
      userMinimal: await getUserMinimal(),
      sortOption: await getSortOption(),
      sortOrder: await getSortOrder(),
      displayMode: await getDisplayMode(),
      startup: await getStartup(),
      startupMinimize: await getStartupMinimize(),
      startupAutoConnect: await getStartupAutoConnect(),
      beta: await getBeta(),
      autoCheckUpdate: await getAutoCheckUpdate(),
      downloadAccelerate: await getDownloadAccelerate(),
      latestVersion: await getLatestVersion(),
      closeMinimize: await getCloseMinimize(),
      customVpn: await getCustomVpn(),
      autoSetMTU: await getAutoSetMTU(),
    );
  }
}

/// 应用设置数据类
class AppSettings {
  final String playerName;
  final List<String> listenList;
  final bool userMinimal;
  final int sortOption;
  final int sortOrder;
  final int displayMode;
  final bool startup;
  final bool startupMinimize;
  final bool startupAutoConnect;
  final bool beta;
  final bool autoCheckUpdate;
  final String downloadAccelerate;
  final String? latestVersion;
  final bool closeMinimize;
  final List<String> customVpn;
  final bool autoSetMTU;

  AppSettings({
    required this.playerName,
    required this.listenList,
    required this.userMinimal,
    required this.sortOption,
    required this.sortOrder,
    required this.displayMode,
    required this.startup,
    required this.startupMinimize,
    required this.startupAutoConnect,
    required this.beta,
    required this.autoCheckUpdate,
    required this.downloadAccelerate,
    required this.latestVersion,
    required this.closeMinimize,
    required this.customVpn,
    required this.autoSetMTU,
  });
}
