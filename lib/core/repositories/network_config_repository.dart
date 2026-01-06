import 'package:astral/core/database/app_data.dart';

/// 网络配置的数据持久化（29个字段）
class NetworkConfigRepository {
  final AppDatabase _db;

  NetworkConfigRepository(this._db);

  // ========== 基础网络配置读取 ==========

  Future<String> getNetns() => _db.netConfigSetting.getNetns();
  Future<String> getHostname() => _db.netConfigSetting.getHostname();
  Future<String> getInstanceName() => _db.netConfigSetting.getInstanceName();
  Future<String> getIpv4() => _db.netConfigSetting.getIpv4();
  Future<bool> getDhcp() => _db.netConfigSetting.getDhcp();

  // ========== 网络连接配置读取 ==========

  Future<String> getNetworkName() => _db.netConfigSetting.getNetworkName();
  Future<String> getNetworkSecret() => _db.netConfigSetting.getNetworkSecret();
  Future<List<String>> getListeners() => _db.netConfigSetting.getListeners();
  Future<List<String>> getPeer() => _db.netConfigSetting.getPeer();
  Future<String> getDefaultProtocol() =>
      _db.netConfigSetting.getDefaultProtocol();
  Future<String> getDevName() => _db.netConfigSetting.getDevName();

  // ========== 功能开关配置读取 ==========

  Future<bool> getEnableEncryption() =>
      _db.netConfigSetting.getEnableEncryption();
  Future<bool> getEnableIpv6() => _db.netConfigSetting.getEnableIpv6();
  Future<int> getMtu() => _db.netConfigSetting.getMtu();
  Future<bool> getLatencyFirst() => _db.netConfigSetting.getLatencyFirst();
  Future<bool> getEnableExitNode() => _db.netConfigSetting.getEnableExitNode();
  Future<bool> getNoTun() => _db.netConfigSetting.getNoTun();
  Future<bool> getUseSmoltcp() => _db.netConfigSetting.getUseSmoltcp();
  Future<int> getDataCompressAlgo() =>
      _db.netConfigSetting.getDataCompressAlgo();

  // ========== 高级网络配置读取 ==========

  Future<String> getRelayNetworkWhitelist() =>
      _db.netConfigSetting.getRelayNetworkWhitelist();
  Future<bool> getDisableP2p() => _db.netConfigSetting.getDisableP2p();
  Future<bool> getPrivateMode() => _db.netConfigSetting.getPrivateMode();
  Future<bool> getEnableQuicProxy() =>
      _db.netConfigSetting.getEnableQuicProxy();
  Future<bool> getDisableQuicInput() =>
      _db.netConfigSetting.getDisableQuicInput();
  Future<bool> getRelayAllPeerRpc() =>
      _db.netConfigSetting.getRelayAllPeerRpc();
  Future<bool> getDisableUdpHolePunching() =>
      _db.netConfigSetting.getDisableUdpHolePunching();
  Future<bool> getDisableTcpHolePunching() =>
      _db.netConfigSetting.getDisableTcpHolePunching();
  Future<bool> getDisableSymHolePunching() =>
      _db.netConfigSetting.getDisableSymHolePunching();
  Future<bool> getMultiThread() => _db.netConfigSetting.getMultiThread();

  // ========== 代理相关配置读取 ==========

  Future<List<String>> getCidrproxy() => _db.netConfigSetting.getCidrproxy();
  Future<bool> getBindDevice() => _db.netConfigSetting.getBindDevice();
  Future<bool> getEnableKcpProxy() => _db.netConfigSetting.getEnableKcpProxy();
  Future<bool> getDisableKcpInput() =>
      _db.netConfigSetting.getDisableKcpInput();
  Future<bool> getDisableRelayKcp() =>
      _db.netConfigSetting.getDisableRelayKcp();
  Future<bool> getProxyForwardBySystem() =>
      _db.netConfigSetting.getProxyForwardBySystem();
  Future<bool> getAcceptDns() => _db.netConfigSetting.getAcceptDns();
  Future<String> getTcpWhitelist() => _db.netConfigSetting.getTcpWhitelist();
  Future<String> getUdpWhitelist() => _db.netConfigSetting.getUdpWhitelist();

  // ========== 基础网络配置写入 ==========

  Future<void> updateNetns(String value) =>
      _db.netConfigSetting.updateNetns(value);
  Future<void> updateHostname(String value) =>
      _db.netConfigSetting.updateHostname(value);
  Future<void> updateInstanceName(String value) =>
      _db.netConfigSetting.updateInstanceName(value);
  Future<void> updateIpv4(String value) =>
      _db.netConfigSetting.updateIpv4(value);
  Future<void> updateDhcp(bool value) => _db.netConfigSetting.updateDhcp(value);

