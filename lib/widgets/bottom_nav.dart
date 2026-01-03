import 'package:astral/k/services/service_manager.dart';
import 'package:astral/k/mod/small_window_adapter.dart'; // 导入小窗口适配器
import 'package:astral/k/navigtion.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class BottomNav extends StatelessWidget {
  final List<NavigationItem> navigationItems;
  final ColorScheme colorScheme;

  const BottomNav({
    super.key,
    required this.navigationItems,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    // 检查是否为小窗口模式
    final bool isSmallWindow = SmallWindowAdapter.shouldApplyAdapter(context);

    return Watch((context) {
      final selectedIndex = ServiceManager().uiState.selectedIndex.value;

      return BottomNavigationBar(
        backgroundColor: colorScheme.surfaceContainerLow,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        showUnselectedLabels: !isSmallWindow, // 在小窗口模式下不显示未选中的标签
        selectedFontSize: isSmallWindow ? 10 : 12, // 在小窗口模式下使用更小的字体
        unselectedFontSize: isSmallWindow ? 8 : 10,
        items:
            navigationItems
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: Icon(
                      item.icon,
                      size: isSmallWindow ? 20 : 24,
                    ), // 在小窗口模式下使用更小的图标
                    activeIcon: Icon(
                      item.activeIcon,
                      size: isSmallWindow ? 20 : 24,
                    ),
                    label: item.label,
                  ),
                )
                .toList(),
        currentIndex: selectedIndex,
        onTap: (index) {
          ServiceManager().uiState.selectedIndex.value = index;
        },
      );
    });
  }
}
