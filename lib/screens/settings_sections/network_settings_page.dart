import 'package:astral/k/app_s/aps.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

class NetworkSettingsPage extends StatelessWidget {
  const NetworkSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.network_settings.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // 压缩算法下拉单选
                ListTile(
                  title: Text(LocaleKeys.p2p_hole_punching.tr()),
                  subtitle: Text(LocaleKeys.preferred_protocol.tr()),
                  trailing: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          focusColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: DropdownButton<String>(
                          value:
                              Aps().defaultProtocol.watch(context).isEmpty
                                  ? 'tcp'
                                  : Aps().defaultProtocol.watch(context),
                          items: const [
                            DropdownMenuItem(
                              value: 'tcp',
                              child: Text('TCP', style: TextStyle(fontSize: 14)),
                            ),
                            DropdownMenuItem(
                              value: 'udp',
                              child: Text('UDP', style: TextStyle(fontSize: 14)),
                            ),
                            DropdownMenuItem(
                              value: 'ws',
                              child: Text(
                                'WebSocket',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'wss',
                              child: Text('WSS', style: TextStyle(fontSize: 14)),
                            ),
                            DropdownMenuItem(
                              value: 'quic',
                              child: Text('QUIC', style: TextStyle(fontSize: 14)),
                            ),
                          ],
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down),
                          onChanged: (value) {
                            if (value != null) {
                              Aps().updateDefaultProtocol(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.enable_encryption.tr()),
                  subtitle: Text(LocaleKeys.auto_set_mtu.tr()),
                  value: Aps().enableEncryption.watch(context),
                  onChanged: (value) {
                    Aps().updateEnableEncryption(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.latency_first.tr()),
                  subtitle: Text(LocaleKeys.latency_first_desc.tr()),
                  value: Aps().latencyFirst.watch(context),
                  onChanged: (value) {
                    Aps().updateLatencyFirst(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.magic_dns.tr()),
                  subtitle: Text(LocaleKeys.magic_dns_desc.tr()),
                  value: Aps().accept_dns.watch(context),
                  onChanged: (value) {
                    Aps().updateAcceptDns(value);
                  },
                ),
                SwitchListTile(
                  title: Text(LocaleKeys.tun_device.tr()),
                  subtitle: Text(LocaleKeys.tun_device_desc.tr()),
                  value: Aps().noTun.watch(context),
                  onChanged: (value) {
                    Aps().updateNoTun(value);
                  },
                ),

                SwitchListTile(
                  title: Row(
                    children: [
                      Text(LocaleKeys.smoltcp_stack.tr()),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          LocaleKeys.not_recommended.tr(),
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(LocaleKeys.smoltcp_stack_desc.tr()),
                  value: Aps().useSmoltcp.watch(context),
                  onChanged: (value) {
                    Aps().updateUseSmoltcp(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.disable_p2p.tr()),
                  subtitle: Text(LocaleKeys.disable_p2p_desc.tr()),
                  value: Aps().disableP2p.watch(context),
                  onChanged: (value) {
                    Aps().updateDisableP2p(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.relay_peer_rpc.tr()),
                  subtitle: Text(LocaleKeys.relay_peer_rpc_desc.tr()),
                  value: Aps().relayAllPeerRpc.watch(context),
                  onChanged: (value) {
                    Aps().updateRelayAllPeerRpc(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.disable_udp_hole_punching.tr()),
                  subtitle: Text(LocaleKeys.disable_udp_hole_punching_desc.tr()),
                  value: Aps().disableUdpHolePunching.watch(context),
                  onChanged: (value) {
                    Aps().updateDisableUdpHolePunching(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.enable_multi_thread.tr()),
                  subtitle: Text(LocaleKeys.enable_multi_thread_desc.tr()),
                  value: Aps().multiThread.watch(context),
                  onChanged: (value) {
                    Aps().updateMultiThread(value);
                  },
                ),

                // 压缩算法下拉单选
                ListTile(
                  title: Text(LocaleKeys.compression_algorithm.tr()),
                  subtitle: Text(LocaleKeys.compression_algorithm_desc.tr()),
                  trailing: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          focusColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: DropdownButton<int>(
                          value: Aps().dataCompressAlgo.watch(context),
                          items: [
                            DropdownMenuItem(
                              value: 1,
                              child: Text(
                                LocaleKeys.no_compression.tr(),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 2,
                              child: Text(
                                LocaleKeys.high_performance_compression.tr(),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down),
                          onChanged: (value) {
                            if (value != null) {
                              Aps().updateDataCompressAlgo(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.bind_device.tr()),
                  subtitle: Text(LocaleKeys.bind_device_desc.tr()),
                  value: Aps().bindDevice.watch(context),
                  onChanged: (value) {
                    Aps().updateBindDevice(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.enable_kcp_proxy.tr()),
                  subtitle: Text(LocaleKeys.enable_kcp_proxy_desc.tr()),
                  value: Aps().enableKcpProxy.watch(context),
                  onChanged: (value) {
                    Aps().updateEnableKcpProxy(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.kcp_input.tr()),
                  subtitle: Text(LocaleKeys.kcp_input_desc.tr()),
                  value: Aps().disableKcpInput.watch(context),
                  onChanged: (value) {
                    Aps().updateDisableKcpInput(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.disable_relay_kcp.tr()),
                  subtitle: Text(LocaleKeys.disable_relay_kcp_desc.tr()),
                  value: Aps().disableRelayKcp.watch(context),
                  onChanged: (value) {
                    Aps().updateDisableRelayKcp(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.private_mode.tr()),
                  subtitle: Text(LocaleKeys.private_mode_desc.tr()),
                  value: Aps().privateMode.watch(context),
                  onChanged: (value) {
                    Aps().updatePrivateMode(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.enable_quic_proxy.tr()),
                  subtitle: Text(LocaleKeys.enable_quic_proxy_desc.tr()),
                  value: Aps().enableQuicProxy.watch(context),
                  onChanged: (value) {
                    Aps().updateEnableQuicProxy(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.disable_quic_input.tr()),
                  subtitle: Text(LocaleKeys.disable_quic_input_desc.tr()),
                  value: Aps().disableQuicInput.watch(context),
                  onChanged: (value) {
                    Aps().updateDisableQuicInput(value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}