  // ========== 网络连接配置写入 ==========

  Future<void> updateNetworkName(String value) =>
      _db.netConfigSetting.updateNetworkName(value);
  Future<void> updateNetworkSecret(String value) =>
      _db.netConfigSetting.updateNetworkSecret(value);
  Future<void> updateListeners(List<String> value) =>
      _db.netConfigSetting.updateListeners(value);
  Future<void> updatePeer(List<String> value) =>
      _db.netConfigSetting.updatePeer(value);
  Future<void> updateDefaultProtocol(String value) =>
      _db.netConfigSetting.updateDefaultProtocol(value);
  Future<void> updateDevName(String value) =>
      _db.netConfigSetting.updateDevName(value);

  // ========== 功能开关配置写入 ==========

  Future<void> updateEnableEncryption(bool value) =>
      _db.netConfigSetting.updateEnableEncryption(value);
  Future<void> updateEnableIpv6(bool value) =>
      _db.netConfigSetting.updateEnableIpv6(value);
  Future<void> updateMtu(int value) => _db.netConfigSetting.updateMtu(value);
  Future<void> updateLatencyFirst(bool value) =>
      _db.netConfigSetting.updateLatencyFirst(value);
  Future<void> updateEnableExitNode(bool value) =>
      _db.netConfigSetting.updateEnableExitNode(value);
  Future<void> updateNoTun(bool value) =>
      _db.netConfigSetting.updateNoTun(value);
  Future<void> updateUseSmoltcp(bool value) =>
      _db.netConfigSetting.updateUseSmoltcp(value);
  Future<void> updateDataCompressAlgo(int value) =>
      _db.netConfigSetting.updateDataCompressAlgo(value);

  // ========== 高级网络配置写入 ==========

  Future<void> updateRelayNetworkWhitelist(String value) =>
      _db.netConfigSetting.updateRelayNetworkWhitelist(value);
  Future<void> updateDisableP2p(bool value) =>
      _db.netConfigSetting.updateDisableP2p(value);
  Future<void> updatePrivateMode(bool value) =>
      _db.netConfigSetting.updatePrivateMode(value);
  Future<void> updateRelayAllPeerRpc(bool value) =>
      _db.netConfigSetting.updateRelayAllPeerRpc(value);
  Future<void> updateDisableUdpHolePunching(bool value) =>
      _db.netConfigSetting.updateDisableUdpHolePunching(value);
  Future<void> updateDisableTcpHolePunching(bool value) =>
      _db.netConfigSetting.updateDisableTcpHolePunching(value);
  Future<void> updateDisableSymHolePunching(bool value) =>
      _db.netConfigSetting.updateDisableSymHolePunching(value);
  Future<void> updateMultiThread(bool value) =>
      _db.netConfigSetting.updateMultiThread(value);
  Future<void> updateEnableQuicProxy(bool value) =>
      _db.netConfigSetting.updateEnableQuicProxy(value);
  Future<void> updateDisableQuicInput(bool value) =>
      _db.netConfigSetting.updateDisableQuicInput(value);

  // ========== 代理相关配置写入 ==========

  Future<void> updateBindDevice(bool value) =>
      _db.netConfigSetting.updateBindDevice(value);
  Future<void> updateEnableKcpProxy(bool value) =>
      _db.netConfigSetting.updateEnableKcpProxy(value);
  Future<void> updateDisableKcpInput(bool value) =>
      _db.netConfigSetting.updateDisableKcpInput(value);
  Future<void> updateDisableRelayKcp(bool value) =>
      _db.netConfigSetting.updateDisableRelayKcp(value);
  Future<void> updateProxyForwardBySystem(bool value) =>
      _db.netConfigSetting.updateProxyForwardBySystem(value);
  Future<void> updateAcceptDns(bool value) =>
      _db.netConfigSetting.updateAcceptDns(value);
  Future<void> updateCidrproxy(int index, String value) =>
      _db.netConfigSetting.updateCidrproxy(index, value);
  Future<void> setCidrproxy(List<String> value) =>
      _db.netConfigSetting.setCidrproxy(value);
  Future<void> setAutoSetMTU(bool value) =>
      _db.AllSettings.setAutoSetMTU(value);
  Future<void> updateTcpWhitelist(String value) =>
      _db.netConfigSetting.updateTcpWhitelist(value);
  Future<void> updateUdpWhitelist(String value) =>
      _db.netConfigSetting.updateUdpWhitelist(value);

