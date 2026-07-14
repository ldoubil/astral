import 'package:signals_flutter/signals_flutter.dart';

/// UI状态（纯Signal，临时状态，不需要持久化）
class UIState {
  final screenSplitWidth = signal(480.0);
  final isDesktop = signal(false);
  final selectedIndex = signal(0);
  final hoveredIndex = signal<int?>(null);
  final isInBackground = signal(false);
  final trayHidden = signal(false);

  void updateScreenSplitWidth(double width) {
    screenSplitWidth.value = width;
    isDesktop.value = width > 480;
  }

  void setBackground(bool value) {
    isInBackground.value = value;
  }

  void setTrayHidden(bool value) {
    trayHidden.value = value;
  }
}
