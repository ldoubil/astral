import 'dart:io';
import 'package:astral/features/nat_test/pages/nat_test_page.dart';
import 'package:astral/features/magic_wall/pages/magic_wall_page.dart';
import 'package:astral/features/settings/pages/network/port_whitelist_page.dart';
import 'package:flutter/material.dart';

/// 工具入口项
class ToolItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const ToolItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

/// 工具页：联机相关工具入口枢纽
class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle(context, '联机工具'),
                const SizedBox(height: 12),
                if (Platform.isWindows) ...[
                  _buildListTile(
                    context,
                    ToolItem(
                      title: '魔法墙',
                      subtitle: '高级防火墙管理',
                      icon: Icons.security,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MagicWallPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                _buildListTile(
                  context,
                  ToolItem(
                    title: '端口白名单',
                    subtitle: '配置TCP/UDP端口访问白名单',
                    icon: Icons.security_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PortWhitelistPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _buildListTile(
                  context,
                  ToolItem(
                    title: 'NAT 类型测试',
                    subtitle: '检测您的网络 NAT 类型',
                    icon: Icons.network_check,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NatTestPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, ToolItem item) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Icon(
          item.icon,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          item.title,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          item.subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: item.onTap,
      ),
    );
  }
}
