import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/k/services/service_manager.dart';
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
      body: Watch((context) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Column(
                children: [
                  // Astral连接协议
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
                              ServiceManager()
                                      .networkConfigState
                                      .defaultProtocol
                                      .value
                                      .isEmpty
                                  ? 'tcp'
                                  : ServiceManager()
                                      .networkConfigState
                                      .defaultProtocol
                                      .value,
                          items: const [
                            DropdownMenuItem(
                              value: 'tcp',
                              child: Text(
                                'TCP',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'udp',
                              child: Text(
                                'UDP',
                                style: TextStyle(fontSize: 14),
                              ),
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
                              child: Text(
                                'WSS',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'quic',
                              child: Text(
                                'QUIC',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down),
                          onChanged: (value) {
                            if (value != null) {
                              ServiceManager().networkConfig
                                  .updateDefaultProtocol(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  const Divider(),

                  // 启用数据加密
                  SwitchListTile(
                    title: Text(LocaleKeys.enable_encryption.tr()),
                    subtitle: Text(LocaleKeys.auto_set_mtu.tr()),
                    value:
                        ServiceManager()
                            .networkConfigState
                            .enableEncryption
                            .value,
                    onChanged: (value) {
                      ServiceManager().networkConfig.updateEnableEncryption(
                        value,
                      );
                    },
                  ),

                  // 启用延迟优先
                  SwitchListTile(
                    title: Text(LocaleKeys.latency_first.tr()),
                    subtitle: Text(LocaleKeys.latency_first_desc.tr()),
                    value:
                        ServiceManager().networkConfigState.latencyFirst.value,
                    onChanged: (value) {
                      ServiceManager().networkConfig.updateLatencyFirst(value);
                    },
                  ),

                  // 强制中转
                  SwitchListTile(
                    title: Text(LocaleKeys.disable_p2p.tr()),
                    subtitle: Text(LocaleKeys.disable_p2p_desc.tr()),
                    value: ServiceManager().networkConfigState.disableP2p.value,
                    onChanged: (value) {
                      ServiceManager().networkConfig.updateDisableP2p(value);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 专业网络设置
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text(LocaleKeys.advanced_network_settings.tr()),
                    subtitle: Text(
                      LocaleKeys.advanced_network_settings_desc.tr(),
                    ),
                    leading: const Icon(Icons.settings_ethernet),
                  ),

                  const Divider(),

                  // 禁用UDP打洞
                  SwitchListTile(
                    title: Text(LocaleKeys.disable_udp_hole_punching.tr()),
                    subtitle: Text(
                      LocaleKeys.disable_udp_hole_punching_desc.tr(),
                    ),
                    value:
                        ServiceManager()
                            .networkConfigState
                            .disableUdpHolePunching
                            .value,
                    onChanged: (value) {
                      ServiceManager().networkConfig
                          .updateDisableUdpHolePunching(value);
                    },
                  ),

                  // 禁用UDP对称打洞
                  SwitchListTile(
                    title: Text(LocaleKeys.disable_sym_hole_punching.tr()),
                    subtitle: Text(
                      LocaleKeys.disable_sym_hole_punching_desc.tr(),
                    ),
                    value:
                        ServiceManager()
                            .networkConfigState
                            .disableSymHolePunching
                            .value,
                    onChanged: (value) {
                      ServiceManager().networkConfig
                          .updateDisableSymHolePunching(value);
                    },
                  ),

                  // 数据压缩方式
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
                          value:
                              ServiceManager()
                                  .networkConfigState
                                  .dataCompressAlgo
                                  .value,
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
                              ServiceManager().networkConfig
                                  .updateDataCompressAlgo(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  // 启用KCP代理
                  SwitchListTile(
                    title: Text(LocaleKeys.enable_kcp_proxy.tr()),
                    subtitle: Text(LocaleKeys.enable_kcp_proxy_desc.tr()),
                    value:
                        ServiceManager()
                            .networkConfigState
                            .enableKcpProxy
                            .value,
                    onChanged: (value) {
                      ServiceManager().networkConfig.updateEnableKcpProxy(
                        value,
                      );
                    },
                  ),

                  // 启用QUIC代理
                  SwitchListTile(
                    title: Text(LocaleKeys.enable_quic_proxy.tr()),
                    subtitle: Text(LocaleKeys.enable_quic_proxy_desc.tr()),
                    value:
                        ServiceManager()
                            .networkConfigState
                            .enableQuicProxy
                            .value,
                    onChanged: (value) {
                      ServiceManager().networkConfig.updateEnableQuicProxy(
                        value,
                      );
                    },
                  ),

                  // 绑定到物理网卡
                  SwitchListTile(
                    title: Text(LocaleKeys.bind_device.tr()),
                    subtitle: Text(LocaleKeys.bind_device_desc.tr()),
                    value: ServiceManager().networkConfigState.bindDevice.value,
                    onChanged: (value) {
                      ServiceManager().networkConfig.updateBindDevice(value);
                    },
                  ),

                  // 禁用TUN网卡
                  SwitchListTile(
                    title: Text(LocaleKeys.tun_device.tr()),
                    subtitle: Text(LocaleKeys.tun_device_desc.tr()),
                    value: ServiceManager().networkConfigState.noTun.value,
                    onChanged: (value) {
                      ServiceManager().networkConfig.updateNoTun(value);
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
