import 'dart:io';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/shared/widgets/common/home_box.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:signals_flutter/signals_flutter.dart';

class VirtualIpBox extends StatelessWidget {
  const VirtualIpBox({super.key});

  @override
  Widget build(BuildContext context) {
    // 只在Windows平台显示防火墙卡片
    if (!Platform.isWindows) {
      return const SizedBox.shrink();
    }

    var colorScheme = Theme.of(context).colorScheme;
    return Watch((context) {
      final firewallStatus = ServiceManager().firewallState.firewallStatus
          .watch(context);

      return HomeBox(
        widthSpan: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shield, color: colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  LocaleKeys.firewall.tr(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    firewallStatus
                        ? LocaleKeys.firewall_enabled.tr()
                        : LocaleKeys.firewall_disabled.tr(),
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontSize: 14,
                    ),
                  ),
                ),
                Switch(
                  value: firewallStatus,
                  onChanged: (bool value) {
                    ServiceManager().firewall.setFirewall(value);
                  },
                  activeColor: colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
