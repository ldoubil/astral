import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:astral/models/net_node.dart';
import 'package:astral/models/room_info.dart';
import 'package:astral/models/user_info.dart';
import 'package:astral/src/rust/api/hops.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:astral/state/app_state.dart';
import 'package:astral/state/v2/base.dart';
import 'package:flutter/material.dart';
import 'package:vpn_service_plugin/vpn_service_plugin.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

/// 全局连接服务类
/// 负责管理服务器连接、断开连接等操作
class V2ConnectionService {
  static final V2ConnectionService _instance = V2ConnectionService._internal();
  factory V2ConnectionService() => _instance;
  V2ConnectionService._internal();

  /* ------------------------ 常量定义 ------------------------ */
  static const int connectionTimeoutSeconds = 15;
  static const int networkMonitoringIntervalSeconds = 1;
  static const int connectionCheckIntervalSeconds = 1;
  static const String invalidIpAddress = "0.0.0.0";
  static const String defaultCidrMask = "/24";
  static const int defaultMtu = 1360;
  static const int mtuWithEncryption = 1360;
  static const int mtuWithoutEncryption = 1380;

  /* ------------------------ 私有字段 ------------------------ */
  final VpnServicePlugin? vpnPlugin =
      Platform.isAndroid ? VpnServicePlugin() : null;

  Timer? _connectionTimer;
  Timer? _timeoutTimer;
  BuildContext? _currentContext; // 保存当前context用于显示对话框

  /* ------------------------ VPN状态跟踪 ------------------------ */
  int? _vpnFileDescriptor;
  bool _isVpnServiceStarted = false;
  bool _vpnDialogShown = false; // 标记是否已显示VPN对话框

  /// 获取VPN文件描述符
  int? get vpnFileDescriptor => _vpnFileDescriptor;

  /// 检查VPN服务是否已启动
  bool get isVpnServiceStarted => _isVpnServiceStarted;

  /* ------------------------ 回调函数 ------------------------ */
  Function(String message)? onError;
  Function()? onConnected;
  Function()? onDisconnected;

  /// VPN状态变化回调 (context, isStarted, fileDescriptor, message)
  Function(
    BuildContext context,
    bool isStarted,
    int? fileDescriptor,
    String message,
  )?
  onVpnStatusChanged;

  /// 用于获取context的全局导航键（可选）
  GlobalKey<NavigatorState>? navigatorKey;

  /* ------------------------ 公共方法 ------------------------ */

  /// 初始化服务
  Future<void> initialize() async {
    if (Platform.isAndroid) {
      _setupVpnListeners();
    }
  }

  /// 开始连接房间
  /// [room] 要连接的房间信息
  /// [netNode] 网络节点配置
  /// [context] 可选的BuildContext，用于显示对话框
  Future<void> connectToRoom(
    RoomInfo room,
    NetNode netNode, {
    BuildContext? context,
  }) async {
    if (!_canStartConnection()) {
      print("初始化服务器1");
      return;
    }

    if (!_validateRoom(room)) {
      print("初始化服务器2");
      onError?.call(LocaleKeys.add_server_first.tr());
      return;
    }

    // 保存context用于后续显示对话框
    _currentContext = context;

    try {
      await _initializeServer(room, netNode);
      await _beginConnectionProcess(netNode);
    } catch (e) {
      _handleConnectionError(e);
      rethrow;
    }
  }

  /// 断开连接
  void disconnect() {
    _updateConnectionState(false);
    _stopVpn();
    _cancelAllTimers();
    closeServer();
    _clearUserInfo();
    _currentContext = null; // 清除保存的context
    _vpnDialogShown = false; // 重置对话框标记
    onDisconnected?.call();
  }

  /// 清空用户信息列表
  void _clearUserInfo() {
    AppState().v2BaseState.userInfo.value = [];
  }

  /// 清理资源
  void dispose() {
    _cancelAllTimers();
  }

  /* ------------------------ 初始化相关 ------------------------ */

