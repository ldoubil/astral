import 'package:astral/core/database/app_data.dart';
import 'package:flutter/foundation.dart';

// Export CoState for external use
export 'package:astral/core/states/connection_state.dart' show CoState;

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
import 'package:astral/core/states/notification_state.dart';
import 'package:astral/core/states/window_state.dart';
import 'package:astral/core/states/firewall_state.dart';
import 'package:astral/core/states/vpn_state.dart';
import 'package:astral/core/states/app_settings_state.dart';

// Repositories
import 'package:astral/core/repositories/theme_repository.dart';
import 'package:astral/core/repositories/room_repository.dart';
import 'package:astral/core/repositories/server_repository.dart';
import 'package:astral/core/repositories/network_config_repository.dart';
import 'package:astral/core/repositories/app_settings_repository.dart';
import 'package:astral/core/repositories/connection_repository.dart';

// Services
import 'package:astral/core/services/theme_service.dart';
import 'package:astral/core/services/room_service.dart';
import 'package:astral/core/services/server_service.dart';
import 'package:astral/core/services/network_config_service.dart';
import 'package:astral/core/services/app_settings_service.dart';
import 'package:astral/core/services/connection_service.dart';
import 'package:astral/core/services/firewall_service.dart';

/// 服务管理器：统一管理所有服务的单例
///
/// 这是新架构的入口点，替代原来的Aps单例
/// 使用方式：
/// ```dart
/// final services = ServiceManager();
/// await services.init();
///
/// // 访问服务
/// services.theme.updateThemeColor(Colors.blue);
/// services.room.addRoom(room);
/// ```
class ServiceManager {
  static ServiceManager? _instance;
  static ServiceManager get instance {
    _instance ??= ServiceManager._internal();
    return _instance!;
  }

  factory ServiceManager() => instance;

  ServiceManager._internal() {
    _initializeStates();
    _initializeRepositories();
    _initializeServices();
  }

  // ========== States（14个） ==========
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
  late final NotificationState notificationState;
  late final WindowState windowState;
  late final FirewallState firewallState;
  late final VpnState vpnState;
  late final AppSettingsState appSettingsState;

  // ========== Repositories（6个） ==========
  late final ThemeRepository _themeRepository;
  late final RoomRepository _roomRepository;
  late final ServerRepository _serverRepository;
  late final NetworkConfigRepository _networkConfigRepository;
  late final AppSettingsRepository _appSettingsRepository;
  late final ConnectionRepository _connectionRepository;

  // ========== Services（7个公共服务） ==========
  late final ThemeService theme;
  late final RoomService room;
  late final ServerService server;
  late final NetworkConfigService networkConfig;
  late final AppSettingsService appSettings;
  late final ConnectionService connection;
  late final FirewallService firewall;

  // ========== 初始化方法 ==========

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
    notificationState = NotificationState();
    windowState = WindowState();
    firewallState = FirewallState();
    vpnState = VpnState();
    appSettingsState = AppSettingsState();
  }

  void _initializeRepositories() {
    final db = AppDatabase();
    _themeRepository = ThemeRepository(db);
    _roomRepository = RoomRepository(db);
    _serverRepository = ServerRepository(db);
    _networkConfigRepository = NetworkConfigRepository(db);
    _appSettingsRepository = AppSettingsRepository(db);
    _connectionRepository = ConnectionRepository(db);
  }

  void _initializeServices() {
    theme = ThemeService(themeState, _themeRepository);
    room = RoomService(roomState, _roomRepository);
    server = ServerService(serverState, _serverRepository);
    networkConfig = NetworkConfigService(
      networkConfigState,
      _networkConfigRepository,
    );
    connection = ConnectionService(connectionState, _connectionRepository);
    firewall = FirewallService(firewallState);

    appSettings = AppSettingsService(
      playerState: playerState,
      displayState: displayState,
      startupState: startupState,
      updateState: updateState,
      notificationState: notificationState,
      windowState: windowState,
      vpnState: vpnState,
      firewallState: firewallState,
      appSettingsState: appSettingsState,
      repository: _appSettingsRepository,
    );
  }

  /// 初始化所有服务（从数据库加载数据）
  Future<void> init() async {
    // 使用 Future.wait 并发初始化所有服务
    // 但即使某些服务失败，也要继续初始化其他服务
    final results = await Future.wait([
      _initService('Theme', () => theme.init()),
      _initService('Room', () => room.init()),
      _initService('Server', () => server.init()),
      _initService('NetworkConfig', () => networkConfig.init()),
      _initService('AppSettings', () => appSettings.init()),
      _initService('Connection', () => connection.init()),
      _initService('Firewall', () => firewall.init()),
    ]);

    final failedServices = results.where((r) => !r).length;
    if (failedServices > 0) {
      debugPrint('警告: $failedServices 个服务初始化失败，但应用将继续运行');
    }
  }

  /// 安全地初始化单个服务
  Future<bool> _initService(String name, Future<void> Function() init) async {
    try {
      await init();
      debugPrint('$name 服务初始化成功');
      return true;
    } catch (e, stack) {
      debugPrint('$name 服务初始化失败: $e');
      debugPrint('堆栈: $stack');
      return false;
    }
  }

  /// 重置所有服务（用于测试或登出）
  void reset() {
    _instance = null;
  }
}
