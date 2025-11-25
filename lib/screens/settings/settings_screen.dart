import 'package:astral/screens/settings/server_list_edit_screen.dart';
import 'package:flutter/material.dart';

/// MD3 风格的全屏设置页面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // 服务器列表设置项
          _SettingsTile(
            leading: Icon(Icons.dns_outlined, color: colorScheme.primary),
            title: '服务器列表',
            subtitle: '管理服务器配置',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ServerListEditScreen(),
                ),
              );
            },
          ),
          // 可以在这里添加更多设置项
          // _SettingsTile(
          //   leading: Icon(
          //     Icons.network_check_outlined,
          //     color: colorScheme.primary,
          //   ),
          //   title: '网络设置',
          //   subtitle: '配置网络相关选项',
          //   onTap: () {
          //     // 导航到网络设置页面
          //   },
          // ),
        ],
      ),
    );
  }
}

/// MD3 风格的设置项 Tile
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.leading,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle:
            subtitle != null
                ? Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
                : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
