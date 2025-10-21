import 'dart:io';
import 'package:astral/screens/settings/server/custom_server_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/screens/settings/network/network_adapter_page.dart';
import 'package:astral/screens/settings/network/subnet_proxy_page.dart';
import 'package:astral/screens/settings/network/vpn_segment_page.dart';
import 'package:astral/screens/settings/general/startup_page.dart';
import 'package:astral/screens/settings/general/software_settings_page.dart';
import 'package:astral/screens/settings/general/update_settings_page.dart';
import 'package:astral/screens/settings/general/about_page.dart';
import 'package:astral/screens/settings/server/public_server_page.dart';
import 'package:astral/screens/plugins/plugin_management_page.dart'; // 导入插件管理页面
import 'package:astral/screens/general/general_listen_list_page.dart';
import 'package:astral/screens/general/general_base_net_config_page.dart';
import 'package:astral/models/net_node.dart';
import 'package:astral/state/app_state.dart';

class SettingsMainPage extends StatelessWidget {
  const SettingsMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 网络设置分组
          _buildSectionHeader(context, LocaleKeys.network_settings.tr()),
          const SizedBox(height: 8),

          if (Platform.isWindows) ...[


            _buildSettingsCard(
              context,
              icon: Icons.network_check,
              title: LocaleKeys.network_adapter_hop_settings.tr(),
              subtitle: '配置网络适配器跳数',
              onTap: () => _navigateToPage(context, const NetworkAdapterPage()),
            ),
          ],

          _buildSettingsCard(
            context,
            icon: Icons.list_alt,
            title: LocaleKeys.listen_list.tr(),
            subtitle: '管理网络监听地址',
            onTap: () => _navigateToListenListPage(context),
          ),

          if (!Platform.isAndroid)
            _buildSettingsCard(
              context,
              icon: Icons.route,
              title: LocaleKeys.subnet_proxy_cidr.tr(),
              subtitle: '配置子网代理规则',
              onTap: () => _navigateToPage(context, const SubnetProxyPage()),
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
            title: '个性化网络参数配置',
            subtitle: '个性化网络参数配置',
            onTap: () => _navigateToNetworkConfigPage(context),
          ),

          const SizedBox(height: 24),

          // 服务器配置分组
          _buildSectionHeader(context, '服务器配置'),
          const SizedBox(height: 8),
          // CustomServerPage
          _buildSettingsCard(
            context,
            icon: Icons.public,
            title: '自定义服务器列表',
            subtitle: '管理自定义服务器',
            onTap: () => _navigateToPage(context, const CustomServerPage()),
          ),

          _buildSettingsCard(
            context,
            icon: Icons.public,
            title: '公共服务器列表',
            subtitle: '管理公共服务器',
            onTap: () => _navigateToPage(context, const PublicServerPage()),
          ),

          const SizedBox(height: 24),

          // 插件管理分组
          _buildSectionHeader(context, '插件管理'),
          const SizedBox(height: 8),

          _buildSettingsCard(
            context,
            icon: Icons.extension,
            title: '插件管理',
            subtitle: '管理和配置应用插件',
            onTap: () => _navigateToPage(context, const PluginManagementPage()),
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
            icon: Icons.info_outline,
            title: LocaleKeys.about.tr(),
            subtitle: '版本信息和开源许可',
            onTap: () => _navigateToPage(context, const AboutPage()),
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

  /// 导航到网络配置页面
  /// 传递当前的NetNode配置，并在返回时更新AppState
  void _navigateToNetworkConfigPage(BuildContext context) async {
    final currentNetNode = AppState().baseNetNodeState.getCurrentNetNode();
    final updatedNetNode = await Navigator.of(context).push<NetNode>(
      MaterialPageRoute(
        builder: (context) => GeneralBaseNetConfigPage(
          netNode: currentNetNode,
        ),
      ),
    );
    if (updatedNetNode != null) {
      // 更新BaseNetNodeState中的配置
      AppState().baseNetNodeState.updateNetNode(updatedNetNode);
    }
  }

  /// 导航到监听列表页面
  /// 传递当前的监听列表，并在返回时更新AppState
  void _navigateToListenListPage(BuildContext context) async {
    final currentListeners = AppState().baseNetNodeState.netNode.value.listeners  ;
    final newListeners = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (context) => GeneralListenListPage(
          listeners: currentListeners,
        ),
      ),
    );
    
    if (newListeners != null) {
      // 使用updateField方法更新listeners字段
      AppState().baseNetNodeState.updateField(
        (node) => node.listeners,
        (node, value) => node.listeners = value,
        newListeners,
      );
    }
  }
}
