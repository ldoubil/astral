import 'package:astral/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:signals_flutter/signals_flutter.dart';

class NetworkSettingsPage extends StatelessWidget {
  const NetworkSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.network_settings.tr()),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Column(
              children: [
                // 协议选择
                ListTile(
                  title: Text(LocaleKeys.p2p_hole_punching.tr()),
                  subtitle: Text(LocaleKeys.preferred_protocol.tr()),
                  trailing: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: DropdownButton<String>(
                        value:
                            AppState().baseState.defaultProtocol.watch(context).isEmpty
                                ? 'tcp'
                                : AppState().baseState.defaultProtocol.watch(context),
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
                            // Aps().updateDefaultProtocol(value);
                          }
                        },
                      ),
                    ),
                  ),
                ),

                const Divider(),

                // 基础网络设置
                SwitchListTile(
                  title: Text(LocaleKeys.enable_encryption.tr()),
                  subtitle: Text(LocaleKeys.auto_set_mtu.tr()),
                  value: AppState().baseState.enableEncryption.watch(context),
                  onChanged: (value) {
                    // AppState().baseState.updateEnableEncryption(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.latency_first.tr()),
                  subtitle: Text(LocaleKeys.latency_first_desc.tr()),
                  value: AppState().baseState.latencyFirst.watch(context),
                  onChanged: (value) {
                    // AppState().baseState.updateLatencyFirst(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.magic_dns.tr()),
                  subtitle: Text(LocaleKeys.magic_dns_desc.tr()),
                  value: AppState().baseState.accept_dns.watch(context),
                  onChanged: (value) {
                    // AppState().baseState.updateAcceptDns(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.tun_device.tr()),
                  subtitle: Text(LocaleKeys.tun_device_desc.tr()),
                  value: AppState().baseState.noTun.watch(context),
                  onChanged: (value) {
                    // AppState().baseState.updateNoTun(value);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 高级网络设置
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('高级网络设置'),
                  subtitle: Text('专业用户配置选项'),
                  leading: const Icon(Icons.settings_ethernet),
                ),

                const Divider(),

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
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(LocaleKeys.smoltcp_stack_desc.tr()),
                  value: AppState().baseState.useSmoltcp.watch(context),
                  onChanged: (value) {
                    // AppState().baseState.updateUseSmoltcp(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.disable_p2p.tr()),
                  subtitle: Text(LocaleKeys.disable_p2p_desc.tr()),
                  value: AppState().baseState.disableP2p.watch(context),
                  onChanged: (value) {
                    // AppState().baseState.updateDisableP2p(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.relay_peer_rpc.tr()),
                  subtitle: Text(LocaleKeys.relay_peer_rpc_desc.tr()),
                  value: AppState().baseState.relayAllPeerRpc.watch(context),
                  onChanged: (value) {
                    // AppState().baseState.updateRelayAllPeerRpc(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.disable_udp_hole_punching.tr()),
                  subtitle: Text(
                    LocaleKeys.disable_udp_hole_punching_desc.tr(),
                  ),
                  value: AppState().baseState.disableUdpHolePunching.watch(context),
                  onChanged: (value) {
                    // AppState().baseState.updateDisableUdpHolePunching(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.enable_multi_thread.tr()),
                  subtitle: Text(LocaleKeys.enable_multi_thread_desc.tr()),
                  value: AppState().baseState.multiThread.watch(context),
                  onChanged: (value) {
                    // AppState().baseState.updateMultiThread(value);
                  },
                ),

                // 压缩算法选择
                ListTile(
                  title: Text(LocaleKeys.compression_algorithm.tr()),
                  subtitle: Text(LocaleKeys.compression_algorithm_desc.tr()),
                  trailing: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: DropdownButton<int>(
                        value: AppState().baseState.dataCompressAlgo.watch(context),
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
                            // Aps().updateDataCompressAlgo(value);
                          }
                        },
                      ),
                    ),
                  ),
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.bind_device.tr()),
                  subtitle: Text(LocaleKeys.bind_device_desc.tr()),
                  value: AppState().baseState.bindDevice.watch(context),
                  onChanged: (value) {
                    // AppState().baseState.updateBindDevice(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.enable_kcp_proxy.tr()),
                  subtitle: Text(LocaleKeys.enable_kcp_proxy_desc.tr()),
                  value: AppState().baseState.enableKcpProxy.watch(context),
                  onChanged: (value) {
                    // AppState().baseState.updateEnableKcpProxy(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.kcp_input.tr()),
                  subtitle: Text(LocaleKeys.kcp_input_desc.tr()),
                  value: AppState().baseState.disableKcpInput.watch(context),
                  onChanged: (value) {
                    // AppState().baseState.updateDisableKcpInput(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.disable_relay_kcp.tr()),
                  subtitle: Text(LocaleKeys.disable_relay_kcp_desc.tr()),
                  value: AppState().baseState.disableRelayKcp.watch(context),
                  onChanged: (value) {
                    // AppState().baseState.updateDisableRelayKcp(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.private_mode.tr()),
                  subtitle: Text(LocaleKeys.private_mode_desc.tr()),
                  value: AppState().baseState.privateMode.watch(context),
                  onChanged: (value) {
                    // AppState().baseState.updatePrivateMode(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.enable_quic_proxy.tr()),
                  subtitle: Text(LocaleKeys.enable_quic_proxy_desc.tr()),
                  value: AppState().baseState.enableQuicProxy.watch(context),
                  onChanged: (value) {
                    // AppState().baseState.updateEnableQuicProxy(value);
                  },
                ),

                SwitchListTile(
                  title: Text(LocaleKeys.disable_quic_input.tr()),
                  subtitle: Text(LocaleKeys.disable_quic_input_desc.tr()),
                  value: AppState().baseState.disableQuicInput.watch(context),
                  onChanged: (value) {
                    // AppState().baseState.updateDisableQuicInput(value);
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
