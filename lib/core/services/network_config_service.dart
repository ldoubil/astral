import 'package:astral/core/states/network_config_state.dart';
import 'package:astral/core/repositories/network_config_repository.dart';

/// 网络配置服务：协调NetworkConfigState和NetworkConfigRepository
class NetworkConfigService {
  final NetworkConfigState state;
  final NetworkConfigRepository _repository;

  NetworkConfigService(this.state, this._repository);

  // ========== 初始化（批量加载） ==========

  Future<void> init() async {
    final config = await _repository.loadAll();

    // 批量更新状态
    state.netns.value = config.netns;
    state.hostname.value = config.hostname;
    state.instanceName.value = config.instanceName;
    state.ipv4.value = config.ipv4;
    state.dhcp.value = config.dhcp;
    state.networkName.value = config.networkName;
    state.networkSecret.value = config.networkSecret;
    state.listeners.value = config.listeners;
    state.peer.value = config.peer;
    state.defaultProtocol.value = config.defaultProtocol;
    state.devName.value = config.devName;
    state.enableEncryption.value = config.enableEncryption;
    state.enableIpv6.value = config.enableIpv6;
    state.mtu.value = config.mtu;
    state.latencyFirst.value = config.latencyFirst;
    state.enableExitNode.value = config.enableExitNode;
    state.noTun.value = config.noTun;
    state.useSmoltcp.value = config.useSmoltcp;
    state.dataCompressAlgo.value = config.dataCompressAlgo;
    state.cidrproxy.value = config.cidrproxy;
    state.relayNetworkWhitelist.value = config.relayNetworkWhitelist;
    state.disableP2p.value = config.disableP2p;
    state.privateMode.value = config.privateMode;
    state.enableQuicProxy.value = config.enableQuicProxy;
    state.disableQuicInput.value = config.disableQuicInput;
    state.relayAllPeerRpc.value = config.relayAllPeerRpc;
    state.disableUdpHolePunching.value = config.disableUdpHolePunching;
    state.disableTcpHolePunching.value = config.disableTcpHolePunching;
    state.disableSymHolePunching.value = config.disableSymHolePunching;
    state.multiThread.value = config.multiThread;
    state.bindDevice.value = config.bindDevice;
    state.enableKcpProxy.value = config.enableKcpProxy;
    state.disableKcpInput.value = config.disableKcpInput;
    state.disableRelayKcp.value = config.disableRelayKcp;
    state.proxyForwardBySystem.value = config.proxyForwardBySystem;
    state.acceptDns.value = config.acceptDns;
    state.tcpWhitelist.value = config.tcpWhitelist;
    state.udpWhitelist.value = config.udpWhitelist;
  }

  // ========== 基础配置方法 ==========

  Future<void> updateNetns(String value) async {
    state.netns.value = value;
    await _repository.updateNetns(value);
  }

  Future<void> updateHostname(String value) async {
    state.updateHostname(value);
    await _repository.updateHostname(value);
  }

  Future<void> updateInstanceName(String value) async {
    state.updateInstanceName(value);
    await _repository.updateInstanceName(value);
  }

  Future<void> updateIpv4(String value) async {
    state.updateIpv4(value);
    await _repository.updateIpv4(value);
  }

  Future<void> updateDhcp(bool value) async {
    state.updateDhcp(value);
    await _repository.updateDhcp(value);
  }

  Future<void> updateNetworkName(String value) async {
    state.updateNetworkName(value);
    await _repository.updateNetworkName(value);
  }

  Future<void> updateNetworkSecret(String value) async {
    state.updateNetworkSecret(value);
    await _repository.updateNetworkSecret(value);
  }

  Future<void> updateListeners(List<String> value) async {
    state.listeners.value = value;
    await _repository.updateListeners(value);
  }

  Future<void> updatePeer(List<String> value) async {
    state.peer.value = value;
    await _repository.updatePeer(value);
  }

  Future<void> setAutoSetMTU(bool value) async {
    state.autoSetMTU.value = value;
    await _repository.setAutoSetMTU(value);
  }

  Future<void> updateDefaultProtocol(String value) async {
    state.defaultProtocol.value = value;
    await _repository.updateDefaultProtocol(value);
  }

  Future<void> updateDevName(String value) async {
    state.devName.value = value;
    await _repository.updateDevName(value);
  }

  // ========== 加密与MTU（特殊处理） ==========

  Future<void> updateEnableEncryption(bool value) async {
    state.updateEnableEncryption(value);
    await _repository.updateEnableEncryption(value);

    // 自动调整MTU
    if (value) {
      await updateMtu(1360);
    } else {
      await updateMtu(1380);
    }
  }

