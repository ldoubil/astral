import 'package:astral/screens/main_screen/widgets/server_list_view.dart';
import 'package:flutter/material.dart';

/// 设置页面组件
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  int _selectedMenuItem = -1; // -1 表示显示菜单列表，>=0 表示显示具体设置项

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // 左侧菜单列表
        Container(
          width: 240,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _buildMenuItem(
                context,
                theme,
                icon: Icons.dns_outlined,
                title: '服务器列表',
                index: 0,
              ),
              // 可以在这里添加更多设置选项
              // _buildMenuItem(
              //   context,
              //   theme,
              //   icon: Icons.network_check_outlined,
              //   title: '网络设置',
              //   index: 1,
              // ),
            ],
          ),
        ),
        // 右侧内容区域
        Expanded(
          child: _selectedMenuItem == -1
              ? _buildDefaultView(theme)
              : _buildContent(_selectedMenuItem),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = _selectedMenuItem == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
      onTap: () {
        setState(() {
          _selectedMenuItem = index;
        });
      },
    );
  }

  Widget _buildDefaultView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '设置',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请从左侧选择设置选项',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(int menuIndex) {
    switch (menuIndex) {
      case 0:
        return const ServerListView();
      // 可以在这里添加更多设置页面
      // case 1:
      //   return const NetworkSettingsView();
      default:
        return _buildDefaultView(Theme.of(context));
    }
  }
}
