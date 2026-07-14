import 'package:astral/core/database/dao/net_config_dao.dart';
import 'package:astral/core/states/network_config_state.dart';
import 'package:astral/core/repositories/network_config_repository.dart';

/// 网络配置服务：协调 State 与持久化
class NetworkConfigService {
  final NetworkConfigState state;
  final NetworkConfigRepository _repo;

  NetworkConfigService(this.state, this._repo);

  Future<void> init() async {
    final config = await _repo.get();
    state.applyFrom(config, autoSetMtu: await _repo.getAutoSetMTU());
  }

  Future<void> updateIpv4(String value) async {
    state.updateIpv4(value);
    await _repo.update((c) => c.ipv4 = value);
  }

  Future<void> updateDhcp(bool value) async {
    state.updateDhcp(value);
    await _repo.update((c) => c.dhcp = value);
  }

  Future<void> setAutoSetMTU(bool value) async {
    state.autoSetMTU.value = value;
    await _repo.setAutoSetMTU(value);
  }

  Future<void> updateDefaultProtocol(String value) async {
    state.defaultProtocol.value = value;
    await _repo.update((c) => c.default_protocol = value);
  }

  Future<void> updateEnableEncryption(bool value) async {
    state.updateEnableEncryption(value);
    await _repo.update((c) => c.enable_encryption = value);

    if (value) {
      await updateMtu(1360);
    } else {
      await updateMtu(1380);
    }
  }

  Future<void> updateMtu(int value) async {
    state.updateMtu(value);
    await _repo.update((c) => c.mtu = value);
  }

  Future<void> updateLatencyFirst(bool value) async {
    state.updateLatencyFirst(value);
    await _repo.update((c) => c.latency_first = value);
  }

  Future<void> updateNoTun(bool value) async {
    state.noTun.value = value;
    await _repo.update((c) => c.no_tun = value);
  }

  Future<void> updateEnableSocks5(bool value) async {
    state.enableSocks5.value = value;
    await _repo.update((c) => c.enable_socks5 = value);
  }

  Future<void> updateSocks5Port(int value) async {
    final port = normalizeSocks5Port(value);
    state.socks5Port.value = port;
    await _repo.update((c) => c.socks5_port = port);
  }

  Future<void> updateDataCompressAlgo(int value) async {
    state.dataCompressAlgo.value = value;
    await _repo.update((c) => c.data_compress_algo = value);
  }

  Future<void> updateDisableP2p(bool value) async {
    state.disableP2p.value = value;
    await _repo.update((c) => c.disable_p2p = value);
  }

  Future<void> updateEnableUdpBroadcastRelay(bool value) async {
    state.enableUdpBroadcastRelay.value = value;
    await _repo.update((c) => c.enable_udp_broadcast_relay = value);
  }

  Future<void> updateDisableUdpHolePunching(bool value) async {
    state.disableUdpHolePunching.value = value;
    await _repo.update((c) => c.disable_udp_hole_punching = value);
  }

  Future<void> updateDisableTcpHolePunching(bool value) async {
    state.disableTcpHolePunching.value = value;
    await _repo.update((c) => c.disable_tcp_hole_punching = value);
  }

  Future<void> updateDisableSymHolePunching(bool value) async {
    state.disableSymHolePunching.value = value;
    await _repo.update((c) => c.disable_sym_hole_punching = value);
  }

  Future<void> updateBindDevice(bool value) async {
    state.bindDevice.value = value;
    await _repo.update((c) => c.bind_device = value);
  }

  Future<void> updateEnableKcpProxy(bool value) async {
    state.enableKcpProxy.value = value;
    await _repo.update((c) => c.enable_kcp_proxy = value);
  }

  Future<void> updateTcpWhitelist(String value) async {
    state.tcpWhitelist.value = value;
    await _repo.update((c) => c.tcp_whitelist = value);
  }

  Future<void> updateUdpWhitelist(String value) async {
    state.udpWhitelist.value = value;
    await _repo.update((c) => c.udp_whitelist = value);
  }
}
