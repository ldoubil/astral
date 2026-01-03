import 'dart:io';
import 'package:astral/k/services/service_manager.dart';
import 'package:astral/widgets/home_box.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

// 添加模拟数据模型
class NetworkNode {
  final String id;
  final String name;
  final bool isServer;
  final List<NetworkConnection> connections;

  NetworkNode({
    required this.id,
    required this.name,
    this.isServer = false,
    this.connections = const [],
  });
}

class NetworkConnection {
  final String targetId;
  final int latency; // 毫秒

  NetworkConnection({required this.targetId, required this.latency});
}

class VirtualIpBox extends StatelessWidget {
  const VirtualIpBox({super.key});

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
              Icon(Icons.network_check, color: colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                LocaleKeys.firewall.tr(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              const Spacer(),
              // 添加状态指示器
              Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    ServiceManager().connectionState.connectionState.value,
                    colorScheme,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(
                    ServiceManager().connectionState.connectionState.value,
                  ),
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
          if (Platform.isWindows) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    Icon(Icons.shield, size: 20, color: colorScheme.primary),
                    Text(
                      '${LocaleKeys.firewall_label.tr()}: ',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      ServiceManager().firewallState.firewallStatus.value
                          ? LocaleKeys.firewall_enabled.tr()
                          : LocaleKeys.firewall_disabled.tr(),
                      style: TextStyle(color: colorScheme.secondary),
                    ),
                  ],
                ),

                const Spacer(),
                Switch(
                  value:
                      ServiceManager()
                          .firewallState
                          .firewallStatus
                          .value, // 需要在Aps中添加firewall_enabled状态
                  onChanged: (bool value) {
                    ServiceManager().firewall.setFirewall(value); // 切换防火墙状态
                  },
                  activeColor: colorScheme.primary,
                ),
              ],
            ),
          ],
          if (ServiceManager().networkConfigState.ipv4.value.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                Icon(Icons.public, size: 20, color: colorScheme.primary),
                Text(
                  '${LocaleKeys.virtual_ip_label.tr()}: ',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  ServiceManager().networkConfigState.ipv4.value,
                  style: TextStyle(color: colorScheme.secondary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// 获取状态颜色
Color _getStatusColor(CoState state, ColorScheme colorScheme) {
  switch (state) {
    case CoState.idle:
      return Colors.grey;
    case CoState.connecting:
      return Colors.orange;
    case CoState.connected:
      return Colors.green;
  }
}

// 获取状态文本
String _getStatusText(CoState state) {
  switch (state) {
    case CoState.idle:
      return LocaleKeys.status_disconnected.tr();
    case CoState.connecting:
      return LocaleKeys.status_connecting.tr();
    case CoState.connected:
      return LocaleKeys.status_connected.tr();
  }
}