  /// 设置VPN监听器
  void _setupVpnListeners() {
    if (vpnPlugin == null) return;

    vpnPlugin!.onVpnServiceStarted.listen((data) {
      final fd = data['fd'] as int?;
      _vpnFileDescriptor = fd;
      _isVpnServiceStarted = fd != null && fd > 0;

      debugPrint('VPN服务已启动，文件描述符: $fd');

      if (_isVpnServiceStarted && fd != null) {
        setTunFd(fd: fd);
        debugPrint('VPN文件描述符已设置: $fd');

        // 通知VPN状态变化（如果有context的话）
        final context = _currentContext ?? _getCurrentContext();
        if (context != null && context.mounted && !_vpnDialogShown) {
          _vpnDialogShown = true; // 标记已显示对话框
          _notifyVpnStatusChanged(true, fd, 'VPN连接已建立\n文件描述符: $fd');
          // 显示成功对话框
          _showVpnStatusDialog(context, true, fd, 'VPN连接已建立\n文件描述符: $fd');
        }
      } else {
        final context = _currentContext ?? _getCurrentContext();
        if (context != null && context.mounted && !_vpnDialogShown) {
          _vpnDialogShown = true; // 标记已显示对话框
          _notifyVpnStatusChanged(false, null, 'VPN服务启动失败：文件描述符无效');
          _showVpnStatusDialog(context, false, null, 'VPN服务启动失败\n文件描述符无效');
        }
      }
    });

    vpnPlugin!.onVpnServiceStopped.listen((data) {
      debugPrint('VPN服务已停止');
      _vpnFileDescriptor = null;
      _isVpnServiceStarted = false;
      _vpnDialogShown = false; // 重置对话框标记
      _notifyVpnStatusChanged(false, null, 'VPN连接已断开');
    });
  }

  /// 获取当前context
  BuildContext? _getCurrentContext() {
    return navigatorKey?.currentContext;
  }

  /// 通知VPN状态变化
  void _notifyVpnStatusChanged(
    bool isStarted,
    int? fileDescriptor,
    String message,
  ) {
    final context = _getCurrentContext();
    if (context != null && onVpnStatusChanged != null) {
      onVpnStatusChanged!(context, isStarted, fileDescriptor, message);
    }
    debugPrint('VPN状态变化: $message');
  }

  /// 检查Android VPN连接是否已创建
  /// 返回 (是否已创建, 文件描述符, 状态描述)
  (bool isCreated, int? fileDescriptor, String status) checkVpnConnection() {
    if (!Platform.isAndroid) {
      return (false, null, '非Android平台');
    }

    if (!_isVpnServiceStarted || _vpnFileDescriptor == null) {
      return (false, null, 'VPN服务未启动或文件描述符无效');
    }

    final fd = _vpnFileDescriptor!;
    if (fd > 0) {
      return (true, fd, 'VPN连接正常\n文件描述符: $fd');
    } else {
      return (false, null, 'VPN文件描述符无效: $fd');
    }
  }

  /* ------------------------ 连接验证 ------------------------ */

  /// 检查是否可以开始连接
  bool _canStartConnection() {
    return AppState().v2BaseState.roomConnectionState.value ==
        RoomConnectionState.idle;
  }

  /// 验证房间信息
  bool _validateRoom(RoomInfo room) {
    return room.servers.isNotEmpty;
  }

  /* ------------------------ 服务器初始化 ------------------------ */

  /// 初始化服务器
  Future<void> _initializeServer(RoomInfo room, NetNode netNode) async {
    print("初始化服务器");
    final serverConfig = _buildServerConfig(room, netNode);
    final username = _buildUsername();
    await createServer(
      username: username,
      enableDhcp: serverConfig.enableDhcp,
      specifiedIp: serverConfig.specifiedIp,
      roomName: room.uuid,
      roomPassword: room.uuid,
      cidrs: netNode.cidrproxy,
      forwards: serverConfig.forwards,
      severurl: serverConfig.serverUrls,
      onurl: _getFilteredListenUrls(),
      flag: _buildFlags(netNode),
    );
  }

