import 'dart:io';
import 'package:astral/screens/settings/server/custom_server_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/screens/settings/general/startup_page.dart';
import 'package:astral/screens/settings/general/software_settings_page.dart';
import 'package:astral/screens/settings/general/update_settings_page.dart';
import 'package:astral/screens/settings/general/about_page.dart';
import 'package:astral/screens/plugins/plugin_management_page.dart'; // 导入插件管理页面

class SettingsMainPage extends StatelessWidget {
  const SettingsMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 用户信息卡片（Material Design 风格）
          _buildUserInfoArea(context),
          const SizedBox(height: 24),

          // 服务器配置分组
          _buildSectionHeader(context, LocaleKeys.server_config.tr()),
          const SizedBox(height: 8),
          // CustomServerPage
          _buildSettingsCard(
            context,
            icon: Icons.public,
            title: LocaleKeys.custom_server_list.tr(),
            subtitle: LocaleKeys.custom_server_list_desc.tr(),
            onTap: () => _navigateToPage(context, const CustomServerPage()),
          ),

          const SizedBox(height: 24),

          // 插件管理分组
          _buildSectionHeader(context, LocaleKeys.plugin_management.tr()),
          const SizedBox(height: 8),

          _buildSettingsCard(
            context,
            icon: Icons.extension,
            title: LocaleKeys.plugin_management.tr(),
            subtitle: LocaleKeys.plugin_management_desc.tr(),
            onTap: () => _navigateToPage(context, const PluginManagementPage()),
          ),

          const SizedBox(height: 24),

          // 通用设置分组
          _buildSectionHeader(context, LocaleKeys.general_settings.tr()),
          const SizedBox(height: 8),

          if (!Platform.isAndroid)
            _buildSettingsCard(
              context,
              icon: Icons.launch,
              title: LocaleKeys.startup_related.tr(),
              subtitle: LocaleKeys.startup_desc.tr(),
              onTap: () => _navigateToPage(context, const StartupPage()),
            ),

          _buildSettingsCard(
            context,
            icon: Icons.info,
            title: LocaleKeys.software_settings.tr(),
            subtitle: LocaleKeys.software_settings_desc.tr(),
            onTap: () => _navigateToPage(context, const SoftwareSettingsPage()),
          ),

          _buildSettingsCard(
            context,
            icon: Icons.system_update,
            title: LocaleKeys.update_settings.tr(),
            subtitle: LocaleKeys.update_settings_desc.tr(),
            onTap: () => _navigateToPage(context, const UpdateSettingsPage()),
          ),

          _buildSettingsCard(
            context,
            icon: Icons.info_outline,
            title: LocaleKeys.about.tr(),
            subtitle: LocaleKeys.about_desc.tr(),
            onTap: () => _navigateToPage(context, const AboutPage()),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoArea(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // 头像占位
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 32,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                // 状态指示器
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).cardColor,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // 昵称和状态
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '用户昵称', // 占位文本
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '在线', // 占位状态
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
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
