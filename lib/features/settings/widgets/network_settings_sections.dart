import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/ui/app_snack_bars.dart';
import 'package:astral/src/rust/api/hops.dart';
import 'package:signals_flutter/signals_flutter.dart';

Widget _settingsCard({required List<Widget> children}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [Card(child: Column(children: children))],
  );
}

Widget _divider() => const Divider(height: 1);

/// 基础网络设置卡片（协议 / 加密 / 延迟优先 / 禁用 P2P）
class NetworkBasicSettingsCard extends StatelessWidget {
  const NetworkBasicSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _settingsCard(
      children: [
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
                            .defaultProtocol.watch(context)
                            .isEmpty
                        ? 'tcp'
                        : ServiceManager()
                            .networkConfigState
                            .defaultProtocol.watch(context),
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
                    value: 'faketcp',
                    child: Text('FakeTCP', style: TextStyle(fontSize: 14)),
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
                    ServiceManager().networkConfig.updateDefaultProtocol(
                      value,
                    );
                  }
                },
              ),
            ),
          ),
        ),
        _divider(),
        SwitchListTile(
          title: Text(LocaleKeys.enable_encryption.tr()),
          subtitle: Text(LocaleKeys.auto_set_mtu.tr()),
          value: ServiceManager().networkConfigState.enableEncryption.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateEnableEncryption(value);
          },
        ),
        SwitchListTile(
          title: Text(LocaleKeys.latency_first.tr()),
          subtitle: Text(LocaleKeys.latency_first_desc.tr()),
          value: ServiceManager().networkConfigState.latencyFirst.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateLatencyFirst(value);
          },
        ),
        SwitchListTile(
          title: Text(LocaleKeys.disable_p2p.tr()),
          subtitle: Text(LocaleKeys.disable_p2p_desc.tr()),
          value: ServiceManager().networkConfigState.disableP2p.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateDisableP2p(value);
          },
        ),
      ],
    );
  }
}

/// 高级网络设置卡片
class NetworkAdvancedSettingsCard extends StatelessWidget {
  const NetworkAdvancedSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _settingsCard(
      children: [
        ListTile(
          title: Text(LocaleKeys.advanced_network_settings.tr()),
          subtitle: Text(LocaleKeys.advanced_network_settings_desc.tr()),
          leading: const Icon(Icons.settings_ethernet),
        ),
        _divider(),
        SwitchListTile(
          title: Text(LocaleKeys.disable_udp_hole_punching.tr()),
          subtitle: Text(LocaleKeys.disable_udp_hole_punching_desc.tr()),
          value:
              ServiceManager()
                  .networkConfigState
                  .disableUdpHolePunching.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateDisableUdpHolePunching(
              value,
            );
          },
        ),
        SwitchListTile(
          title: Text(LocaleKeys.disable_tcp_hole_punching.tr()),
          subtitle: Text(LocaleKeys.disable_tcp_hole_punching_desc.tr()),
          value:
              ServiceManager()
                  .networkConfigState
                  .disableTcpHolePunching.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateDisableTcpHolePunching(
              value,
            );
          },
        ),
        SwitchListTile(
          title: Text(LocaleKeys.disable_sym_hole_punching.tr()),
          subtitle: Text(LocaleKeys.disable_sym_hole_punching_desc.tr()),
          value:
              ServiceManager()
                  .networkConfigState
                  .disableSymHolePunching.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateDisableSymHolePunching(
              value,
            );
          },
        ),
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
                        .dataCompressAlgo.watch(context),
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
                    ServiceManager().networkConfig.updateDataCompressAlgo(
                      value,
                    );
                  }
                },
              ),
            ),
          ),
        ),
        SwitchListTile(
          title: Text(LocaleKeys.enable_kcp_proxy.tr()),
          subtitle: Text(LocaleKeys.enable_kcp_proxy_desc.tr()),
          value: ServiceManager().networkConfigState.enableKcpProxy.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateEnableKcpProxy(value);
          },
        ),
        SwitchListTile(
          title: Text(LocaleKeys.bind_device.tr()),
          subtitle: Text(LocaleKeys.bind_device_desc.tr()),
          value: ServiceManager().networkConfigState.bindDevice.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateBindDevice(value);
          },
        ),
        SwitchListTile(
          title: Text(LocaleKeys.tun_device.tr()),
          subtitle: Text(LocaleKeys.tun_device_desc.tr()),
          value: ServiceManager().networkConfigState.noTun.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateNoTun(value);
          },
        ),
        SwitchListTile(
          title: Text(LocaleKeys.enable_socks5.tr()),
          subtitle: Text(LocaleKeys.enable_socks5_desc.tr()),
          value: ServiceManager().networkConfigState.enableSocks5.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.updateEnableSocks5(value);
          },
        ),
        if (ServiceManager().networkConfigState.enableSocks5.watch(context)) ...[
          ListTile(
            title: Text(LocaleKeys.socks5_port.tr()),
            subtitle: Text(LocaleKeys.socks5_port_desc.tr()),
            trailing: SizedBox(
              width: 100,
              child: TextFormField(
                key: ValueKey(
                  ServiceManager().networkConfigState.socks5Port.watch(context),
                ),
                initialValue: ServiceManager()
                    .networkConfigState
                    .socks5Port.watch(context)
                    .toString(),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.end,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (value) {
                  final port = int.tryParse(value);
                  if (port != null && port > 0 && port <= 65535) {
                    ServiceManager().networkConfig.updateSocks5Port(port);
                  }
                },
              ),
            ),
          ),
          ListTile(
            title: Text(
              LocaleKeys.socks5_address_hint.tr(
                namedArgs: {
                  'port': ServiceManager()
                      .networkConfigState
                      .socks5Port.watch(context)
                      .toString(),
                },
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// MTU / Hop 设置卡片
class NetworkHopSettingsCard extends StatelessWidget {
  const NetworkHopSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _settingsCard(
      children: [
        SwitchListTile(
          title: Text(LocaleKeys.auto_set_hop.tr()),
          subtitle: Text(LocaleKeys.auto_set_hop_desc.tr()),
          value: ServiceManager().networkConfigState.autoSetMTU.watch(context),
          onChanged: (value) {
            ServiceManager().networkConfig.setAutoSetMTU(value);
          },
        ),
        _divider(),
        ListTile(
          leading: const Icon(Icons.list),
          title: Text(LocaleKeys.view_hop_list.tr()),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showHopList(context),
        ),
      ],
    );
  }
}

Future<void> showHopList(BuildContext context) async {
  try {
    final result = await getAllInterfacesMetrics();
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.network_adapter_hop_list.tr()),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    result
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text('${e.$1}: ${e.$2}'),
                          ),
                        )
                        .toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(LocaleKeys.close.tr()),
              ),
            ],
          ),
    );
  } catch (e) {
    if (!context.mounted) return;
    AppSnackBars.error(context, '错误', LocaleKeys.get_hop_list_failed.tr());
  }
}
