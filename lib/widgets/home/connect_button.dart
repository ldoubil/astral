import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:astral/state/app_state.dart';
import 'package:astral/state/child/base_state.dart';
import 'package:astral/state/child/base_net_node_state.dart';
import 'package:astral/src/rust/api/hops.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:vpn_service_plugin/vpn_service_plugin.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ConnectButton extends StatefulWidget {
  const ConnectButton({super.key});

  @override
  State<ConnectButton> createState() => _ConnectButtonState();
}

class _ConnectButtonState extends State<ConnectButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _progress = 0.0;
  // 仅在安卓平台初始化VPN插件
  final vpnPlugin = Platform.isAndroid ? VpnServicePlugin() : null;
  // 在类中添加这些变量
  Timer? _connectionTimer;
  Timer? _timeoutTimer;
  int _connectionDuration = 0; // 连接持续时间（秒）

  // 添加通知插件（仅安卓平台）
  final FlutterLocalNotificationsPlugin? _notificationsPlugin =
      Platform.isAndroid ? FlutterLocalNotificationsPlugin() : null;
  static const int _notificationId = 1001;

  // 添加超时时间常量
  static const int connectionTimeoutSeconds = 15;

  // 辅助方法：验证IPv4地址格式
  bool _isValidIpAddress(String ip) {
    if (ip.isEmpty) return false;
    // 更严格的IPv4正则表达式，检查每个部分的范围0-255
    final RegExp ipRegex = RegExp(
      r"^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",
    );
    if (!ipRegex.hasMatch(ip)) {
      return false;
    }
    // 避免一些明显无效的IP，例如全0或全255（尽管 "0.0.0.0" 已单独检查）
    if (ip == "0.0.0.0" || ip == "255.255.255.255") {
      return false; // "0.0.0.0" 通常表示未指定或无效
    }
    return true;
  }

  void _startVpn({
    required String ipv4Addr,
    int mtu = 1300,
    List<String> disallowedApplications = const ['com.kevin.astral'],
  }) {
    if (ipv4Addr.isNotEmpty & (ipv4Addr != "")) {
      // 确保IP地址格式为"IP/掩码"
      if (!ipv4Addr.contains('/')) {
        ipv4Addr = "$ipv4Addr/24";
      }

      vpnPlugin?.startVpn(
        ipv4Addr: ipv4Addr,
        mtu: mtu,
        routes:
            AppState().baseState.customVpn.value
                .where((route) => _isValidCIDR(route))
                .toList(),
        disallowedApplications: disallowedApplications,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    if (Platform.isAndroid) {
      // 初始化通知
      _initializeNotifications();

      // 监听VPN服务启动事件
      vpnPlugin?.onVpnServiceStarted.listen((data) {
        setTunFd(fd: data['fd']);
        // 在这里处理VPN启动后的逻辑
      });
      // 监听VPN服务停止事件
      vpnPlugin?.onVpnServiceStopped.listen((data) {
        // 在这里处理VPN停止后的逻辑
      });
    }

    // 添加自动连接逻辑
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (AppState().startupState.startupAutoConnect.watch(context)) {
        _startConnection();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timeoutTimer?.cancel(); // 组件销毁时也要取消
    _connectionTimer?.cancel();
    if (Platform.isAndroid) {
      _cancelNotification();
    }
    super.dispose();
  }

  // 初始化通知
  Future<void> _initializeNotifications() async {
    if (_notificationsPlugin == null) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  // 显示或更新连接状态通知
  Future<void> _showConnectionNotification({
    required String status,
    required String ip,
    required String duration,
  }) async {
    if (_notificationsPlugin == null) return;

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'astral_connection',
          LocaleKeys.notification_connection_status.tr(),
          channelDescription: LocaleKeys.notification_connection_desc.tr(),
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          showWhen: false,
          icon: '@mipmap/ic_launcher',
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _notificationsPlugin!.show(
      _notificationId,
      '${LocaleKeys.app_name.tr()} VPN - $status',
      '${LocaleKeys.ip_label.tr()}: $ip | ${LocaleKeys.connection_time.tr()}: $duration',
      notificationDetails,
    );
  }

  // 取消通知
  Future<void> _cancelNotification() async {
    if (_notificationsPlugin == null) return;
    await _notificationsPlugin!.cancel(_notificationId);
  }

  // 格式化连接时间
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  /// 开始连接流程的方法
  /// 该方法负责将按钮状态从空闲(idle)切换到连接中(connecting)，
  /// 然后模拟一个10秒的网络连接过程，最后切换到已连接(connected)状态
  Future<void> _startConnection() async {
    // 如果当前状态不是空闲状态，则直接返回，防止重复触发连接操作
    if (AppState().baseState.Connec_state.value != CoState.idle) return;

    // final rom = AppState().baseState.selectroom.value;
    // if (rom == null) return;

    // 检查服务器列表是否为空
    // final enabledServers =
        // AppState().baseState.servers.value.where((server) => server.enable).toList();
         final enabledServers =[];
    if (enabledServers.isEmpty) {
      // 显示提示信息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.add_server_first.tr()),
            action: SnackBarAction(
              label: LocaleKeys.go_add.tr(),
              onPressed: () {
                // 跳转到服务器页面（索引为2）
                AppState().baseState.selectedIndex.set(2);
              },
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    try {
      // 初始化服务器
      // await _initializeServer(rom);

      // 开始连接流程
      await _beginConnectionProcess();
    } catch (e) {
      // 发生错误时重置状态
      AppState().baseState.Connec_state.value = CoState.idle; 
      rethrow;
    }
  }

  Future<void> _initializeServer(dynamic rom) async {
    final aps = AppState().baseState;
    if (Platform.isAndroid) {
      vpnPlugin?.prepareVpn();
    }

    String currentIp = AppState().baseNetNodeState.netNode.value.ipv4;
    bool forceDhcp = false;
    String ipForServer = ""; // 默认为空，如果强制DHCP

    if (currentIp.isEmpty ||
        currentIp == "0.0.0.0" ||
        !_isValidIpAddress(currentIp)) {
      forceDhcp = true;
    } else {
      // IP有效且不是 "0.0.0.0"
      ipForServer = currentIp;
    }
    List<Forward> forwards = [];
    // for (var conn in aps.connections.value) {
    //   if (conn.enabled) {
    //     for (var conn in conn.connections) {
    //       // 根据协议类型添加转发规则
    //       if (conn.proto == 'all') {
    //         // ALL协议时添加TCP和UDP两条规则
    //         forwards.add(
    //           Forward(
    //             bindAddr: conn.bindAddr,
    //             dstAddr: conn.dstAddr,
    //             proto: 'tcp',
    //           ),
    //         );
    //         forwards.add(
    //           Forward(
    //             bindAddr: conn.bindAddr,
    //             dstAddr: conn.dstAddr,
    //             proto: 'udp',
    //           ),
    //         );
    //       } else {
    //         // TCP或UDP时只添加对应协议的规则
    //         forwards.add(
    //           Forward(
    //             bindAddr: conn.bindAddr,
    //             dstAddr: conn.dstAddr,
    //             proto: conn.proto,
    //           ),
    //         );
    //       }
    //     }
    //   }
    // }
    await createServer(
      username: aps.PlayerName.value,
      enableDhcp: forceDhcp ? true : AppState().baseNetNodeState.netNode.value.dhcp,
      specifiedIp: forceDhcp ? "" : ipForServer, // 如果强制DHCP，则指定IP为空
      roomName: rom.roomName,
      roomPassword: rom.password,
      cidrs: AppState().baseNetNodeState.netNode.value.cidrproxy,
      forwards: forwards,
      severurl:[],
      onurl:
          AppState().baseState.listenListPersistent.value.where((url) => !url.contains('[::]')).toList(),
      flag: _buildFlags(aps),
    );
  }

  FlagsC _buildFlags(BaseState aps) {
    final netNode = AppState().baseNetNodeState.netNode.value;
    return FlagsC(
      defaultProtocol: netNode.default_protocol,
      devName: netNode.dev_name,
      enableEncryption: netNode.enable_encryption,
      enableIpv6: true,
      mtu: netNode.enable_encryption ? 1360 : 1380,
      multiThread: netNode.multi_thread,
      latencyFirst: netNode.latency_first,
      enableExitNode: true,
      noTun: netNode.no_tun,
      useSmoltcp: netNode.use_smoltcp,
      // relayNetworkWhitelist: netNode.relay_network_whitelist,
      relayNetworkWhitelist: '*',
      disableP2P: netNode.disable_p2p,
      relayAllPeerRpc: netNode.relay_all_peer_rpc,
      disableUdpHolePunching: netNode.disable_udp_hole_punching,
      dataCompressAlgo: netNode.data_compress_algo,
      bindDevice: netNode.bind_device,
      enableKcpProxy: netNode.enable_kcp_proxy,
      disableKcpInput: netNode.disable_kcp_input,
      disableRelayKcp: netNode.disable_relay_kcp,
      proxyForwardBySystem: true,
      acceptDns: netNode.accept_dns,
      privateMode: netNode.private_mode,
      enableQuicProxy: netNode.enable_quic_proxy,
      disableQuicInput: netNode.disable_quic_input,
    );
  }

  Future<void> _beginConnectionProcess() async {
    AppState().baseState.Connec_state.value = CoState.connecting;
    setState(() {
      _progress = 0.0;
    });

    // 在安卓平台显示连接中通知
    if (Platform.isAndroid) {
      await _showConnectionNotification(
        status: LocaleKeys.status_connecting.tr(),
        ip: LocaleKeys.status_getting_ip.tr(),
        duration: '00:00',
      );
    }

    // 设置连接超时
    _setupConnectionTimeout();

    // 启动连接状态检查
    _startConnectionStatusCheck();
  }

  void _setupConnectionTimeout() {
    _timeoutTimer = Timer(Duration(seconds: connectionTimeoutSeconds), () {
      if (AppState().baseState.Connec_state.value == CoState.connecting) {
        debugPrint(LocaleKeys.connection_timeout.tr());
        if (Platform.isAndroid) {
          _cancelNotification();
        }
        _disconnect();
      }
    });
  }

  void _startConnectionStatusCheck() {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (AppState().baseState.Connec_state.value != CoState.connecting) {
        timer.cancel();
        return;
      }

      final isConnected = await _checkAndUpdateConnectionStatus();
      if (isConnected) {
        timer.cancel();
        await _handleSuccessfulConnection();
      } else {
        setState(() => _progress += 100 / connectionTimeoutSeconds); // 修改进度计算方式
      }
    });
  }

  Future<bool> _checkAndUpdateConnectionStatus() async {
    final runningInfo = await getRunningInfo();
    final data = jsonDecode(runningInfo);

    final ipv4Address = _extractIpv4Address(data);
    if (ipv4Address != "0.0.0.0" && AppState().baseNetNodeState.netNode.value.ipv4 != ipv4Address) {
      // 更新NetNode中的ipv4地址
      AppState().baseNetNodeState.netNode.value.ipv4 = ipv4Address;
    }
    return ipv4Address != "0.0.0.0";
  }

  String _extractIpv4Address(Map<String, dynamic> data) {
    final virtualIpv4 = data['my_node_info']?['virtual_ipv4'];
    final addr =
        virtualIpv4?.isEmpty ?? true ? 0 : virtualIpv4['address']['addr'] ?? 0;
    return intToIp(addr);
  }

  Future<void> _handleSuccessfulConnection() async {
    // 连接成功时取消超时定时器
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    setState(() {
      _progress = 100;
      _connectionDuration = 0;
    });
    AppState().baseState.Connec_state.value = CoState.connected;
    AppState().baseState.isConnecting.value = true;
    if (Platform.isAndroid) {
      _startVpn(ipv4Addr: AppState().baseNetNodeState.netNode.value.ipv4, mtu: AppState().baseNetNodeState.netNode.value.mtu);
      // 显示连接成功通知
      await _showConnectionNotification(
        status: LocaleKeys.status_connected.tr(),
        ip: AppState().baseNetNodeState.netNode.value.ipv4.isNotEmpty ? AppState().baseNetNodeState.netNode.value.ipv4 : LocaleKeys.status_getting_ip.tr(),
        duration: _formatDuration(_connectionDuration),
      );
    }
    if (Platform.isWindows) {
        setInterfaceMetric(interfaceName: "astral", metric: 0);
    }
    _startNetworkMonitoring();
  }

  void _startNetworkMonitoring() {
    _connectionTimer?.cancel();
    _connectionTimer = Timer.periodic(
      const Duration(seconds: 1),
      _monitorNetworkStatus,
    );
  }

  Future<void> _monitorNetworkStatus(Timer timer) async {
    if (!mounted) {
      timer.cancel();
      return;
    }

    setState(() => _connectionDuration++);

    try {
      final runningInfo = await getRunningInfo();
      final data = jsonDecode(runningInfo);

      // AppState().baseState.updateIpv4(_extractIpv4Address(data));
      AppState().baseState.netStatus.value = await getNetworkStatus();

      // 在安卓平台更新通知
      if (Platform.isAndroid && AppState().baseState.Connec_state.value == CoState.connected) {
        await _showConnectionNotification(
          status: LocaleKeys.status_connected.tr(),
          ip: AppState().baseNetNodeState.netNode.value.ipv4.isNotEmpty ? AppState().baseNetNodeState.netNode.value.ipv4 : LocaleKeys.status_getting_ip.tr(),
          duration: _formatDuration(_connectionDuration),
        );
      }
    } catch (e) {
      // 监控过程中出现错误时保持连接状态，但记录错误
      debugPrint('Network monitoring error: $e');
    }
  }

  /// 断开连接的方法
  /// 该方法负责将按钮状态从已连接(connected)切换回空闲(idle)状态，
  /// 实现断开连接的功能
  void _disconnect() {
    AppState().baseState.isConnecting.value = false;
    if (Platform.isAndroid) {
      vpnPlugin?.stopVpn();
      // 取消通知
      _cancelNotification();
    }
    // 取消计时器
    _connectionTimer?.cancel();
    _connectionTimer = null;
    closeServer();
    AppState().baseState.Connec_state.value = CoState.idle;
  }

  /// 切换连接状态的方法
  /// 根据当前的连接状态来决定是开始连接还是断开连接
  void _toggleConnection() {
    if (AppState().baseState.Connec_state.value == CoState.idle) {
      // 如果当前是空闲状态，则开始连接
      _startConnection();
    } else if (AppState().baseState.Connec_state.value == CoState.connected) {
      // 如果当前是已连接状态，则断开连接
      debugPrint("断开连接");
      _disconnect();
    }
  }

  Widget _getButtonIcon(CoState state) {
    switch (state) {
      case CoState.idle:
        return Icon(
          Icons.power_settings_new_rounded,
          key: const ValueKey('idle_icon'),
        );
      case CoState.connecting:
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animationController.value * 2 * pi,
              child: const Icon(
                Icons.sync_rounded,
                key: ValueKey('connecting_icon'),
              ),
            );
          },
        );
      case CoState.connected:
        return Icon(Icons.link_rounded, key: const ValueKey('connected_icon'));
    }
  }

  Widget _getButtonLabel(CoState state) {
    final String text;
    switch (state) {
      case CoState.idle:
        text = LocaleKeys.connect.tr();
      case CoState.connecting:
        text = LocaleKeys.connecting.tr();
      case CoState.connected:
        text = LocaleKeys.connected.tr();
    }

    return Text(
      text,
      key: ValueKey('label_$state'),
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
    );
  }

  Color _getButtonColor(CoState state, ColorScheme colorScheme) {
    switch (state) {
      case CoState.idle:
        return colorScheme.primary;
      case CoState.connecting:
        return colorScheme.surfaceVariant;
      case CoState.connected:
        return colorScheme.tertiary;
    }
  }

  Color _getButtonForegroundColor(CoState state, ColorScheme colorScheme) {
    switch (state) {
      case CoState.idle:
        return colorScheme.onPrimary;
      case CoState.connecting:
        return colorScheme.onSurfaceVariant;
      case CoState.connected:
        return colorScheme.onTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: 14, // 固定高度，包含进度条高度(6px)和底部边距(8px)
            width: 180, // 固定宽度与按钮一致
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset:
                  AppState().baseState.Connec_state.watch(context) == CoState.connecting
                      ? Offset.zero
                      : const Offset(0, 1.0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity:
                    AppState().baseState.Connec_state.watch(context) == CoState.connecting
                        ? 1.0
                        : 0.0,
                child: Container(
                  width: 180,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey(
                      'progress_${AppState().baseState.Connec_state.watch(context) == CoState.connecting}',
                    ),
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: Duration(
                      seconds: connectionTimeoutSeconds,
                    ), // 使用变量控制动画时间
                    curve: Curves.easeInOut,
                    builder: (context, value, _) {
                      // 更新进度值
                      _progress = value * 100;
                      return FractionallySizedBox(
                        widthFactor: value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.tertiary,
                                colorScheme.primary,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // 按钮
          Align(
            alignment: Alignment.centerRight,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width:
                  AppState().baseState.Connec_state.watch(context) != CoState.idle ? 180 : 100,
              height: 60,
              child: FloatingActionButton.extended(
                onPressed:
                    AppState().baseState.Connec_state.watch(context) == CoState.connecting
                        ? null
                        : _toggleConnection,
                heroTag: "connect_button",
                extendedPadding: const EdgeInsets.symmetric(horizontal: 2),
                splashColor:
                    AppState().baseState.Connec_state.watch(context) != CoState.idle
                        ? colorScheme.onTertiary.withAlpha(51)
                        : colorScheme.onPrimary.withAlpha(51),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                  ) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: _getButtonIcon(AppState().baseState.Connec_state.watch(context)),
                ),
                label: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOutQuad,
                  switchOutCurve: Curves.easeInQuad,
                  child: _getButtonLabel(AppState().baseState.Connec_state.watch(context)),
                ),
                backgroundColor: _getButtonColor(
                  AppState().baseState.Connec_state.watch(context),
                  colorScheme,
                ),
                foregroundColor: _getButtonForegroundColor(
                  AppState().baseState.Connec_state.watch(context),
                  colorScheme,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 整数转为 IP 字符串
String intToIp(int ipInt) {
  return [
    (ipInt >> 24) & 0xFF,
    (ipInt >> 16) & 0xFF,
    (ipInt >> 8) & 0xFF,
    ipInt & 0xFF,
  ].join('.');
}

// 新增CIDR验证方法
bool _isValidCIDR(String cidr) {
  final cidrPattern = RegExp(
    r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/(3[0-2]|[12]?[0-9])$',
  );

  if (!cidrPattern.hasMatch(cidr)) {
    debugPrint('⚠️ 无效路由条目已过滤: $cidr');
    return false;
  }

  // 额外验证网络地址有效性
  final parts = cidr.split('/');
  final ip = parts[0];
  final mask = int.parse(parts[1]);

  return _isValidIpAddress(ip) && mask >= 0 && mask <= 32;
}

bool _isValidIpAddress(String ip) {
  if (ip.isEmpty) return false;

  // 严格的正则表达式验证（每个数字段 0-255）
  final RegExp ipRegex = RegExp(
    r"^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",
  );

  // 排除特殊保留地址（可扩展）
  if (!ipRegex.hasMatch(ip) ||
      ip == "0.0.0.0" ||
      ip == "255.255.255.255" ||
      ip.startsWith("127.")) {
    return false;
  }
  return true;
}
