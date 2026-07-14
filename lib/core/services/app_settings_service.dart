import 'package:astral/core/services/service_manager.dart';
import 'dart:io';

import 'package:astral/core/states/player_state.dart';
import 'package:astral/core/states/display_state.dart';
import 'package:astral/core/states/startup_state.dart';
import 'package:astral/core/states/update_state.dart';
import 'package:astral/core/states/window_state.dart';
import 'package:astral/core/states/vpn_state.dart';
import 'package:astral/core/states/app_settings_state.dart';
import 'package:astral/core/repositories/app_settings_repository.dart';
import 'package:astral/core/database/dao/all_settings_dao.dart';
import 'package:astral/shared/utils/github_proxy_selector.dart';
import 'package:astral/core/platform/startup_url_scheme.dart';

/// 应用设置服务：协调 State 与持久化
class AppSettingsService {
  final PlayerState playerState;
  final DisplayState displayState;
  final StartupState startupState;
  final UpdateState updateState;
  final WindowState windowState;
  final VpnState vpnState;
  final AppSettingsState appSettingsState;
  final AppSettingsRepository _repo;

  AppSettingsService({
    required this.playerState,
    required this.displayState,
    required this.startupState,
    required this.updateState,
    required this.windowState,
    required this.vpnState,
    required this.appSettingsState,
    required AppSettingsRepository repository,
  }) : _repo = repository;

  Future<void> init() async {
    final settings = await _repo.get();
    final listenList = await _repo.getListenList();
    final playerName = await _repo.getPlayerName();

    playerState.updatePlayerName(playerName);
    playerState.setListenList(listenList);

    displayState.setUserListSimple(settings.userListSimple);
    displayState.setSortOption(UserSortOption.fromIndex(settings.sortOption));
    displayState.setSortOrder(UserSortOrder.fromIndex(settings.sortOrder));
    displayState.setDisplayMode(UserDisplayMode.fromIndex(settings.displayMode));

    startupState.updateAll(
      startup: settings.startup,
      startupMinimize: settings.startupMinimize,
      startupAutoConnect: settings.startupAutoConnect,
    );

    updateState.setBeta(settings.beta);
    updateState.setAutoCheckUpdate(settings.autoCheckUpdate);

    var downloadAccelerate = settings.downloadAccelerate;
    if (downloadAccelerate == 'https://gh.xmly.dev/') {
      downloadAccelerate = GitHubProxySelector.autoMode;
      await _repo.update((s) => s.downloadAccelerate = downloadAccelerate);
    }
    updateState.setDownloadAccelerate(downloadAccelerate);
    updateState.setLatestVersion(settings.latestVersion);

    appSettingsState.updateEnableConnectionNotification(
      settings.enableConnectionNotification,
    );
    appSettingsState.updateReduceAnimationUpdates(
      settings.reduceAnimationUpdates,
    );
    appSettingsState.updateAutoRetryOnFailure(settings.autoRetryOnFailure);
    appSettingsState.updateMaxRetryCount(settings.maxRetryCount);

    windowState.setCloseMinimize(settings.closeMinimize);
    vpnState.setCustomVpn(List<String>.from(settings.customVpn));
  }

  Future<void> updatePlayerName(String name) async {
    playerState.updatePlayerName(name);
    await _repo.update((s) => s.playerName = name);
  }

  Future<void> setListenList(List<String> list) async {
    playerState.setListenList(list);
    await _repo.update((s) => s.listenList = list);
  }

  Future<void> addListen(String listen) async {
    playerState.addListen(listen);
    await _repo.update((s) => s.listenList = playerState.listenList.value);
  }

  Future<void> deleteListen(int index) async {
    playerState.removeListen(index);
    await _repo.update((s) => s.listenList = playerState.listenList.value);
  }

  Future<void> updateListen(int index, String listen) async {
    await _repo.update((s) {
      s.listenList ??= List<String>.from(AllSettingsDao.defaultListenList);
      s.listenList![index] = listen;
    });
    playerState.setListenList(await _repo.getListenList());
  }

  Future<void> setUserListSimple(bool value) async {
    displayState.setUserListSimple(value);
    await _repo.update((s) => s.userListSimple = value);
  }

  Future<void> setSortOption(UserSortOption option) async {
    displayState.setSortOption(option);
    await _repo.update((s) => s.sortOption = option.index);
  }

  Future<void> setSortOrder(UserSortOrder order) async {
    displayState.setSortOrder(order);
    await _repo.update((s) => s.sortOrder = order.index);
  }

  Future<void> setDisplayMode(UserDisplayMode mode) async {
    displayState.setDisplayMode(mode);
    await _repo.update((s) => s.displayMode = mode.index);
  }

  Future<void> setStartup(bool value) async {
    startupState.setStartup(value);
    await _repo.update((s) => s.startup = value);
    await handleStartupSetting(value);
  }

  Future<void> setStartupMinimize(bool value) async {
    startupState.setStartupMinimize(value);
    await _repo.update((s) => s.startupMinimize = value);
  }

  Future<void> setStartupAutoConnect(bool value) async {
    startupState.setStartupAutoConnect(value);
    await _repo.update((s) => s.startupAutoConnect = value);
  }

  Future<void> setBeta(bool value) async {
    updateState.setBeta(value);
    await _repo.update((s) => s.beta = value);
  }

  Future<void> setAutoCheckUpdate(bool value) async {
    updateState.setAutoCheckUpdate(value);
    await _repo.update((s) => s.autoCheckUpdate = value);
  }

  Future<void> setDownloadAccelerate(String value) async {
    updateState.setDownloadAccelerate(value);
    await _repo.update((s) => s.downloadAccelerate = value);
  }

  Future<void> updateLatestVersion(String version) async {
    updateState.setLatestVersion(version);
    await _repo.update((s) => s.latestVersion = version);
  }

  Future<void> updateEnableConnectionNotification(bool enable) async {
    appSettingsState.updateEnableConnectionNotification(enable);
    await _repo.update((s) => s.enableConnectionNotification = enable);

    if (!enable && Platform.isAndroid) {
      await ServiceManager().notifications.cancelConnectionNotification();
    }
  }

  Future<void> updateReduceAnimationUpdates(bool enable) async {
    appSettingsState.updateReduceAnimationUpdates(enable);
    await _repo.update((s) => s.reduceAnimationUpdates = enable);
  }

  Future<void> updateAutoRetryOnFailure(bool enable) async {
    appSettingsState.updateAutoRetryOnFailure(enable);
    await _repo.update((s) => s.autoRetryOnFailure = enable);
  }

  Future<void> updateMaxRetryCount(int count) async {
    appSettingsState.updateMaxRetryCount(count);
    await _repo.update((s) => s.maxRetryCount = count);
  }

  Future<void> updateCloseMinimize(bool value) async {
    windowState.setCloseMinimize(value);
    await _repo.update((s) => s.closeMinimize = value);
  }

  Future<void> addCustomVpn(String value) async {
    vpnState.addCustomVpn(value);
    await _repo.update((s) => s.customVpn = vpnState.customVpn.value);
  }

  Future<void> deleteCustomVpn(int index) async {
    vpnState.removeCustomVpn(index);
    await _repo.update((s) => s.customVpn = vpnState.customVpn.value);
  }

  Future<void> updateCustomVpn(int index, String value) async {
    await _repo.update((s) => s.customVpn[index] = value);
    vpnState.setCustomVpn(List<String>.from((await _repo.get()).customVpn));
  }
}
