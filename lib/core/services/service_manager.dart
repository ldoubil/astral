import 'dart:io';

import 'package:astral/core/database/app_data.dart';
import 'package:astral/core/database/dao/magic_wall_dao.dart';
import 'package:flutter/foundation.dart';

// States
import 'package:astral/core/states/theme_state.dart';
import 'package:astral/core/states/ui_state.dart';
import 'package:astral/core/states/room_state.dart';
import 'package:astral/core/states/server_state.dart';
import 'package:astral/core/states/network_config_state.dart';
import 'package:astral/core/states/player_state.dart';
import 'package:astral/core/states/display_state.dart';
import 'package:astral/core/states/startup_state.dart';
import 'package:astral/core/states/update_state.dart';
import 'package:astral/core/states/connection_state.dart';
import 'package:astral/core/states/window_state.dart';
import 'package:astral/core/states/firewall_state.dart';
import 'package:astral/core/states/vpn_state.dart';
import 'package:astral/core/states/app_settings_state.dart';
import 'package:astral/core/states/server_status_state.dart';

// Repositories
import 'package:astral/core/repositories/theme_repository.dart';
import 'package:astral/core/repositories/network_config_repository.dart';
import 'package:astral/core/repositories/app_settings_repository.dart';

// Services
import 'package:astral/core/services/connection_connect_guard.dart';
import 'package:astral/core/services/theme_service.dart';
import 'package:astral/core/services/room_service.dart';
import 'package:astral/core/services/server_service.dart';
import 'package:astral/core/services/network_config_service.dart';
import 'package:astral/core/services/app_settings_service.dart';
import 'package:astral/core/services/firewall_service.dart';
import 'package:astral/core/services/server_connection_manager.dart';
import 'package:astral/core/services/vpn_manager.dart';
import 'package:astral/core/services/notification_service.dart';
import 'package:astral/core/services/widget_service.dart';

/// 服务管理器：统一管理领域服务与运行时单例入口
class ServiceManager {
  static ServiceManager? _instance;
  static ServiceManager get instance {
    _instance ??= ServiceManager._internal();
    return _instance!;
  }

  factory ServiceManager() => instance;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  ServiceManager._internal() {
    _initializeStates();
    _initializeData();
    _initializeServices();
  }

  // ========== States ==========
  late final ThemeState themeState;
  late final UIState uiState;
  late final RoomState roomState;
  late final ServerState serverState;
  late final NetworkConfigState networkConfigState;
  late final PlayerState playerState;
  late final DisplayState displayState;
  late final StartupState startupState;
  late final UpdateState updateState;
  late final ConnectionState connectionState;
  late final WindowState windowState;
  late final FirewallState firewallState;
  late final VpnState vpnState;
  late final AppSettingsState appSettingsState;
  late final ServerStatusState serverStatusState;

  // ========== 数据访问 ==========
  late final AppDatabase db;
  late final ThemeRepository _themeRepository;
  late final NetworkConfigRepository _networkConfigRepository;
  late final AppSettingsRepository _appSettingsRepository;

  /// 魔法墙 DAO（含 [MagicWallDaoApi] 便捷方法）
  MagicWallDao get magicWall => db.magicWall;

  // ========== Domain services ==========
  late final ThemeService theme;
  late final RoomService room;
  late final ServerService server;
  late final NetworkConfigService networkConfig;
  late final AppSettingsService appSettings;
  late final FirewallService firewall;

  // ========== Runtime singletons ==========
  ServerConnectionManager get connection => ServerConnectionManager.instance;
  VpnManager get vpn => VpnManager.instance;
  NotificationService get notifications => NotificationService.instance;
  WidgetService get widgets => WidgetService.instance;

  void _initializeStates() {
    themeState = ThemeState();
    uiState = UIState();
    roomState = RoomState();
    serverState = ServerState();
    networkConfigState = NetworkConfigState();
    playerState = PlayerState();
    displayState = DisplayState();
    startupState = StartupState();
    updateState = UpdateState();
    connectionState = ConnectionState();
    windowState = WindowState();
    firewallState = FirewallState();
    vpnState = VpnState();
    appSettingsState = AppSettingsState();
    serverStatusState = ServerStatusState();
  }

  void _initializeData() {
    db = AppDatabase();
    _themeRepository = ThemeRepository(db);
    _networkConfigRepository = NetworkConfigRepository(db);
    _appSettingsRepository = AppSettingsRepository(db);
  }

  void _initializeServices() {
    theme = ThemeService(themeState, _themeRepository);
    room = RoomService(roomState, db);
    server = ServerService(serverState, db);
    networkConfig = NetworkConfigService(
      networkConfigState,
      _networkConfigRepository,
    );
    firewall = FirewallService(firewallState);

    appSettings = AppSettingsService(
      playerState: playerState,
      displayState: displayState,
      startupState: startupState,
      updateState: updateState,
      windowState: windowState,
      vpnState: vpnState,
      appSettingsState: appSettingsState,
      repository: _appSettingsRepository,
    );
  }

  Future<void> init() async {
    if (_initialized) return;
    final results = await Future.wait([
      _initService('Theme', () => theme.init()),
      _initService('Room', () => room.init()),
      _initService('Server', () => server.init()),
      _initService('NetworkConfig', () => networkConfig.init()),
      _initService('AppSettings', () => appSettings.init()),
      _initService('Firewall', () => firewall.init()),
    ]);

    final failedServices = results.where((r) => !r).length;
    if (failedServices > 0) {
      debugPrint('警告: $failedServices 个服务初始化失败，但应用将继续运行');
    }

    if (Platform.isAndroid) {
      await vpn.initAndroidHooks();
    }

    await ConnectionConnectGuard.tryStartupAutoConnect();

    _initialized = true;
  }

  Future<bool> _initService(String name, Future<void> Function() init) async {
    try {
      await init();
      return true;
    } catch (e, stack) {
      debugPrint('$name 服务初始化失败: $e');
      debugPrint('堆栈: $stack');
      return false;
    }
  }

  void reset() {
    _instance = null;
  }
}
