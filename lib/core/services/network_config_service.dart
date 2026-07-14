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
    state.enableSocks5.value = config.enableSocks5;
    state.socks5Port.value = config.socks5Port;
    state.useSmoltcp.value = config.useSmoltcp;
    state.dataCompressAlgo.value = config.dataCompressAlgo;
    state.cidrproxy.value = config.cidrproxy;
    state.relayNetworkWhitelist.value = config.relayNetworkWhitelist;
    state.disableP2p.value = config.disableP2p;
    state.enableUdpBroadcastRelay.value = config.enableUdpBroadcastRelay;
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
    state.autoSetMTU.value = await _repository.getAutoSetMTU();
  }

  // ========== 仍有 UI / 分享导入调用的写入 ==========

  Future<void> updateIpv4(String value) async {
    state.updateIpv4(value);
    await _repository.updateIpv4(value);
  }

  Future<void> updateDhcp(bool value) async {
    state.updateDhcp(value);
    await _repository.updateDhcp(value);
  }

  Future<void> setAutoSetMTU(bool value) async {
    state.autoSetMTU.value = value;
    await _repository.setAutoSetMTU(value);
  }

  Future<void> updateDefaultProtocol(String value) async {
    state.defaultProtocol.value = value;
    await _repository.updateDefaultProtocol(value);
  }

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

  Future<void> updateLatencyFirst(bool value) async {
    state.updateLatencyFirst(value);
    await _repository.updateLatencyFirst(value);
  }

  Future<void> updateNoTun(bool value) async {
    state.noTun.value = value;
    await _repository.updateNoTun(value);
  }

  Future<void> updateEnableSocks5(bool value) async {
    state.enableSocks5.value = value;
    await _repository.updateEnableSocks5(value);
  }

  Future<void> updateSocks5Port(int value) async {
    state.socks5Port.value = value;
    await _repository.updateSocks5Port(value);
  }

  Future<void> updateDataCompressAlgo(int value) async {
    state.dataCompressAlgo.value = value;
    await _repository.updateDataCompressAlgo(value);
  }

  Future<void> updateDisableP2p(bool value) async {
    state.disableP2p.value = value;
    await _repository.updateDisableP2p(value);
  }

  Future<void> updateEnableUdpBroadcastRelay(bool value) async {
    state.enableUdpBroadcastRelay.value = value;
    await _repository.updateEnableUdpBroadcastRelay(value);
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

  Future<void> updateBindDevice(bool value) async {
    state.bindDevice.value = value;
    await _repository.updateBindDevice(value);
  }

  Future<void> updateEnableKcpProxy(bool value) async {
    state.enableKcpProxy.value = value;
    await _repository.updateEnableKcpProxy(value);
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