  /// 准备VPN权限（如果需要）
  Future<void> _prepareVpnIfNeeded() async {
    if (!Platform.isAndroid || vpnPlugin == null) {
      return;
    }

    try {
      await vpnPlugin!.prepareVpn();
      // prepareVpn() 如果返回errorMsg，说明需要用户授权，但已经启动了授权界面
      // 这里不阻塞，让用户完成授权即可
    } catch (e) {
      debugPrint('准备VPN权限失败: $e');
    }
  }

  /// 构建服务器配置
  _ServerConfig _buildServerConfig(RoomInfo room, NetNode netNode) {
    return _ServerConfig(
      enableDhcp: true,
      specifiedIp: "",
      serverUrls: _buildServerUrls(room.servers),
      forwards: [], // 端口转发逻辑可以在这里添加
    );
  }

  String _buildUsername() {
    final baseName = AppState().v2UserState.Name.value.trim();
    final avatarUrl = AppState().v2UserState.AvatarUrl.value.trim();
    final qq = _extractQqFromAvatarUrl(avatarUrl);

    final safeName = baseName.isNotEmpty ? baseName : '默认用户名';

    if (qq != null && _isValidQq(qq)) {
      return '$safeName*$qq';
    }
    return safeName;
  }

  /// 构建服务器URL列表
  List<String> _buildServerUrls(List servers) {
    return servers.map((server) => _buildServerUrl(server)).toList();
  }

  /// 构建单个服务器URL
  String _buildServerUrl(dynamic server) {
    final protocol = _getProtocolString(server.protocolSwitch);
    return '$protocol://${server.host}:${server.port}';
  }

  /// 获取过滤后的监听URL列表
  List<String> _getFilteredListenUrls() {
    return AppState().v2BaseState.listenListPersistent.value
        .where((url) => !url.contains('[::]'))
        .toList();
  }

  /// 获取协议字符串
  String _getProtocolString(dynamic protocolSwitch) {
    const protocolMap = {
      'ServerProtocolSwitch.tcp': 'tcp',
      'ServerProtocolSwitch.udp': 'udp',
      'ServerProtocolSwitch.ws': 'ws',
      'ServerProtocolSwitch.wss': 'wss',
      'ServerProtocolSwitch.quic': 'quic',
      'ServerProtocolSwitch.wg': 'wg',
      'ServerProtocolSwitch.http': 'http',
      'ServerProtocolSwitch.https': 'https',
    };

    return protocolMap[protocolSwitch.toString()] ?? 'tcp';
  }

