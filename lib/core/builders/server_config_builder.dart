import 'package:astral/core/models/server_mod.dart';
import 'package:astral/core/models/network_config_share.dart';
import 'package:astral/core/models/forwarding.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:flutter/foundation.dart';

/// 服务器配置构建器
///
/// 设计思路：
/// 1. 默认配置为底层
/// 2. 通过链式调用逐层修改
/// 3. 房间配置可临时覆盖默认配置（不修改持久化）
/// 4. 每步都有日志记录
class ServerConfigBuilder {
  final ServiceManager _services;
  final List<String> _logs = [];

  // 配置参数
  String? _username;
  bool? _enableDhcp;
  String? _specifiedIp;
  String? _roomName;
  String? _roomPassword;
  List<String> _serverUrls = [];
  List<String> _listenerUrls = [];
  List<String> _cidrs = [];
  List<Forward> _forwards = [];
  FlagsC? _flags;

  // 房间配置（临时覆盖）
  NetworkConfigShare? _roomConfig;

  ServerConfigBuilder(this._services) {
    _log('📦 初始化服务器配置构建器');
  }

  void _log(String message) {
    debugPrint('🔧 $message');
    _logs.add(message);
  }

  /// 设置玩家信息
  ServerConfigBuilder withPlayerInfo() {
    _username = _services.playerState.playerName.value;

    final currentIp = _services.networkConfigState.ipv4.value;
    bool forceDhcp =
        currentIp.isEmpty ||
        currentIp == "0.0.0.0" ||
        !_isValidIpAddress(currentIp);

    if (forceDhcp) {
      _enableDhcp = true;
      _specifiedIp = "";
      _log('玩家: $_username (强制DHCP)');
    } else {
      _enableDhcp = _services.networkConfigState.dhcp.value;
      _specifiedIp = currentIp;
      _log('玩家: $_username (IP: $currentIp, DHCP: $_enableDhcp)');
    }

    return this;
  }

  /// 设置房间信息
  ServerConfigBuilder withRoom(dynamic room) {
    _roomName = room.roomName;
    _roomPassword = room.password;
    _log('房间: $_roomName');
    return this;
  }

  /// 设置房间配置（临时覆盖）
  ServerConfigBuilder withRoomConfig(NetworkConfigShare? config) {
    _roomConfig = config;
    if (config != null) {
      final overrides = <String>[];
      if (config.dhcp != null) overrides.add('DHCP');
      if (config.defaultProtocol != null) overrides.add('协议');
      if (config.enableEncryption != null) overrides.add('加密');
      if (config.latencyFirst != null) overrides.add('低延迟');
      if (config.disableP2p != null) overrides.add('P2P');
      if (config.disableUdpHolePunching != null) overrides.add('UDP打洞');
      if (config.enableKcpProxy != null) overrides.add('KCP代理');
      if (config.noTun != null) overrides.add('TUN模式');

      if (overrides.isNotEmpty) {
        _log('🔄 房间配置临时覆盖: ${overrides.join(', ')}');
      }
    }
    return this;
  }

  /// 构建服务器URL列表
  ServerConfigBuilder withServers(dynamic room, List<ServerMod> globalServers) {
    // 房间服务器优先 - 直接检查列表，不依赖 hasServers 标志
    if (room.servers != null && room.servers.isNotEmpty) {
      _serverUrls = List<String>.from(room.servers);
      _log('📡 使用房间服务器 (${_serverUrls.length} 个): $_serverUrls');
      return this;
    }

    // 否则使用全局启用的服务器
    final urls = <String>[];
    for (var server in globalServers.where((s) => s.enable)) {
      if (server.tcp) urls.add('tcp://${server.url}');
      if (server.udp) urls.add('udp://${server.url}');
      if (server.ws) urls.add('ws://${server.url}');
      if (server.wss) urls.add('wss://${server.url}');
      if (server.quic) urls.add('quic://${server.url}');
      if (server.wg) urls.add('wg://${server.url}');
      if (server.txt) urls.add('txt://${server.url}');
      if (server.srv) urls.add('srv://${server.url}');
      if (server.http) urls.add('http://${server.url}');
      if (server.https) urls.add('https://${server.url}');
    }

    _serverUrls = urls;
    _log('📡 使用全局服务器 (${_serverUrls.length} 个)');
    return this;
  }

  /// 构建监听器列表
  ServerConfigBuilder withListeners(List<String> listeners) {
    _listenerUrls = listeners.where((url) => !url.contains('[::]')).toList();
    _log('👂 监听器 (${_listenerUrls.length} 个)');
    return this;
  }