  Future<void> updateMtu(int value) async {
    state.updateMtu(value);
    await _repository.updateMtu(value);
  }

  // ========== 功能开关 ==========

  Future<void> updateEnableIpv6(bool value) async {
    state.enableIpv6.value = value;
    await _repository.updateEnableIpv6(value);
  }

  Future<void> updateLatencyFirst(bool value) async {
    state.updateLatencyFirst(value);
    await _repository.updateLatencyFirst(value);
  }

  Future<void> updateEnableExitNode(bool value) async {
    state.updateEnableExitNode(value);
    await _repository.updateEnableExitNode(value);
  }

  Future<void> updateNoTun(bool value) async {
    state.noTun.value = value;
    await _repository.updateNoTun(value);
  }

  Future<void> updateUseSmoltcp(bool value) async {
    state.useSmoltcp.value = value;
    await _repository.updateUseSmoltcp(value);
  }

  Future<void> updateDataCompressAlgo(int value) async {
    state.dataCompressAlgo.value = value;
    await _repository.updateDataCompressAlgo(value);
  }

  // ========== 高级配置 ==========

  Future<void> updateRelayNetworkWhitelist(String value) async {
    state.relayNetworkWhitelist.value = value;
    await _repository.updateRelayNetworkWhitelist(value);
  }

  Future<void> updateDisableP2p(bool value) async {
    state.disableP2p.value = value;
    await _repository.updateDisableP2p(value);
  }

  Future<void> updatePrivateMode(bool value) async {
    state.privateMode.value = value;
    await _repository.updatePrivateMode(value);
  }

  Future<void> updateEnableQuicProxy(bool value) async {
    state.enableQuicProxy.value = value;
    await _repository.updateEnableQuicProxy(value);
  }

  Future<void> updateDisableQuicInput(bool value) async {
    state.disableQuicInput.value = value;
    await _repository.updateDisableQuicInput(value);
  }

  Future<void> updateRelayAllPeerRpc(bool value) async {
    state.relayAllPeerRpc.value = value;
    await _repository.updateRelayAllPeerRpc(value);
  }

  Future<void> updateDisableUdpHolePunching(bool value) async {
    state.disableUdpHolePunching.value = value;
    await _repository.updateDisableUdpHolePunching(value);
  }

  Future<void> updateDisableTcpHolePunching(bool value) async {
    state.disableTcpHolePunching.value = value;
    await _repository.updateDisableTcpHolePunching(value);
  }

  Future<void> updateDisableSymHolePunching(bool value) async {
    state.disableSymHolePunching.value = value;
    await _repository.updateDisableSymHolePunching(value);
  }

  Future<void> updateMultiThread(bool value) async {
    state.updateMultiThread(value);
    await _repository.updateMultiThread(value);
  }

  // ========== 代理相关 ==========

  Future<void> addCidrproxy(String cidr) async {
    state.addCidrProxy(cidr);
    await _repository.setCidrproxy(state.cidrproxy.value);
  }

  Future<void> deleteCidrproxy(int index) async {
    state.removeCidrProxy(index);
    await _repository.setCidrproxy(state.cidrproxy.value);
  }

  Future<void> updateCidrproxy(int index, String cidr) async {
    await _repository.updateCidrproxy(index, cidr);
    final updated = await _repository.getCidrproxy();
    state.cidrproxy.value = updated;
  }

  Future<void> updateBindDevice(bool value) async {
    state.bindDevice.value = value;
    await _repository.updateBindDevice(value);
  }

  Future<void> updateEnableKcpProxy(bool value) async {
    state.enableKcpProxy.value = value;
    await _repository.updateEnableKcpProxy(value);
  }

  Future<void> updateDisableKcpInput(bool value) async {
    state.disableKcpInput.value = value;
    await _repository.updateDisableKcpInput(value);
  }

  Future<void> updateDisableRelayKcp(bool value) async {
    state.disableRelayKcp.value = value;
    await _repository.updateDisableRelayKcp(value);
  }

  Future<void> updateProxyForwardBySystem(bool value) async {
    state.proxyForwardBySystem.value = value;
    await _repository.updateProxyForwardBySystem(value);
  }

  Future<void> updateAcceptDns(bool value) async {
    state.acceptDns.value = value;
    await _repository.updateAcceptDns(value);
  }

  Future<void> updateTcpWhitelist(String value) async {
    state.tcpWhitelist.value = value;
    await _repository.updateTcpWhitelist(value);
  }

  Future<void> updateUdpWhitelist(String value) async {
    state.udpWhitelist.value = value;
    await _repository.updateUdpWhitelist(value);
  }
}