  /// 构建标志配置
  FlagsC _buildFlags(NetNode netNode) {
    return FlagsC(
      defaultProtocol: netNode.default_protocol,
      devName: netNode.dev_name,
      enableEncryption: netNode.enable_encryption,
      enableIpv6: true,
      mtu: netNode.enable_encryption ? mtuWithEncryption : mtuWithoutEncryption,
      multiThread: netNode.multi_thread,
      latencyFirst: netNode.latency_first,
      enableExitNode: true,
      noTun: netNode.no_tun,
      useSmoltcp: netNode.use_smoltcp,
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

  /* ------------------------ 连接流程管理 ------------------------ */

  /// 开始连接流程
  Future<void> _beginConnectionProcess(NetNode netNode) async {
    AppState().v2BaseState.setConnecting();
    _setupConnectionTimeout();
    _startConnectionStatusCheck(netNode);
  }

  /// 设置连接超时
  void _setupConnectionTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(
      Duration(seconds: connectionTimeoutSeconds),
      _handleConnectionTimeout,
    );
  }

  /// 处理连接超时
  void _handleConnectionTimeout() {
    if (AppState().v2BaseState.roomConnectionState.value ==
        RoomConnectionState.connecting) {
      debugPrint(LocaleKeys.connection_timeout.tr());
      disconnect();
    }
  }

  /// 启动连接状态检查
  void _startConnectionStatusCheck(NetNode netNode) {
    Timer.periodic(
      const Duration(seconds: connectionCheckIntervalSeconds),
      (timer) => _checkConnectionStatus(timer, netNode),
    );
  }

  /// 检查连接状态
  Future<void> _checkConnectionStatus(Timer timer, NetNode netNode) async {
    if (AppState().v2BaseState.roomConnectionState.value !=
        RoomConnectionState.connecting) {
      timer.cancel();
      return;
    }

    final isConnected = await _checkAndUpdateConnectionStatus(netNode);
    if (isConnected) {
      timer.cancel();
      // 使用保存的context或通过navigatorKey获取
      final currentContext = _currentContext ?? _getCurrentContext();
      await _handleSuccessfulConnection(netNode, context: currentContext);
    }
  }

  /// 检查并更新连接状态
  Future<bool> _checkAndUpdateConnectionStatus(NetNode netNode) async {
    try {
      final runningInfo = await getRunningInfo();
      final data = jsonDecode(runningInfo) as Map<String, dynamic>;
      final ipv4Address = _extractIpv4Address(data);

      if (ipv4Address != invalidIpAddress) {
        if (AppState().v2UserState.ipv4.value != ipv4Address) {
          AppState().v2UserState.ipv4.value = ipv4Address;
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('检查连接状态失败: $e');
      return false;
    }
  }

  /// 提取IPv4地址
  String _extractIpv4Address(Map<String, dynamic> data) {
    final virtualIpv4 = data['my_node_info']?['virtual_ipv4'];
    if (virtualIpv4 == null || virtualIpv4.isEmpty) {
      return invalidIpAddress;
    }

    final addr = virtualIpv4['address']?['addr'] ?? 0;
    return intToIp(addr as int);
  }

  /// 处理成功连接
  Future<void> _handleSuccessfulConnection(
    NetNode netNode, {
    BuildContext? context,
  }) async {
    _cancelTimeoutTimer();
    _updateConnectionState(true);

    // 连接成功后立即从服务器获取最新数据（IP地址等）
    try {
      debugPrint('连接成功，立即获取服务器数据...');
      final runningInfo = await getRunningInfo();
      final data = jsonDecode(runningInfo) as Map<String, dynamic>;
      final extractedIp = _extractIpv4Address(data);

      if (_isValidIpAddress(extractedIp)) {
        // 更新IP地址到netNode和状态中
        netNode.ipv4 = extractedIp;
        AppState().v2UserState.ipv4.value = extractedIp;
        debugPrint('从服务器获取IP地址成功: $extractedIp');
      } else {
        // 如果仍然无效，尝试从状态中获取
        final stateIp = AppState().v2UserState.ipv4.value;
        if (stateIp.isNotEmpty &&
            stateIp != invalidIpAddress &&
            _isValidIpAddress(stateIp)) {
          netNode.ipv4 = stateIp;
          debugPrint('从状态获取IP地址: $stateIp');
        }
      }
    } catch (e) {
      debugPrint('获取服务器数据失败: $e');
      // 如果获取失败，尝试使用已有的IP地址
      final stateIp = AppState().v2UserState.ipv4.value;
      if (stateIp.isNotEmpty &&
          stateIp != invalidIpAddress &&
          _isValidIpAddress(stateIp)) {
        netNode.ipv4 = stateIp;
      }
    }

    // 立即启动VPN（等待IP地址准备好）
    await _setupPlatformSpecificFeatures(netNode, context: context);
    onConnected?.call();
    _startNetworkMonitoring();
  }

  /// 更新连接状态
  void _updateConnectionState(bool isConnected) {
    AppState().v2BaseState.isConnecting.value = isConnected;
    if (isConnected) {
      AppState().v2BaseState.setConnected();
    } else {
      AppState().v2BaseState.resetConnectionState();
    }
  }

  /// 设置平台特定功能
  Future<void> _setupPlatformSpecificFeatures(
    NetNode netNode, {
    BuildContext? context,
  }) async {
    if (Platform.isAndroid) {
      await _startVpn(netNode, context: context);
    } else if (Platform.isWindows) {
      setInterfaceMetric(interfaceName: "astral", metric: 0);
    }
  }

  /// 处理连接错误
  void _handleConnectionError(dynamic error) {
    AppState().v2BaseState.resetConnectionState();
    onError?.call(error.toString());
  }

  /* ------------------------ VPN管理 ------------------------ */

  /// 启动VPN
  Future<void> _startVpn(NetNode netNode, {BuildContext? context}) async {
    if (!Platform.isAndroid || vpnPlugin == null) {
      return;
    }

    // 尝试从多个来源获取IP地址
    String ipv4Addr = netNode.ipv4;

    // 如果netNode中的IP无效或为空，尝试从状态中获取
    if (ipv4Addr.isEmpty || !_isValidIpAddress(ipv4Addr)) {
      final stateIp = AppState().v2UserState.ipv4.value;
      if (stateIp.isNotEmpty && _isValidIpAddress(stateIp)) {
        ipv4Addr = stateIp;
        netNode.ipv4 = stateIp; // 同步更新到netNode
        debugPrint('从状态获取IP地址: $ipv4Addr');
      }
    }

    // 如果还是无效，尝试重新从服务器获取
    if (ipv4Addr.isEmpty || !_isValidIpAddress(ipv4Addr)) {
      try {
        debugPrint('尝试从服务器获取IP地址...');
        final runningInfo = await getRunningInfo();
        final data = jsonDecode(runningInfo) as Map<String, dynamic>;
        final extractedIp = _extractIpv4Address(data);
        if (_isValidIpAddress(extractedIp)) {
          ipv4Addr = extractedIp;
          netNode.ipv4 = extractedIp; // 更新netNode中的IP
          AppState().v2UserState.ipv4.value = extractedIp; // 更新状态中的IP
          debugPrint('从服务器获取IP地址成功: $ipv4Addr');
        }
      } catch (e) {
        debugPrint('获取IP地址失败: $e');
      }
    }

    // 必须等待IP地址分配，不能使用默认IP
    if (ipv4Addr.isEmpty || !_isValidIpAddress(ipv4Addr)) {
      debugPrint('未获取到有效IP地址，无法启动VPN: $ipv4Addr');
      if (context != null && context.mounted) {
        _showVpnStatusDialog(
          context,
          false,
          null,
          'VPN启动失败\n未获取到虚拟IP地址，无法启动VPN\n\n当前IP: ${ipv4Addr.isEmpty ? "未获取" : ipv4Addr}\n\n提示：请等待IP地址分配完成后再启动VPN',
        );
      }
      return;
    }

    // 确保IP地址格式为"IP/掩码"
    final formattedIp = _formatIpAddress(ipv4Addr);
    debugPrint('准备启动VPN，使用IP地址: $formattedIp');
    final routes = _getValidVpnRoutes();

    // 直接启动VPN，Android端会自动处理权限
    // 如果权限未准备好，startVpn会返回errorMsg，但我们不阻塞等待
    // 用户授权后可以手动重新连接或等待自动重试
    try {
      final result = await vpnPlugin!.startVpn(
        ipv4Addr: formattedIp, // 必须提供有效的IP地址
        mtu: netNode.mtu,
        routes: routes,
        disallowedApplications: const ['com.kevin.astral'],
      );

      // 检查是否需要VPN权限
      if (result.containsKey('errorMsg')) {
        final errorMsg = result['errorMsg'] as String;
        if (errorMsg == 'need_prepare') {
          debugPrint('需要VPN权限，准备显示授权界面');

          if (context != null && context.mounted) {
            _showVpnStatusDialog(
              context,
              false,
              null,
              '需要VPN权限\n请在授权界面中允许VPN连接',
            );
          }

          // 准备VPN权限，显示授权界面
          await _prepareVpnIfNeeded();
          // 注意：此时权限可能还未准备好，需要用户授权
          // VPN服务会在用户授权完成后才能启动
        }
      } else {
        debugPrint('VPN服务启动请求已发送: $formattedIp');

        // VPN服务启动请求已发送，文件描述符将通过 onVpnServiceStarted 回调返回
        // 等待一段时间让服务启动完成（最多等待3秒）
        bool vpnStarted = false;
        for (int i = 0; i < 6; i++) {
          await Future.delayed(const Duration(milliseconds: 500));
          final (isCreated, fd, status) = checkVpnConnection();
          if (isCreated && fd != null) {
            vpnStarted = true;
            debugPrint('VPN服务已成功启动，文件描述符: $fd');
            break;
          }
        }

        // 如果等待后仍未启动，显示提示（实际成功会通过监听器显示）
        if (!vpnStarted && context != null && context.mounted) {
          final (isCreated, fd, status) = checkVpnConnection();
          if (!isCreated) {
            // 显示等待提示，但不在监听器中重复显示
            debugPrint('VPN服务启动超时，等待文件描述符...');
          }
        }
      }
    } catch (e) {
      debugPrint('启动VPN失败: $e');
      if (context != null && context.mounted) {
        _showVpnStatusDialog(context, false, null, 'VPN启动失败\n错误: $e');
      }
    }
  }

  /// 显示VPN状态对话框
  void _showVpnStatusDialog(
    BuildContext context,
    bool isCreated,
    int? fileDescriptor,
    String message,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  isCreated ? Icons.check_circle : Icons.error,
                  color: isCreated ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(isCreated ? 'VPN连接成功' : 'VPN连接状态'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                if (fileDescriptor != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '文件描述符 (FD):',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '$fileDescriptor',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('确定'),
              ),
              if (!isCreated && Platform.isAndroid)
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // 可以在这里添加重试逻辑
                    _prepareVpnIfNeeded();
                  },
                  child: const Text('重新授权'),
                ),
            ],
          ),
    );
  }

  /// 格式化IP地址（添加CIDR掩码）
  String _formatIpAddress(String ip) {
    if (ip.contains('/')) {
      return ip;
    }
    return '$ip$defaultCidrMask';
  }

  /// 获取有效的VPN路由
  List<String> _getValidVpnRoutes() {
    return AppState().v2BaseState.customVpn.value
        .where((route) => _isValidCIDR(route))
        .toList();
  }

  /// 停止VPN
  void _stopVpn() {
    if (Platform.isAndroid) {
      vpnPlugin?.stopVpn();
    }
  }

  /* ------------------------ 网络监控 ------------------------ */

  /// 启动网络监控
  void _startNetworkMonitoring() {
    _connectionTimer?.cancel();
    _connectionTimer = Timer.periodic(
      const Duration(seconds: networkMonitoringIntervalSeconds),
      _monitorNetworkStatus,
    );
  }

  /// 监控网络状态
  Future<void> _monitorNetworkStatus(Timer timer) async {
    try {
      final status = await getNetworkStatus();
      AppState().v2BaseState.netStatus.value = status;

      // 更新用户信息列表
      _updateUserInfo(status);
    } catch (e) {
      debugPrint('网络监控错误: $e');
    }
  }

  /// 更新用户信息列表
  void _updateUserInfo(KVNetworkStatus status) {
    final userInfoList =
        status.nodes
            .where(_shouldIncludeNode)
            .map((node) => _convertNodeToUserInfo(node))
            .toList();

    AppState().v2BaseState.userInfo.value = userInfoList;
  }

  /// 判断节点是否需要展示
  bool _shouldIncludeNode(KVNodeInfo node) {
    final hostname = node.hostname.toLowerCase();
    final ipv4 = node.ipv4;

    if (hostname.contains('server')) {
      return false;
    }

    if (ipv4 == invalidIpAddress) {
      return false;
    }

    return true;
  }

  /// 将 KVNodeInfo 转换为 UserInfo
  UserInfo _convertNodeToUserInfo(KVNodeInfo node) {
    final version = node.version;
    String device = "unknown";

    if (version.contains('|')) {
      final parts = version.split('|');
      if (parts.length >= 2 && parts[1].trim().isNotEmpty) {
        device = parts[1].trim();
      }
    }

    // avatarUrl 从昵称分割 * 为分割符 0是昵称 1 是qq号（可能为空）
    String displayName = node.hostname;
    String avatarUrl = "";

    if (displayName.contains('*')) {
      final parts = displayName.split('*');
      if (parts.isNotEmpty && parts[0].trim().isNotEmpty) {
        displayName = parts[0].trim();
      }
      if (parts.length > 1) {
        final qq = parts[1].trim();
        if (_isValidQq(qq)) {
          avatarUrl = _buildQqAvatarUrl(qq);
        }
      }
    }

    if (displayName.isEmpty) {
      displayName = '未知用户';
    }

    return UserInfo(
      name: displayName,
      avatarUrl: avatarUrl,
      ip: node.ipv4,
      latency: node.latencyMs.round(),
      device: device,
    );
  }

  bool _isValidQq(String qq) {
    if (qq.isEmpty || qq.length > 10) return false;
    return RegExp(r'^\d+$').hasMatch(qq);
  }

  String _buildQqAvatarUrl(String qq) =>
      'http://q.qlogo.cn/headimg_dl?dst_uin=$qq&spec=640&img_type=jpg';

  String? _extractQqFromAvatarUrl(String url) {
    if (url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final qq = uri.queryParameters['dst_uin'];
    if (qq != null && _isValidQq(qq)) {
      return qq;
    }
    return null;
  }

  /* ------------------------ 定时器管理 ------------------------ */

  /// 取消所有定时器
  void _cancelAllTimers() {
    _cancelConnectionTimer();
    _cancelTimeoutTimer();
  }

  /// 取消连接定时器
  void _cancelConnectionTimer() {
    _connectionTimer?.cancel();
    _connectionTimer = null;
  }

  /// 取消超时定时器
  void _cancelTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  /* ------------------------ 工具方法 ------------------------ */

  /// 验证IPv4地址格式
  bool _isValidIpAddress(String ip) {
    if (ip.isEmpty) return false;

    final ipRegex = RegExp(
      r"^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",
    );

    if (!ipRegex.hasMatch(ip)) {
      return false;
    }

    // 排除特殊保留地址
    if (ip == invalidIpAddress || ip == "255.255.255.255") {
      return false;
    }

    return true;
  }

  /// 验证CIDR格式
  bool _isValidCIDR(String cidr) {
    final cidrPattern = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/(3[0-2]|[12]?[0-9])$',
    );

    if (!cidrPattern.hasMatch(cidr)) {
      debugPrint('⚠️ 无效路由条目已过滤: $cidr');
      return false;
    }

    final parts = cidr.split('/');
    final ip = parts[0];
    final mask = int.tryParse(parts[1]) ?? -1;

    return _isValidIpAddress(ip) && mask >= 0 && mask <= 32;
  }
}

/* ------------------------ 辅助类 ------------------------ */

/// 服务器配置数据类
class _ServerConfig {
  final bool enableDhcp;
  final String specifiedIp;
  final List<String> serverUrls;
  final List<Forward> forwards;

  _ServerConfig({
    required this.enableDhcp,
    required this.specifiedIp,
    required this.serverUrls,
    required this.forwards,
  });
}

/* ------------------------ 工具函数 ------------------------ */

/// 整数转为 IP 字符串
String intToIp(int ipInt) {
  return [
    (ipInt >> 24) & 0xFF,
    (ipInt >> 16) & 0xFF,
    (ipInt >> 8) & 0xFF,
    ipInt & 0xFF,
  ].join('.');
}
