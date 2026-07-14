import 'package:astral/core/database/dao/net_config_dao.dart';
import 'package:astral/core/models/net_config.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 网络配置状态（纯Signal，29个字段）
class NetworkConfigState {
  // ========== 基础网络配置 (7个) ==========
  final netns = signal('');
  final hostname = signal('');
  final instanceName = signal('default');
  final ipv4 = signal('');
  final dhcp = signal(true);
  final autoSetMTU = signal(true);

  // ========== 网络连接配置 (6个) ==========
  final networkName = signal('');
  final networkSecret = signal('');
  final listeners = signal<List<String>>([]);
  final peer = signal<List<String>>([]);
  final defaultProtocol = signal('');
  final devName = signal('');

  // ========== 功能开关配置 (9个) ==========
  final enableEncryption = signal(true);
  final enableIpv6 = signal(true);
  final mtu = signal(1360);
  final latencyFirst = signal(false);
  final enableExitNode = signal(false);
  final noTun = signal(false);
  final enableSocks5 = signal(false);
  final socks5Port = signal(1080);
  final useSmoltcp = signal(false);
  final dataCompressAlgo = signal(1);
  final cidrproxy = signal<List<String>>([]);

  // ========== 高级网络配置 (10个) ==========
  final relayNetworkWhitelist = signal('');
  final disableP2p = signal(false);
  /// Windows：捕获局域网 UDP 广播并转发到虚拟网（EasyTier `enable_udp_broadcast_relay`）。
  final enableUdpBroadcastRelay = signal(false);
  final privateMode = signal(false);
  final enableQuicProxy = signal(false);
  final disableQuicInput = signal(false);
  final relayAllPeerRpc = signal(false);
  final disableUdpHolePunching = signal(false);
  final disableTcpHolePunching = signal(false);
  final disableSymHolePunching = signal(false);
  final multiThread = signal(true);

  // ========== 代理相关配置 (6个) ==========
  final bindDevice = signal(false);
  final enableKcpProxy = signal(false);
  final disableKcpInput = signal(false);
  final disableRelayKcp = signal(false);
  final proxyForwardBySystem = signal(false);
  final acceptDns = signal(false);

  // ========== 白名单配置 (2个) ==========
  final tcpWhitelist = signal('');
  final udpWhitelist = signal('');

  // ========== 简单的状态更新方法 ==========

  void updateIpv4(String value) => ipv4.value = value;
  void updateDhcp(bool value) => dhcp.value = value;
  void updateEnableEncryption(bool value) => enableEncryption.value = value;
  void updateMtu(int value) => mtu.value = value;
  void updateLatencyFirst(bool value) => latencyFirst.value = value;

  void applyFrom(NetConfig config, {required bool autoSetMtu}) {
    netns.value = config.netns;
    hostname.value = config.hostname;
    instanceName.value = config.instance_name;
    ipv4.value = config.ipv4;
    dhcp.value = config.dhcp;
    networkName.value = config.network_name;
    networkSecret.value = config.network_secret;
    listeners.value = List<String>.from(config.listeners);
    peer.value = List<String>.from(config.peer);
    defaultProtocol.value = config.default_protocol;
    devName.value = config.dev_name;
    enableEncryption.value = config.enable_encryption;
    enableIpv6.value = config.enable_ipv6;
    mtu.value = config.mtu;
    latencyFirst.value = config.latency_first;
    enableExitNode.value = config.enable_exit_node;
    noTun.value = config.no_tun;
    enableSocks5.value = config.enable_socks5;
    socks5Port.value = normalizeSocks5Port(config.socks5_port);
    useSmoltcp.value = config.use_smoltcp;
    dataCompressAlgo.value = config.data_compress_algo;
    cidrproxy.value = List<String>.from(config.cidrproxy);
    relayNetworkWhitelist.value = config.relay_network_whitelist;
    disableP2p.value = config.disable_p2p;
    enableUdpBroadcastRelay.value = config.enable_udp_broadcast_relay;
    privateMode.value = config.private_mode;
    enableQuicProxy.value = config.enable_quic_proxy;
    disableQuicInput.value = config.disable_quic_input;
    relayAllPeerRpc.value = config.relay_all_peer_rpc;
    disableUdpHolePunching.value = config.disable_udp_hole_punching;
    disableTcpHolePunching.value = config.disable_tcp_hole_punching;
    disableSymHolePunching.value = config.disable_sym_hole_punching;
    multiThread.value = config.multi_thread;
    bindDevice.value = config.bind_device;
    enableKcpProxy.value = config.enable_kcp_proxy;
    disableKcpInput.value = config.disable_kcp_input;
    disableRelayKcp.value = config.disable_relay_kcp;
    proxyForwardBySystem.value = config.proxy_forward_by_system;
    acceptDns.value = config.accept_dns;
    tcpWhitelist.value = config.tcp_whitelist;
    udpWhitelist.value = config.udp_whitelist;
    autoSetMTU.value = autoSetMtu;
  }
}
