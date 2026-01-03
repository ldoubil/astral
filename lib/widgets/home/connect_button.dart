import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:astral/utils/net_astral_udp.dart';
import 'package:astral/k/services/service_manager.dart';
import 'package:astral/src/rust/api/firewall.dart';
import 'package:astral/src/rust/api/hops.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:flutter/material.dart';
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
            ServiceManager().vpnState.customVpn.value
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
      if (ServiceManager().startupState.startupAutoConnect.value) {
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

    await _notificationsPlugin!.initialize(initializationSettings);
  }

  // 显示或更新连接状态通知
  Future<void> _showConnectionNotification({
    required String status,
    required String ip,
    required String duration,
  }) async {
    if (_notificationsPlugin == null) return;

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'astral_connection',
          'Astral 连接状态',
          channelDescription: '显示 Astral VPN 连接状态和信息',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          showWhen: false,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _notificationsPlugin!.show(
      _notificationId,
      'Astral VPN - $status',
      'IP: $ip | 连接时间: $duration',
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
    if (ServiceManager().connectionState.connectionState.value != CoState.idle)
      return;

    final rom = ServiceManager().roomState.selectedRoom.value;
    if (rom == null) return;

    // 检查服务器列表是否为空，以及当前房间是否携带服务器
    final enabledServers =
        ServiceManager().serverState.servers.value
            .where((server) => server.enable)
            .toList();
    final hasRoomServers = rom.servers.isNotEmpty;

    if (enabledServers.isEmpty && !hasRoomServers) {
      // 显示提示信息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.add_server_first.tr()),
            action: SnackBarAction(
              label: LocaleKeys.go_add.tr(),
              onPressed: () {
                // 跳转到服务器页面（索引为2）
                ServiceManager().uiState.selectedIndex.set(2);
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
      await _initializeServer(rom);

      // 开始连接流程
      await _beginConnectionProcess();
    } catch (e) {
      // 发生错误时重置状态
      ServiceManager().connectionState.connectionState.value = CoState.idle;
      rethrow;
    }
  }

  Future<void> _initializeServer(dynamic rom) async {
    final services = ServiceManager();
    if (Platform.isAndroid) {
      vpnPlugin?.prepareVpn();
    }

    String currentIp = services.networkConfigState.ipv4.value;
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
    for (var conn in services.firewallState.connections.value) {
      if (conn.enabled) {
        for (var conn in conn.connections) {
          // 根据协议类型添加转发规则
          if (conn.proto == 'all') {
            // ALL协议时添加TCP和UDP两条规则
            forwards.add(
              Forward(
                bindAddr: conn.bindAddr,
                dstAddr: conn.dstAddr,
                proto: 'tcp',
              ),
            );
            forwards.add(
              Forward(
                bindAddr: conn.bindAddr,
                dstAddr: conn.dstAddr,
                proto: 'udp',
              ),
            );
          } else {
            // TCP或UDP时只添加对应协议的规则
            forwards.add(
              Forward(
                bindAddr: conn.bindAddr,
                dstAddr: conn.dstAddr,
                proto: conn.proto,
              ),
            );
          }
        }
      }
    }
    await createServer(
      username: services.playerState.playerName.value,
      enableDhcp: forceDhcp ? true : services.networkConfigState.dhcp.value,
      specifiedIp: forceDhcp ? "" : ipForServer, // 如果强制DHCP，则指定IP为空
      roomName: rom.roomName,
      roomPassword: rom.password,
      cidrs: services.vpnState.customVpn.value,
      forwards: forwards,
      severurl: () {
        // 获取全局启用的服务器生成的URL列表
        final globalUrls = <String>[];
        for (var server in services.serverState.servers.value.where(
          (server) => server.enable,
        )) {
          if (server.tcp) globalUrls.add('tcp://${server.url}');
          if (server.udp) globalUrls.add('udp://${server.url}');
          if (server.ws) globalUrls.add('ws://${server.url}');
          if (server.wss) globalUrls.add('wss://${server.url}');
          if (server.quic) globalUrls.add('quic://${server.url}');
          if (server.wg) globalUrls.add('wg://${server.url}');
          if (server.txt) globalUrls.add('txt://${server.url}');
          if (server.srv) globalUrls.add('srv://${server.url}');
          if (server.http) globalUrls.add('http://${server.url}');
          if (server.https) globalUrls.add('https://${server.url}');
        }

        // 合并房间服务器和全局服务器，然后去重
        final mergedUrls = <String>[...rom.servers, ...globalUrls];
        final deduplicatedUrls = mergedUrls.toSet().toList();

        return deduplicatedUrls;
      }(),
      onurl:
          ServiceManager().appSettingsState.listenList.value
              .where((url) => !url.contains('[::]'))
              .toList(),
      flag: _buildFlags(ServiceManager()),
    );
  }

  FlagsC _buildFlags(ServiceManager services) {
    final networkConfig = services.networkConfigState;
    final vpnState = services.vpnState;

    return FlagsC(
      defaultProtocol: networkConfig.defaultProtocol.value,
      devName: networkConfig.devName.value,
      enableEncryption: networkConfig.enableEncryption.value,
      enableIpv6: networkConfig.enableIpv6.value,
      mtu: networkConfig.enableEncryption.value ? 1360 : 1380,
      multiThread: networkConfig.multiThread.value,
      latencyFirst: networkConfig.latencyFirst.value,
      enableExitNode: networkConfig.enableExitNode.value,
      noTun: networkConfig.noTun.value,
      useSmoltcp: networkConfig.useSmoltcp.value,
      // relayNetworkWhitelist: networkConfig.relayNetworkWhitelist.value,
      relayNetworkWhitelist: '*',
      disableP2P: networkConfig.disableP2p.value,
      relayAllPeerRpc: true,
      disableUdpHolePunching: networkConfig.disableUdpHolePunching.value,
      dataCompressAlgo: networkConfig.dataCompressAlgo.value,
      bindDevice: networkConfig.bindDevice.value,
      enableKcpProxy: networkConfig.enableKcpProxy.value,
      disableKcpInput: networkConfig.disableKcpInput.value,
      disableRelayKcp: false,
      proxyForwardBySystem: vpnState.proxyForwardBySystem.value,
      acceptDns: vpnState.acceptDns.value,
      privateMode: vpnState.privateMode.value,
      enableQuicProxy: networkConfig.enableQuicProxy.value,
      disableQuicInput: networkConfig.disableQuicInput.value,
      disableSymHolePunching: networkConfig.disableSymHolePunching.value,
    );
  }

  Future<void> _beginConnectionProcess() async {
    ServiceManager().connectionState.connectionState.value = CoState.connecting;
    setState(() {
      _progress = 0.0;
    });

    // 在安卓平台显示连接中通知
    if (Platform.isAndroid) {
      await _showConnectionNotification(
        status: '连接中',
        ip: '正在获取...',
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
      if (ServiceManager().connectionState.connectionState.value ==
          CoState.connecting) {
        debugPrint("连接超时");
        if (Platform.isAndroid) {
          _cancelNotification();
        }
        _disconnect();
      }
    });
  }

  void _startConnectionStatusCheck() {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (ServiceManager().connectionState.connectionState.value !=
          CoState.connecting) {
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
    if (ipv4Address != "0.0.0.0" &&
        ServiceManager().networkConfigState.ipv4.value != ipv4Address) {
      ServiceManager().networkConfig.updateIpv4(ipv4Address);
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
    ServiceManager().connectionState.connectionState.value = CoState.connected;
    ServiceManager().connectionState.isConnecting.value = true;
    if (Platform.isAndroid) {
      _startVpn(
        ipv4Addr: ServiceManager().networkConfigState.ipv4.value,
        mtu: ServiceManager().networkConfigState.mtu.value,
      );
      // 显示连接成功通知
      await _showConnectionNotification(
        status: '已连接',
        ip:
            ServiceManager().networkConfigState.ipv4.value.isNotEmpty
                ? ServiceManager().networkConfigState.ipv4.value
                : '获取中...',
        duration: _formatDuration(_connectionDuration),
      );
    }
    if (Platform.isWindows) {
      // 始终将网卡跃点设置为最低（0），确保 IPv4 和 IPv6 都设置
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

      ServiceManager().networkConfig.updateIpv4(_extractIpv4Address(data));
      ServiceManager().connectionState.netStatus.value =
          await getNetworkStatus();

      // 在安卓平台更新通知
      if (Platform.isAndroid &&
          ServiceManager().connectionState.connectionState.value ==
              CoState.connected) {
        await _showConnectionNotification(
          status: '已连接',
          ip:
              ServiceManager().networkConfigState.ipv4.value.isNotEmpty
                  ? ServiceManager().networkConfigState.ipv4.value
                  : '获取中...',
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
    ServiceManager().connectionState.isConnecting.value = false;
    if (Platform.isAndroid) {
      vpnPlugin?.stopVpn();
      // 取消通知
      _cancelNotification();
    }
    // 取消计时器
    _connectionTimer?.cancel();
    _connectionTimer = null;
    closeServer();
    ServiceManager().connectionState.connectionState.value = CoState.idle;
  }

  /// 切换连接状态的方法
  /// 根据当前的连接状态来决定是开始连接还是断开连接
  void _toggleConnection() {
    if (ServiceManager().connectionState.connectionState.value ==
        CoState.idle) {
      // 如果当前是空闲状态，则开始连接
      _startConnection();
    } else if (ServiceManager().connectionState.connectionState.value ==
        CoState.connected) {
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
        text = '连接';
      case CoState.connecting:
        text = '连接中...';
      case CoState.connected:
        text = '已连接';
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
                  ServiceManager().connectionState.connectionState.value ==
                          CoState.connecting
                      ? Offset.zero
                      : const Offset(0, 1.0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity:
                    ServiceManager().connectionState.connectionState.value ==
                            CoState.connecting
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
                      'progress_${ServiceManager().connectionState.connectionState.value == CoState.connecting}',
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
                  ServiceManager().connectionState.connectionState.value !=
                          CoState.idle
                      ? 180
                      : 100,
              height: 60,
              child: FloatingActionButton.extended(
                onPressed:
                    ServiceManager().connectionState.connectionState.value ==
                            CoState.connecting
                        ? null
                        : _toggleConnection,
                heroTag: "connect_button",
                extendedPadding: const EdgeInsets.symmetric(horizontal: 2),
                splashColor:
                    ServiceManager().connectionState.connectionState.value !=
                            CoState.idle
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
                  child: _getButtonIcon(
                    ServiceManager().connectionState.connectionState.value,
                  ),
                ),
                label: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOutQuad,
                  switchOutCurve: Curves.easeInQuad,
                  child: _getButtonLabel(
                    ServiceManager().connectionState.connectionState.value,
                  ),
                ),
                backgroundColor: _getButtonColor(
                  ServiceManager().connectionState.connectionState.value,
                  colorScheme,
                ),
                foregroundColor: _getButtonForegroundColor(
                  ServiceManager().connectionState.connectionState.value,
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
