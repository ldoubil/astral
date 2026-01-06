import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:astral/core/builders/server_config_builder.dart';
import 'package:astral/core/models/network_config_share.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/services/notification_service.dart';
import 'package:astral/core/services/vpn_manager.dart';
import 'package:astral/shared/utils/network/ip_utils.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:astral/src/rust/api/hops.dart';
import 'package:flutter/foundation.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:isar_community/isar.dart';

/// 服务器连接管理器
///
/// 负责管理服务器连接、断开、状态监控等核心功能
class ServerConnectionManager {
  static ServerConnectionManager? _instance;

  Timer? _statusCheckTimer;
  Timer? _networkMonitorTimer;
  Timer? _timeoutTimer;
  int _connectionDuration = 0;

  static const int connectionTimeoutSeconds = 15;

  ServerConnectionManager._();

  /// 获取单例实例
  static ServerConnectionManager get instance {
    _instance ??= ServerConnectionManager._();
    return _instance!;
  }

  /// 获取连接时长
  int get connectionDuration => _connectionDuration;

  /// 开始连接流程
  Future<bool> connect() async {
    final services = ServiceManager();

    // 检查状态
    if (services.connectionState.connectionState.value != CoState.idle) {
      return false;
    }

    final room = services.roomState.selectedRoom.value;
    if (room == null) return false;

    // 清理旧连接
    await closeServer();

    // 检查服务器配置
    final enabledServers =
        services.serverState.servers.value
            .where((server) => server.enable)
            .toList();
    final hasRoomServers = room.servers.isNotEmpty;

    if (enabledServers.isEmpty && !hasRoomServers) {
      debugPrint('⚠️ 没有可用的服务器');
      return false;
    }

    try {
      // 准备VPN（Android）
      if (Platform.isAndroid) {
        await VpnManager.instance.prepare();
      }

      // 初始化服务器
      await _initializeServer(room);

      // 开始连接流程
      await _beginConnectionProcess();

      return true;
    } catch (e) {
      debugPrint('❌ 连接失败: $e');
      batch(() {
        services.connectionState.connectionState.value = CoState.idle;
      });
      return false;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    final services = ServiceManager();

    batch(() {
      services.connectionState.isConnecting.value = false;
    });

    // 停止VPN
    if (Platform.isAndroid) {
      await VpnManager.instance.stop();
      await NotificationService.instance.cancelConnectionNotification();
    }

    // 取消定时器
    _statusCheckTimer?.cancel();
    _networkMonitorTimer?.cancel();
    _timeoutTimer?.cancel();
    _statusCheckTimer = null;
    _networkMonitorTimer = null;
    _timeoutTimer = null;

    // 关闭服务器
    await closeServer();

    batch(() {
      services.connectionState.connectionState.value = CoState.idle;
      services.serverStatusState.setActiveServers({});
    });
  }

  /// 初始化服务器配置
  Future<void> _initializeServer(dynamic room) async {
    final services = ServiceManager();

    // 解析房间配置（临时覆盖）
    NetworkConfigShare? roomConfig;
    if (room.networkConfigJson.isNotEmpty) {
      try {
        roomConfig = NetworkConfigShare.fromJsonString(room.networkConfigJson);
        debugPrint('🔧 检测到房间配置，将临时覆盖默认设置');
      } catch (e) {
        debugPrint('⚠️ 解析房间配置失败: $e');
      }
    }

    // 使用Builder构建配置
    final config =
        ServerConfigBuilder(services)
            .withPlayerInfo()
            .withRoom(room)
            .withRoomConfig(roomConfig)
            .withServers(room, services.serverState.servers.value)
            .withListeners(services.playerState.listenList.value)
            .withCidrs(services.vpnState.customVpn.value)
            .withForwards(services.firewallState.connections.value)
            .withFlags()
            .build();

    // 调用Rust API创建服务器
    await createServer(
      username: config.username,
      enableDhcp: config.enableDhcp,
      specifiedIp: config.specifiedIp,
      roomName: config.roomName,
      roomPassword: config.roomPassword,
      severurl: config.severurl,
      onurl: config.onurl,
      cidrs: config.cidrs,
      forwards: config.forwards,
      flag: config.flag,
    );
  }

  /// 开始连接流程
  Future<void> _beginConnectionProcess() async {
    batch(() {
      ServiceManager().connectionState.connectionState.value =
          CoState.connecting;
    });

    // 显示通知（Android）
    if (Platform.isAndroid) {
      await NotificationService.instance.showConnectionNotification(
        status: '连接中',
        ip: '正在获取...',
        duration: '00:00',
      );
    }

    // 设置超时
    _setupConnectionTimeout();

    // 启动状态检查
    _startConnectionStatusCheck();
  }

  /// 设置连接超时
  void _setupConnectionTimeout() {
    _timeoutTimer = Timer(Duration(seconds: connectionTimeoutSeconds), () {
      if (ServiceManager().connectionState.connectionState.value ==
          CoState.connecting) {
        debugPrint('⏱️ 连接超时');
        disconnect();
      }
    });
  }

  /// 启动连接状态检查
  void _startConnectionStatusCheck() {
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) async {
      if (ServiceManager().connectionState.connectionState.value !=
          CoState.connecting) {
        timer.cancel();
        return;
      }

      final isConnected = await _checkConnectionStatus();
      if (isConnected) {
        timer.cancel();
        await _handleSuccessfulConnection();
      }
    });
  }

  /// 检查连接状态
  Future<bool> _checkConnectionStatus() async {
    try {
      final runningInfo = await getRunningInfo();
      if (runningInfo.isEmpty) return false;

      final data = jsonDecode(runningInfo);
      if (data == null || data is! Map<String, dynamic>) return false;

      final ipv4Address = _extractIpv4Address(data);
      if (ipv4Address != "0.0.0.0" &&
          ServiceManager().networkConfigState.ipv4.value != ipv4Address) {
        ServiceManager().networkConfig.updateIpv4(ipv4Address);
      }

      return ipv4Address != "0.0.0.0";
    } catch (e) {
      return false;
    }
  }

  /// 处理连接成功
  Future<void> _handleSuccessfulConnection() async {
    // 取消超时定时器
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _connectionDuration = 0;

    batch(() {
      ServiceManager().connectionState.connectionState.value =
          CoState.connected;
      ServiceManager().connectionState.isConnecting.value = true;
      _markActiveServers();
    });

    // 启动VPN（Android）
    if (Platform.isAndroid) {
      await VpnManager.instance.start(
        ipv4Addr: ServiceManager().networkConfigState.ipv4.value,
        mtu: ServiceManager().networkConfigState.mtu.value,
      );

      await NotificationService.instance.showConnectionNotification(
        status: '已连接',
        ip:
            ServiceManager().networkConfigState.ipv4.value.isNotEmpty
                ? ServiceManager().networkConfigState.ipv4.value
                : '获取中...',
        duration: NotificationService.formatDuration(_connectionDuration),
      );
    }

    // 设置网卡跃点（Windows）
    if (Platform.isWindows) {
      setInterfaceMetric(interfaceName: "astral", metric: 0);
    }

    // 启动网络监控
    _startNetworkMonitoring();
  }

  /// 启动网络监控
  void _startNetworkMonitoring() {
    _networkMonitorTimer?.cancel();
    _networkMonitorTimer = Timer.periodic(
      const Duration(seconds: 1),
      _monitorNetworkStatus,
    );
  }

  /// 监控网络状态
  Future<void> _monitorNetworkStatus(Timer timer) async {
    _connectionDuration++;

    try {
      final runningInfo = await getRunningInfo();
      final data = jsonDecode(runningInfo);

      ServiceManager().networkConfig.updateIpv4(_extractIpv4Address(data));
      final netStatus = await getNetworkStatus();

      batch(() {
        ServiceManager().connectionState.netStatus.value = netStatus;
      });

      // 更新通知（Android）
      if (Platform.isAndroid &&
          ServiceManager().connectionState.connectionState.value ==
              CoState.connected) {
        await NotificationService.instance.showConnectionNotification(
          status: '已连接',
          ip:
              ServiceManager().networkConfigState.ipv4.value.isNotEmpty
                  ? ServiceManager().networkConfigState.ipv4.value
                  : '获取中...',
          duration: NotificationService.formatDuration(_connectionDuration),
        );
      }
    } catch (e) {
      // 忽略监控错误
    }
  }

  /// 提取IPv4地址
  String _extractIpv4Address(Map<String, dynamic> data) {
    final virtualIpv4 = data['my_node_info']?['virtual_ipv4'];
    final addr =
        virtualIpv4?.isEmpty ?? true ? 0 : virtualIpv4['address']['addr'] ?? 0;
    return intToIp(addr);
  }

  /// 标记活跃服务器
  void _markActiveServers() {
    final room = ServiceManager().roomState.selectedRoom.value;
    if (room == null) return;

    final activeIds = <Id>{};
    final enabledServers =
        ServiceManager().serverState.servers.value
            .where((server) => server.enable)
            .toList();

    for (var server in enabledServers) {
      activeIds.add(server.id);
    }

    ServiceManager().serverStatusState.setActiveServers(activeIds);
  }

  /// 清理资源
  void dispose() {
    _statusCheckTimer?.cancel();
    _networkMonitorTimer?.cancel();
    _timeoutTimer?.cancel();
  }
}
