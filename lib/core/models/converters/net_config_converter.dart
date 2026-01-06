import 'package:isar_community/isar.dart';
import 'package:astral/core/models/net_config.dart';

class NetConfigRepository {
  final Isar _isar;

  NetConfigRepository(this._isar) {
    init();
  }

  Future<void> init() async {
    final count = await _isar.netConfigs.count();
    if (count == 0) {
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(NetConfig());
      });
    }
  }

  // 更新网络命名空间
  Future<void> updateNetns(String netns) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.netns = netns;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取网络命名空间
  Future<String> getNetns() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.netns ?? '';
  }

  // 更新主机名
  Future<void> updateHostname(String hostname) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.hostname = hostname;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取主机名
  Future<String> getHostname() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.hostname ?? '';
  }

  // 更新实例名称
  Future<void> updateInstanceName(String instanceName) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.instance_name = instanceName;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取实例名称
  Future<String> getInstanceName() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.instance_name ?? 'default';
  }

  // 更新IPv4地址
  Future<void> updateIpv4(String ipv4) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.ipv4 = ipv4;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取IPv4地址
  Future<String> getIpv4() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.ipv4 ?? '';
  }

  // 更新DHCP设置
  Future<void> updateDhcp(bool dhcp) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.dhcp = dhcp;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取cidrproxy
  Future<List<String>> getCidrproxy() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.cidrproxy ?? [];
  }

  // 更新cidrproxy
  Future<void> updateCidrproxy(int index, String cidr) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.cidrproxy[index] = cidr;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // setCidrproxy
  Future<void> setCidrproxy(List<String> cidrproxy) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.cidrproxy = cidrproxy;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取DHCP设置
  Future<bool> getDhcp() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.dhcp ?? false;
  }

  // 更新网络名称
  Future<void> updateNetworkName(String networkName) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.network_name = networkName;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取网络名称
  Future<String> getNetworkName() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.network_name ?? '';
  }

  // 更新网络密钥
  Future<void> updateNetworkSecret(String networkSecret) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.network_secret = networkSecret;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取网络密钥
  Future<String> getNetworkSecret() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.network_secret ?? '';
  }

  // 更新监听端口列表
  Future<void> updateListeners(List<String> listeners) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.listeners = listeners;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取监听端口列表
  Future<List<String>> getListeners() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.listeners ?? [];
  }

  // 更新对等节点列表
  Future<void> updatePeer(List<String> peer) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.peer = peer;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取对等节点列表
  Future<List<String>> getPeer() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.peer ?? [];
  }

  // 更新默认协议
  Future<void> updateDefaultProtocol(String defaultProtocol) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.default_protocol = defaultProtocol;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取默认协议
  Future<String> getDefaultProtocol() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.default_protocol ?? '';
  }

  // 更新设备名称
  Future<void> updateDevName(String devName) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.dev_name = devName;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取设备名称
  Future<String> getDevName() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.dev_name ?? '';
  }

  // 更新加密设置
  Future<void> updateEnableEncryption(bool enableEncryption) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.enable_encryption = enableEncryption;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取加密设置
  Future<bool> getEnableEncryption() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.enable_encryption ?? true;
  }

  // 更新IPv6设置
  Future<void> updateEnableIpv6(bool enableIpv6) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.enable_ipv6 = enableIpv6;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取IPv6设置
  Future<bool> getEnableIpv6() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.enable_ipv6 ?? true;
  }

  // 更新MTU值
  Future<void> updateMtu(int mtu) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.mtu = mtu;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取MTU值
  Future<int> getMtu() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.mtu ?? 1400;
  }

  // 更新延迟优先设置
  Future<void> updateLatencyFirst(bool latencyFirst) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.latency_first = latencyFirst;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取延迟优先设置
  Future<bool> getLatencyFirst() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.latency_first ?? false;
  }

  // 更新出口节点设置
  Future<void> updateEnableExitNode(bool enableExitNode) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.enable_exit_node = enableExitNode;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取出口节点设置
  Future<bool> getEnableExitNode() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.enable_exit_node ?? false;
  }

  // 更新TUN设备禁用设置
  Future<void> updateNoTun(bool noTun) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.no_tun = noTun;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取TUN设备禁用设置
  Future<bool> getNoTun() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.no_tun ?? false;
  }

  // 更新smoltcp网络栈设置
  Future<void> updateUseSmoltcp(bool useSmoltcp) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.use_smoltcp = useSmoltcp;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取smoltcp网络栈设置
  Future<bool> getUseSmoltcp() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.use_smoltcp ?? false;
  }

  // 更新中继网络白名单
  Future<void> updateRelayNetworkWhitelist(String relayNetworkWhitelist) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.relay_network_whitelist = relayNetworkWhitelist;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取中继网络白名单
  Future<String> getRelayNetworkWhitelist() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.relay_network_whitelist ?? '';
  }

  // 更新P2P禁用设置
  Future<void> updateDisableP2p(bool disableP2p) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.disable_p2p = disableP2p;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取P2P禁用设置
  Future<bool> getDisableP2p() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.disable_p2p ?? false;
  }

  // 更新私有模式设置
  Future<void> updatePrivateMode(bool privateMode) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.private_mode = privateMode;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取私有模式设置
  Future<bool> getPrivateMode() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.private_mode ?? false;
  }

  // 更新QUIC代理设置
  Future<void> updateEnableQuicProxy(bool enableQuicProxy) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.enable_quic_proxy = enableQuicProxy;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取QUIC代理设置
  Future<bool> getEnableQuicProxy() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.enable_quic_proxy ?? false;
  }

  // 更新禁用QUIC输入设置
  Future<void> updateDisableQuicInput(bool disableQuicInput) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.disable_quic_input = disableQuicInput;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取禁用QUIC输入设置
  Future<bool> getDisableQuicInput() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.disable_quic_input ?? false;
  }

  // 更新中继所有对等RPC设置
  Future<void> updateRelayAllPeerRpc(bool relayAllPeerRpc) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.relay_all_peer_rpc = relayAllPeerRpc;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取中继所有对等RPC设置
  Future<bool> getRelayAllPeerRpc() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.relay_all_peer_rpc ?? false;
  }

  // 更新UDP打洞禁用设置
  Future<void> updateDisableUdpHolePunching(bool disableUdpHolePunching) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.disable_udp_hole_punching = disableUdpHolePunching;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取UDP打洞禁用设置
  Future<bool> getDisableUdpHolePunching() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.disable_udp_hole_punching ?? false;
  }

  // 更新TCP打洞禁用设置
  Future<void> updateDisableTcpHolePunching(bool disableTcpHolePunching) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.disable_tcp_hole_punching = disableTcpHolePunching;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取TCP打洞禁用设置
  Future<bool> getDisableTcpHolePunching() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.disable_tcp_hole_punching ?? false;
  }

  // 更新对称NAT打洞禁用设置
  Future<void> updateDisableSymHolePunching(bool disableSymHolePunching) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.disable_sym_hole_punching = disableSymHolePunching;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取对称NAT打洞禁用设置
  Future<bool> getDisableSymHolePunching() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.disable_sym_hole_punching ?? false;
  }

  // 更新多线程设置
  Future<void> updateMultiThread(bool multiThread) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.multi_thread = multiThread;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取多线程设置
  Future<bool> getMultiThread() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.multi_thread ?? true;
  }

  // 更新数据压缩算法
  Future<void> updateDataCompressAlgo(int dataCompressAlgo) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.data_compress_algo = dataCompressAlgo;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取数据压缩算法
  Future<int> getDataCompressAlgo() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.data_compress_algo ?? 1;
  }

  // 更新设备绑定设置
  Future<void> updateBindDevice(bool bindDevice) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.bind_device = bindDevice;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取设备绑定设置
  Future<bool> getBindDevice() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.bind_device ?? false;
  }

  // 更新KCP代理启用设置
  Future<void> updateEnableKcpProxy(bool enableKcpProxy) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.enable_kcp_proxy = enableKcpProxy;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取KCP代理启用设置
  Future<bool> getEnableKcpProxy() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.enable_kcp_proxy ?? true;
  }

  // 更新KCP输入禁用设置
  Future<void> updateDisableKcpInput(bool disableKcpInput) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.disable_kcp_input = disableKcpInput;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取KCP输入禁用设置
  Future<bool> getDisableKcpInput() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.disable_kcp_input ?? false;
  }

  // 更新中继KCP禁用设置
  Future<void> updateDisableRelayKcp(bool disableRelayKcp) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.disable_relay_kcp = disableRelayKcp;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取中继KCP禁用设置
  Future<bool> getDisableRelayKcp() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.disable_relay_kcp ?? true;
  }

  // 更新系统代理转发设置
  Future<void> updateProxyForwardBySystem(bool proxyForwardBySystem) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.proxy_forward_by_system = proxyForwardBySystem;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取系统代理转发设置
  Future<bool> getProxyForwardBySystem() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.proxy_forward_by_system ?? false;
  }

  /// accept_dns
  Future<void> updateAcceptDns(bool acceptDns) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.accept_dns = acceptDns;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  Future<bool> getAcceptDns() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.accept_dns ?? false;
  }

  // 获取所有连接管理器
  Future<List<ConnectionManager>> getConnectionManagers() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.connectionManagers ?? [];
  }

  // 添加连接管理器
  Future<void> addConnectionManager(ConnectionManager manager) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      // Create a new list instead of adding to the existing fixed-length list
      config.connectionManagers = [...config.connectionManagers, manager];
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 更新连接管理器
  Future<void> updateConnectionManager(
    int index,
    ConnectionManager manager,
  ) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null &&
        index >= 0 &&
        index < config.connectionManagers.length) {
      // Create a new list with the updated item
      List<ConnectionManager> newList = List.from(config.connectionManagers);
      newList[index] = manager;
      config.connectionManagers = newList;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 删除连接管理器
  Future<void> removeConnectionManager(int index) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null &&
        index >= 0 &&
        index < config.connectionManagers.length) {
      // Create a new list without the item at the specified index
      List<ConnectionManager> newList = List.from(config.connectionManagers);
      newList.removeAt(index);
      config.connectionManagers = newList;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 更新连接管理器启用状态
  Future<void> updateConnectionManagerEnabled(int index, bool enabled) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null &&
        index >= 0 &&
        index < config.connectionManagers.length) {
      config.connectionManagers[index].enabled = enabled;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 更新TCP端口白名单
  Future<void> updateTcpWhitelist(String tcpWhitelist) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.tcp_whitelist = tcpWhitelist;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取TCP端口白名单
  Future<String> getTcpWhitelist() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.tcp_whitelist ?? '';
  }

  // 更新UDP端口白名单
  Future<void> updateUdpWhitelist(String udpWhitelist) async {
    NetConfig? config = await _isar.netConfigs.get(1);
    if (config != null) {
      config.udp_whitelist = udpWhitelist;
      await _isar.writeTxn(() async {
        await _isar.netConfigs.put(config);
      });
    }
  }

  // 获取UDP端口白名单
  Future<String> getUdpWhitelist() async {
    NetConfig? config = await _isar.netConfigs.get(1);
    return config?.udp_whitelist ?? '';
  }
}
