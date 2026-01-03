import 'package:astral/k/database/app_data.dart';

/// 应用通用设置的数据持久化
class AppSettingsRepository {
  final AppDatabase _db;

  AppSettingsRepository(this._db);

  // ========== 玩家设置 ==========

  Future<String> getPlayerName() => _db.AllSettings.getPlayerName();
  Future<void> setPlayerName(String name) =>
      _db.AllSettings.setPlayerName(name);

  // ========== 监听列表 ==========

  Future<List<String>> getListenList() => _db.AllSettings.getListenList();
  Future<void> setListenList(List<String> list) =>
      _db.AllSettings.setListenList(list);
  Future<void> updateListenList(int index, String value) =>
      _db.AllSettings.updateListenList(index, value);

  // ========== 排序与显示 ==========

  Future<bool> getUserMinimal() => _db.AllSettings.getUserMinimal();
  Future<void> setUserMinimal(bool value) =>
      _db.AllSettings.setUserMinimal(value);
  Future<int> getSortOption() => _db.AllSettings.getSortOption();
  Future<void> setSortOption(int value) => _db.AllSettings.setSortOption(value);
  Future<int> getSortOrder() => _db.AllSettings.getSortOrder();
  Future<void> setSortOrder(int value) => _db.AllSettings.setSortOrder(value);
  Future<int> getDisplayMode() => _db.AllSettings.getDisplayMode();
  Future<void> setDisplayMode(int value) =>
      _db.AllSettings.setDisplayMode(value);

  // ========== 启动设置 ==========

  Future<bool> getStartup() => _db.AllSettings.getStartup();
  Future<void> setStartup(bool value) => _db.AllSettings.setStartup(value);
  Future<bool> getStartupMinimize() => _db.AllSettings.getStartupMinimize();
  Future<void> setStartupMinimize(bool value) =>
      _db.AllSettings.setStartupMinimize(value);
  Future<bool> getStartupAutoConnect() =>
      _db.AllSettings.getStartupAutoConnect();
  Future<void> setStartupAutoConnect(bool value) =>
      _db.AllSettings.setStartupAutoConnect(value);

  // ========== 更新设置 ==========

  Future<bool> getBeta() => _db.AllSettings.getBeta();
  Future<void> setBeta(bool value) => _db.AllSettings.setBeta(value);
  Future<bool> getAutoCheckUpdate() => _db.AllSettings.getAutoCheckUpdate();
  Future<void> setAutoCheckUpdate(bool value) =>
      _db.AllSettings.setAutoCheckUpdate(value);
  Future<String> getDownloadAccelerate() =>
      _db.AllSettings.getDownloadAccelerate();
  Future<void> setDownloadAccelerate(String value) =>
      _db.AllSettings.setDownloadAccelerate(value);
  Future<String?> getLatestVersion() => _db.AllSettings.getLatestVersion();
  Future<void> setLatestVersion(String value) =>
      _db.AllSettings.setLatestVersion(value);

  // ========== 通知设置 ==========

  Future<bool> getEnableBannerCarousel() =>
      _db.AllSettings.getEnableBannerCarousel();
  Future<void> setEnableBannerCarousel(bool value) =>
      _db.AllSettings.setEnableBannerCarousel(value);
  Future<bool> getHasShownBannerTip() => _db.AllSettings.getHasShownBannerTip();
  Future<void> setHasShownBannerTip(bool value) =>
      _db.AllSettings.setHasShownBannerTip(value);

  // ========== 窗口设置 ==========

  Future<bool> getCloseMinimize() => _db.AllSettings.getCloseMinimize();
  Future<void> setCloseMinimize(bool value) =>
      _db.AllSettings.closeMinimize(value);

  // ========== 自定义VPN ==========

  Future<List<String>> getCustomVpn() => _db.AllSettings.getCustomVpn();
  Future<void> setCustomVpn(List<String> value) =>
      _db.AllSettings.setCustomVpn(value);
  Future<void> updateCustomVpn(int index, String value) =>
      _db.AllSettings.updateCustomVpn(index, value);

  // ========== MTU设置 ==========

  Future<bool> getAutoSetMTU() => _db.AllSettings.getAutoSetMTU();
  Future<void> setAutoSetMTU(bool value) =>
      _db.AllSettings.setAutoSetMTU(value);

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
      enableBannerCarousel: await getEnableBannerCarousel(),
      hasShownBannerTip: await getHasShownBannerTip(),
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
  final bool enableBannerCarousel;
  final bool hasShownBannerTip;
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
    required this.enableBannerCarousel,
    required this.hasShownBannerTip,
    required this.closeMinimize,
    required this.customVpn,
    required this.autoSetMTU,
  });
}
