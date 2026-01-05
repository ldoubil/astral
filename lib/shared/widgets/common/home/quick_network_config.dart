import 'dart:io';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/shared/widgets/common/home_box.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

class QuickNetworkConfig extends StatelessWidget {
  const QuickNetworkConfig({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final services = ServiceManager();

    return Watch((context) {
      final disableP2p = services.networkConfigState.disableP2p.watch(context);
      final firewallStatus = services.firewallState.firewallStatus.watch(context);

      return HomeBox(
        widthSpan: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                const Text(
                  '快捷网络配置',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 强制中转开关
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          disableP2p
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.route,
                      size: 20,
                      color:
                          disableP2p
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '强制中转',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '禁用P2P直连，所有流量经服务器中转',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: disableP2p,
                    onChanged: (value) {
                      services.networkConfig.updateDisableP2p(value);
                    },
                  ),
                ],
              ),
            ),

            // 防火墙开关（仅Windows）
            if (Platform.isWindows) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            firewallStatus
                                ? colorScheme.primaryContainer
                                : colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.shield,
                        size: 20,
                        color:
                            firewallStatus
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.firewall.tr(),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            firewallStatus
                                ? LocaleKeys.firewall_enabled.tr()
                                : LocaleKeys.firewall_disabled.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: firewallStatus,
                      onChanged: (value) {
                        services.firewall.setFirewall(value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}
