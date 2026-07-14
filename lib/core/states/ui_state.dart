import 'package:astral/core/ui/main_tab.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// UI状态（纯Signal，临时状态，不需要持久化）
class UIState {
  final isDesktop = signal(false);
  final selectedIndex = signal(0);
  final hoveredIndex = signal<int?>(null);
  final isInBackground = signal(false);
  final trayHidden = signal(false);

  void goTo(MainTab tab) {
    selectedIndex.value = tab.index;
  }

  void updateScreenSplitWidth(double width) {
    isDesktop.value = width > 480;
  }

  void setBackground(bool value) {
    isInBackground.value = value;
  }

  void setTrayHidden(bool value) {
    trayHidden.value = value;
  }
}