  /// 构建代理CIDR
  ServerConfigBuilder withCidrs(List<String> cidrs) {
    _cidrs = cidrs;
    if (cidrs.isNotEmpty) {
      _log('🌐 代理CIDR (${cidrs.length} 个)');
    }
    return this;
  }

  /// 构建端口转发规则
  ServerConfigBuilder withForwards(List<ForwardingConnection> groups) {
    final forwards = <Forward>[];

    for (var group in groups.where((g) => g.enabled)) {
      for (var conn in group.connections) {
        if (conn.proto == 'all') {
          // ALL协议展开为TCP和UDP
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

    _forwards = forwards;
    if (forwards.isNotEmpty) {
      _log('🔀 端口转发 (${forwards.length} 条规则)');
    }
    return this;
  }

  /// 构建运行时标志（支持房间配置覆盖）
  ServerConfigBuilder withFlags() {
    final nc = _services.networkConfigState;
    final vpn = _services.vpnState;
    final rc = _roomConfig; // 房间配置

    // 应用房间配置的DHCP覆盖
    if (rc?.dhcp != null) {
      _enableDhcp = rc!.dhcp;
      _log('🔄 DHCP被房间配置覆盖: ${rc.dhcp}');
    }

    final enableEncryption = rc?.enableEncryption ?? nc.enableEncryption.value;

    _flags = FlagsC(
      defaultProtocol: rc?.defaultProtocol ?? nc.defaultProtocol.value,
      devName: nc.devName.value,
      enableEncryption: enableEncryption,
      enableIpv6: nc.enableIpv6.value,
      mtu: enableEncryption ? 1360 : 1380,
      multiThread: nc.multiThread.value,
      latencyFirst: rc?.latencyFirst ?? nc.latencyFirst.value,
      enableExitNode: nc.enableExitNode.value,
      noTun: rc?.noTun ?? nc.noTun.value,
      useSmoltcp: nc.useSmoltcp.value,
      relayNetworkWhitelist: '*',
      disableP2P: rc?.disableP2p ?? nc.disableP2p.value,
      relayAllPeerRpc: true,
      disableUdpHolePunching:
          rc?.disableUdpHolePunching ?? nc.disableUdpHolePunching.value,
      disableTcpHolePunching:
          rc?.disableTcpHolePunching ?? nc.disableTcpHolePunching.value,
      dataCompressAlgo: rc?.dataCompressAlgo ?? nc.dataCompressAlgo.value,
      bindDevice: (rc?.bindDevice == true) ? nc.bindDevice.value : false,
      enableKcpProxy: rc?.enableKcpProxy ?? nc.enableKcpProxy.value,
      disableKcpInput: nc.disableKcpInput.value,
      disableRelayKcp: false,
      proxyForwardBySystem: vpn.proxyForwardBySystem.value,
      acceptDns: vpn.acceptDns.value,
      privateMode: vpn.privateMode.value,
      enableQuicProxy: nc.enableQuicProxy.value,
      disableQuicInput: nc.disableQuicInput.value,
      disableSymHolePunching:
          rc?.disableSymHolePunching ?? nc.disableSymHolePunching.value,
      tcpWhitelist: nc.tcpWhitelist.value,
      udpWhitelist: nc.udpWhitelist.value,
    );

    _log('⚙️  运行标志配置完成 (加密: $enableEncryption)');
    return this;
  }

  /// 构建并返回配置 + 日志
  ({
    String username,
    bool enableDhcp,
    String specifiedIp,
    String roomName,
    String roomPassword,
    List<String> severurl,
    List<String> onurl,
    List<String> cidrs,
    List<Forward> forwards,
    FlagsC flag,
    List<String> logs,
  })
  build() {
    _log('✅ 配置构建完成');
    _log(
      '📊 摘要: 服务器=${_serverUrls.length}, 监听器=${_listenerUrls.length}, 转发=${_forwards.length}',
    );

    return (
      username: _username!,
      enableDhcp: _enableDhcp!,
      specifiedIp: _specifiedIp!,
      roomName: _roomName!,
      roomPassword: _roomPassword!,
      severurl: _serverUrls,
      onurl: _listenerUrls,
      cidrs: _cidrs,
      forwards: _forwards,
      flag: _flags!,
      logs: List.unmodifiable(_logs),
    );
  }

  bool _isValidIpAddress(String ip) {
    if (ip.isEmpty) return false;
    final RegExp ipRegex = RegExp(
      r"^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",
    );
    return ipRegex.hasMatch(ip) && ip != "0.0.0.0" && ip != "255.255.255.255";
  }
}
