import 'package:astral/core/states/player_state.dart';
import 'package:astral/core/states/display_state.dart';
import 'package:astral/core/states/startup_state.dart';
import 'package:astral/core/states/update_state.dart';
import 'package:astral/core/states/notification_state.dart';
import 'package:astral/core/states/window_state.dart';
import 'package:astral/core/states/vpn_state.dart';
import 'package:astral/core/states/firewall_state.dart';
import 'package:astral/core/repositories/app_settings_repository.dart';
import 'package:astral/src/rust/api/hops.dart';

/// 应用设置服务：协调多个State和AppSettingsRepository
class AppSettingsService {
  final PlayerState playerState;
  final DisplayState displayState;
  final StartupState startupState;
  final UpdateState updateState;
  final NotificationState notificationState;
  final WindowState windowState;
  final VpnState vpnState;
  final FirewallState firewallState;
  final AppSettingsRepository _repository;

  AppSettingsService({
    required this.playerState,
    required this.displayState,
    required this.startupState,
    required this.updateState,
    required this.notificationState,
    required this.windowState,
    required this.vpnState,
    required this.firewallState,
    required AppSettingsRepository repository,
  }) : _repository = repository;

  // ========== 初始化 ==========

  Future<void> init() async {
    final settings = await _repository.loadAll();

    // 更新各个状态
    playerState.updatePlayerName(settings.playerName);
    playerState.setListenList(settings.listenList);
    playerState.setUserListSimple(settings.userMinimal);

    displayState.setSortOption(settings.sortOption);
    displayState.setSortOrder(settings.sortOrder);
    displayState.setDisplayMode(settings.displayMode);

    startupState.updateAll(
      startup: settings.startup,
      startupMinimize: settings.startupMinimize,
      startupAutoConnect: settings.startupAutoConnect,
    );

    updateState.setBeta(settings.beta);
    updateState.setAutoCheckUpdate(settings.autoCheckUpdate);
    updateState.setDownloadAccelerate(settings.downloadAccelerate);
    updateState.setLatestVersion(settings.latestVersion);

    notificationState.setEnableBannerCarousel(settings.enableBannerCarousel);
    notificationState.setHasShownBannerTip(settings.hasShownBannerTip);

    windowState.setCloseMinimize(settings.closeMinimize);

    vpnState.setCustomVpn(settings.customVpn);

    firewallState.setAutoSetMTU(settings.autoSetMTU);
  }

  // ========== 玩家设置 ==========

  Future<void> updatePlayerName(String name) async {
    playerState.updatePlayerName(name);
    await _repository.setPlayerName(name);
  }

  Future<void> setListenList(List<String> list) async {
    playerState.setListenList(list);
    await _repository.setListenList(list);
  }

  Future<void> addListen(String listen) async {
    playerState.addListen(listen);
    await _repository.setListenList(playerState.listenList.value);
  }

  Future<void> deleteListen(int index) async {
    playerState.removeListen(index);
    await _repository.setListenList(playerState.listenList.value);
  }

  Future<void> updateListen(int index, String listen) async {
    await _repository.updateListenList(index, listen);
    final updated = await _repository.getListenList();
    playerState.setListenList(updated);
  }

  Future<void> setUserListSimple(bool value) async {
    displayState.setUserListSimple(value); // 修复：应该更新displayState而不是playerState
    await _repository.setUserMinimal(value);
  }

  // ========== 排序与显示 ==========

  Future<void> setSortOption(int option) async {
    displayState.setSortOption(option);
    await _repository.setSortOption(option);
  }

  Future<void> setSortOrder(int order) async {
    displayState.setSortOrder(order);
    await _repository.setSortOrder(order);
  }

  Future<void> setDisplayMode(int mode) async {
    displayState.setDisplayMode(mode);
    await _repository.setDisplayMode(mode);
  }

  // ========== 启动设置 ==========

  Future<void> setStartup(bool value) async {
    startupState.setStartup(value);
    await _repository.setStartup(value);
  }

  Future<void> setStartupMinimize(bool value) async {
    startupState.setStartupMinimize(value);
    await _repository.setStartupMinimize(value);
  }

  Future<void> setStartupAutoConnect(bool value) async {
    startupState.setStartupAutoConnect(value);
    await _repository.setStartupAutoConnect(value);
  }

  // ========== 更新设置 ==========

  Future<void> setBeta(bool value) async {
    updateState.setBeta(value);
    await _repository.setBeta(value);
  }

  Future<void> setAutoCheckUpdate(bool value) async {
    updateState.setAutoCheckUpdate(value);
    await _repository.setAutoCheckUpdate(value);
  }

  Future<void> setDownloadAccelerate(String value) async {
    updateState.setDownloadAccelerate(value);
    await _repository.setDownloadAccelerate(value);
  }

  Future<void> updateLatestVersion(String version) async {
    updateState.setLatestVersion(version);
    await _repository.setLatestVersion(version);
  }

  // ========== 通知设置 ==========

  Future<void> updateEnableBannerCarousel(bool enable) async {
    notificationState.setEnableBannerCarousel(enable);
    await _repository.setEnableBannerCarousel(enable);
  }

  Future<void> updateHasShownBannerTip(bool hasShown) async {
    notificationState.setHasShownBannerTip(hasShown);
    await _repository.setHasShownBannerTip(hasShown);
  }

  Future<void> loadHasShownBannerTip() async {
    final value = await _repository.getHasShownBannerTip();
    notificationState.setHasShownBannerTip(value);
  }

  // ========== 窗口设置 ==========

  Future<void> updateCloseMinimize(bool value) async {
    windowState.setCloseMinimize(value);
    await _repository.setCloseMinimize(value);
  }

  // ========== 自定义VPN ==========

  Future<void> addCustomVpn(String value) async {
    vpnState.addCustomVpn(value);
    await _repository.setCustomVpn(vpnState.customVpn.value);
  }

  Future<void> deleteCustomVpn(int index) async {
    vpnState.removeCustomVpn(index);
    await _repository.setCustomVpn(vpnState.customVpn.value);
  }

  Future<void> updateCustomVpn(int index, String value) async {
    await _repository.updateCustomVpn(index, value);
    final updated = await _repository.getCustomVpn();
    vpnState.setCustomVpn(updated);
  }

  // ========== MTU设置 ==========

  Future<void> setAutoSetMTU(bool value) async {
    firewallState.setAutoSetMTU(value);
    await _repository.setAutoSetMTU(value);
    await setInterfaceMetric(interfaceName: "astral", metric: 0);
  }

  Future<void> updateListenListFromDb() async {
    final list = await _repository.getListenList();
    playerState.setListenList(list);
  }
}
