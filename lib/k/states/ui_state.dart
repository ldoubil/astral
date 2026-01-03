import 'package:signals_flutter/signals_flutter.dart';

/// UI状态（纯Signal，临时状态，不需要持久化）
class UIState {
  // 屏幕与设备
  final screenSplitWidth = signal(480.0);
  final isDesktop = signal(false);

  // 导航与交互
  final selectedIndex = signal(0);
  final hoveredIndex = signal<int?>(null);

  // 应用名称
  final appName = signal('Astral');

  // 简单的状态更新
  void updateScreenWidth(double width) {
    screenSplitWidth.value = width;
    isDesktop.value = width > 480;
  }

  void updateScreenSplitWidth(double width) {
    screenSplitWidth.value = width;
    isDesktop.value = width > 480;
  }

  void selectTab(int index) {
    selectedIndex.value = index;
  }

  void setHovered(int? index) {
    hoveredIndex.value = index;
  }

  void resetHover() {
    hoveredIndex.value = null;
  }
}
