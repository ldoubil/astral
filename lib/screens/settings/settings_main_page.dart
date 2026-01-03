import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/screens/settings/network/listen_list_page.dart';
import 'package:astral/screens/settings/network/vpn_segment_page.dart';
import 'package:astral/screens/settings/network/network_settings_page.dart';
import 'package:astral/screens/settings/general/startup_page.dart';
import 'package:astral/screens/settings/general/software_settings_page.dart';
import 'package:astral/screens/settings/general/update_settings_page.dart';
import 'package:astral/screens/logs_page.dart';
import 'package:astral/screens/settings/server_settings_page.dart';

class SettingsMainPage extends StatelessWidget {
  const SettingsMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 服务器设置分组
          _buildSectionHeader(context, '服务器管理'),
          const SizedBox(height: 8),

          _buildSettingsCard(
            context,
            icon: Icons.dns,
            title: '服务器列表',
            subtitle: '管理和配置服务器',
            onTap: () => _navigateToPage(context, const ServerSettingsPage()),
          ),

          const SizedBox(height: 24),

          // 网络设置分组
          _buildSectionHeader(context, LocaleKeys.network_settings.tr()),
          const SizedBox(height: 8),

          _buildSettingsCard(
            context,
            icon: Icons.list_alt,
            title: LocaleKeys.listen_list.tr(),
            subtitle: '管理网络监听地址',
            onTap: () => _navigateToPage(context, const ListenListPage()),
          ),

          if (Platform.isAndroid)
            _buildSettingsCard(
              context,
              icon: Icons.vpn_lock,
              title: LocaleKeys.custom_vpn_segment.tr(),
              subtitle: '配置VPN网段',
              onTap: () => _navigateToPage(context, const VpnSegmentPage()),
            ),

          _buildSettingsCard(
            context,
            icon: Icons.network_wifi,
            title: '高级网络设置',
            subtitle: '协议、加密等高级选项',
            onTap: () => _navigateToPage(context, const NetworkSettingsPage()),
          ),

          const SizedBox(height: 24),

          // 通用设置分组
          _buildSectionHeader(context, '通用设置'),
          const SizedBox(height: 8),

          if (!Platform.isAndroid)
            _buildSettingsCard(
              context,
              icon: Icons.launch,
              title: LocaleKeys.startup_related.tr(),
              subtitle: '开机启动和自动连接',
              onTap: () => _navigateToPage(context, const StartupPage()),
            ),

          _buildSettingsCard(
            context,
            icon: Icons.info,
            title: LocaleKeys.software_settings.tr(),
            subtitle: '权限和界面设置',
            onTap: () => _navigateToPage(context, const SoftwareSettingsPage()),
          ),

          _buildSettingsCard(
            context,
            icon: Icons.system_update,
            title: LocaleKeys.update_settings.tr(),
            subtitle: '自动更新和下载设置',
            onTap: () => _navigateToPage(context, const UpdateSettingsPage()),
          ),

          _buildSettingsCard(
            context,
            icon: Icons.article_outlined,
            title: '日志',
            subtitle: '查看应用运行日志',
            onTap: () => _navigateToPage(context, const LogsPage()),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
  }
}
