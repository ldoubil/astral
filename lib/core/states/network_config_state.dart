import 'package:signals_flutter/signals_flutter.dart';

/// 网络配置状态（纯Signal，29个字段）
class NetworkConfigState {
  // ========== 基础网络配置 (7个) ==========
  final netns = signal('');
  final hostname = signal('');
  final instanceName = signal('default');
  final ipv4 = signal('');
  final ipv6 = signal('');
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
  final useSmoltcp = signal(false);
  final dataCompressAlgo = signal(1);
  final cidrproxy = signal<List<String>>([]);

  // ========== 高级网络配置 (9个) ==========
  final relayNetworkWhitelist = signal('');
  final disableP2p = signal(false);
  final privateMode = signal(false);
  final enableQuicProxy = signal(false);
  final disableQuicInput = signal(false);
  final relayAllPeerRpc = signal(false);
  final disableUdpHolePunching = signal(false);
  final disableSymHolePunching = signal(false);
  final multiThread = signal(true);

  // ========== 代理相关配置 (6个) ==========
  final bindDevice = signal(false);
  final enableKcpProxy = signal(false);
  final disableKcpInput = signal(false);
  final disableRelayKcp = signal(false);
  final proxyForwardBySystem = signal(false);
  final acceptDns = signal(false);

  // ========== 简单的状态更新方法 ==========

  void updateIpv4(String value) => ipv4.value = value;
  void updateDhcp(bool value) => dhcp.value = value;
  void updateNetworkName(String value) => networkName.value = value;
  void updateNetworkSecret(String value) => networkSecret.value = value;
  void updateHostname(String value) => hostname.value = value;
  void updateInstanceName(String value) => instanceName.value = value;
  void updateEnableEncryption(bool value) => enableEncryption.value = value;
  void updateMtu(int value) => mtu.value = value;
  void updateMultiThread(bool value) => multiThread.value = value;
  void updateLatencyFirst(bool value) => latencyFirst.value = value;
  void updateEnableExitNode(bool value) => enableExitNode.value = value;

  // 列表操作
  void addListener(String listener) {
    final list = List<String>.from(listeners.value);
    list.add(listener);
    listeners.value = list;
  }

  void removeListener(int index) {
    final list = List<String>.from(listeners.value);
    list.removeAt(index);
    listeners.value = list;
  }

  void addCidrProxy(String cidr) {
    final list = List<String>.from(cidrproxy.value);
    list.add(cidr);
    cidrproxy.value = list;
  }

  void removeCidrProxy(int index) {
    final list = List<String>.from(cidrproxy.value);
    list.removeAt(index);
    cidrproxy.value = list;
  }

  // Computed Signal 示例
  late final isConfigured = computed(() {
    return ipv4.value.isNotEmpty &&
        networkName.value.isNotEmpty &&
        networkSecret.value.isNotEmpty;
  });

  late final displayIp = computed(() {
    return dhcp.value ? 'DHCP (自动)' : ipv4.value;
  });
}
