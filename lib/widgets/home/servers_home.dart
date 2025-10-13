import 'package:astral/state/app_state.dart';
import 'package:astral/widgets/home_box.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ServersHome extends StatelessWidget {
  const ServersHome({super.key});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return HomeBox(
      widthSpan: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dns, color: colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                LocaleKeys.current_servers.tr(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final servers = AppState().baseState.servers.watch(context);
              var enabledServers =
                  servers.where((s) => s.enable == true).toList();
              if (enabledServers.isEmpty) {
                return Text(
                  LocaleKeys.no_enabled_servers.tr(),
                  style: TextStyle(color: Colors.grey),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    enabledServers.map<Widget>((server) {
                      List<Widget> protocolChips = [];
                      if (server.tcp == true) {
                        protocolChips.add(
                          _buildProtocolChip('TCP', true, colorScheme),
                        );
                      }
                      if (server.udp == true) {
                        protocolChips.add(
                          _buildProtocolChip('UDP', true, colorScheme),
                        );
                      }
                      if (server.ws == true) {
                        protocolChips.add(
                          _buildProtocolChip('WS', true, colorScheme),
                        );
                      }
                      if (server.wss == true) {
                        protocolChips.add(
                          _buildProtocolChip('WSS', true, colorScheme),
                        );
                      }
                      if (server.quic == true) {
                        protocolChips.add(
                          _buildProtocolChip('QUIC', true, colorScheme),
                        );
                      }
                      if (server.wg == true) {
                        protocolChips.add(
                          _buildProtocolChip('WG', true, colorScheme),
                        );
                      }
                      if (server.txt == true) {
                        protocolChips.add(
                          _buildProtocolChip('TXT', true, colorScheme),
                        );
                      }
                      if (server.srv == true) {
                        protocolChips.add(
                          _buildProtocolChip('SRV', true, colorScheme),
                        );
                      }
                      if (server.http == true) {
                        protocolChips.add(
                          _buildProtocolChip('http', true, colorScheme),
                        );
                      }
                      if (server.https == true) {
                        protocolChips.add(
                          _buildProtocolChip('https', true, colorScheme),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 名字
                            Row(
                              children: [
                                Icon(
                                  Icons.cloud,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${server.name} - ${server.url}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            // IP/URL

                            // 协议
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 26.0,
                                top: 2.0,
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children:
                                      protocolChips
                                          .expand(
                                            (chip) => [
                                              chip,
                                              const SizedBox(width: 2),
                                            ],
                                          )
                                          .toList()
                                        ..removeLast(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// 在文件末尾添加协议Chip构建函数
Widget _buildProtocolChip(String label, bool enabled, ColorScheme colorScheme) {
  return Chip(
    label: Text(label, style: TextStyle(fontSize: 12)),
    backgroundColor:
        enabled ? colorScheme.primary.withOpacity(0.15) : Colors.grey.shade200,
    labelStyle: TextStyle(
      color: enabled ? colorScheme.primary : Colors.grey,
      fontWeight: FontWeight.bold,
    ),
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    padding: EdgeInsets.zero,
  );
}
