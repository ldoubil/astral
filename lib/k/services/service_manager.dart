import 'package:astral/k/database/app_data.dart';

// Export CoState for external use
export 'package:astral/k/states/connection_state.dart' show CoState;

// States
import 'package:astral/k/states/theme_state.dart';
import 'package:astral/k/states/ui_state.dart';
import 'package:astral/k/states/room_state.dart';
import 'package:astral/k/states/server_state.dart';
import 'package:astral/k/states/network_config_state.dart';
import 'package:astral/k/states/player_state.dart';
import 'package:astral/k/states/display_state.dart';
import 'package:astral/k/states/startup_state.dart';
import 'package:astral/k/states/update_state.dart';
import 'package:astral/k/states/connection_state.dart';
import 'package:astral/k/states/notification_state.dart';
import 'package:astral/k/states/window_state.dart';
import 'package:astral/k/states/firewall_state.dart';
import 'package:astral/k/states/vpn_state.dart';
import 'package:astral/k/states/app_settings_state.dart';

// Repositories
import 'package:astral/k/repositories/theme_repository.dart';
import 'package:astral/k/repositories/room_repository.dart';
import 'package:astral/k/repositories/server_repository.dart';
import 'package:astral/k/repositories/network_config_repository.dart';
import 'package:astral/k/repositories/app_settings_repository.dart';
import 'package:astral/k/repositories/connection_repository.dart';

// Services
import 'package:astral/k/services/theme_service.dart';
import 'package:astral/k/services/room_service.dart';
import 'package:astral/k/services/server_service.dart';
import 'package:astral/k/services/network_config_service.dart';
import 'package:astral/k/services/app_settings_service.dart';
import 'package:astral/k/services/connection_service.dart';
import 'package:astral/k/services/firewall_service.dart';

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
      repository: _appSettingsRepository,
    );
  }

  /// 初始化所有服务（从数据库加载数据）
  Future<void> init() async {
    await Future.wait([
      theme.init(),
      room.init(),
      server.init(),
      networkConfig.init(),
      appSettings.init(),
      connection.init(),
      firewall.init(),
    ]);
  }

  /// 重置所有服务（用于测试或登出）
  void reset() {
    _instance = null;
  }
}