  // ========== 批量操作 ==========

  /// 批量加载所有网络配置
  Future<NetworkConfig> loadAll() async {
    return NetworkConfig(
      netns: await getNetns(),
      hostname: await getHostname(),
      instanceName: await getInstanceName(),
      ipv4: await getIpv4(),
      dhcp: await getDhcp(),
      networkName: await getNetworkName(),
      networkSecret: await getNetworkSecret(),
      listeners: await getListeners(),
      peer: await getPeer(),
      defaultProtocol: await getDefaultProtocol(),
      devName: await getDevName(),
      enableEncryption: await getEnableEncryption(),
      enableIpv6: await getEnableIpv6(),
      mtu: await getMtu(),
      latencyFirst: await getLatencyFirst(),
      enableExitNode: await getEnableExitNode(),
      noTun: await getNoTun(),
      useSmoltcp: await getUseSmoltcp(),
      dataCompressAlgo: await getDataCompressAlgo(),
      cidrproxy: await getCidrproxy(),
      relayNetworkWhitelist: await getRelayNetworkWhitelist(),
      disableP2p: await getDisableP2p(),
      privateMode: await getPrivateMode(),
      enableQuicProxy: await getEnableQuicProxy(),
      disableQuicInput: await getDisableQuicInput(),
      relayAllPeerRpc: await getRelayAllPeerRpc(),
      disableUdpHolePunching: await getDisableUdpHolePunching(),
      disableTcpHolePunching: await getDisableTcpHolePunching(),
      disableSymHolePunching: await getDisableSymHolePunching(),
      multiThread: await getMultiThread(),
      bindDevice: await getBindDevice(),
      enableKcpProxy: await getEnableKcpProxy(),
      disableKcpInput: await getDisableKcpInput(),
      disableRelayKcp: await getDisableRelayKcp(),
      proxyForwardBySystem: await getProxyForwardBySystem(),
      acceptDns: await getAcceptDns(),
      tcpWhitelist: await getTcpWhitelist(),
      udpWhitelist: await getUdpWhitelist(),
    );
  }
}

/// 网络配置数据类
class NetworkConfig {
  final String netns;
  final String hostname;
  final String instanceName;
  final String ipv4;
  final bool dhcp;
  final String networkName;
  final String networkSecret;
  final List<String> listeners;
  final List<String> peer;
  final String defaultProtocol;
  final String devName;
  final bool enableEncryption;
  final bool enableIpv6;
  final int mtu;
  final bool latencyFirst;
  final bool enableExitNode;
  final bool noTun;
  final bool useSmoltcp;
  final int dataCompressAlgo;
  final List<String> cidrproxy;
  final String relayNetworkWhitelist;
  final bool disableP2p;
  final bool privateMode;
  final bool enableQuicProxy;
  final bool disableQuicInput;
  final bool relayAllPeerRpc;
  final bool disableUdpHolePunching;
  final bool disableTcpHolePunching;
  final bool disableSymHolePunching;
  final bool multiThread;
  final bool bindDevice;
  final bool enableKcpProxy;
  final bool disableKcpInput;
  final bool disableRelayKcp;
  final bool proxyForwardBySystem;
  final bool acceptDns;
  final String tcpWhitelist;
  final String udpWhitelist;

  NetworkConfig({
    required this.netns,
    required this.hostname,
    required this.instanceName,
    required this.ipv4,
    required this.dhcp,
    required this.networkName,
    required this.networkSecret,
    required this.listeners,
    required this.peer,
    required this.defaultProtocol,
    required this.devName,
    required this.enableEncryption,
    required this.enableIpv6,
    required this.mtu,
    required this.latencyFirst,
    required this.enableExitNode,
    required this.noTun,
    required this.useSmoltcp,
    required this.dataCompressAlgo,
    required this.cidrproxy,
    required this.relayNetworkWhitelist,
    required this.disableP2p,
    required this.privateMode,
    required this.enableQuicProxy,
    required this.disableQuicInput,
    required this.relayAllPeerRpc,
    required this.disableUdpHolePunching,
    required this.disableTcpHolePunching,
    required this.disableSymHolePunching,
    required this.multiThread,
    required this.bindDevice,
    required this.enableKcpProxy,
    required this.disableKcpInput,
    required this.disableRelayKcp,
    required this.proxyForwardBySystem,
    required this.acceptDns,
    required this.tcpWhitelist,
    required this.udpWhitelist,
  });
}
