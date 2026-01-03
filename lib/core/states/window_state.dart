import 'package:signals_flutter/signals_flutter.dart';

/// 窗口相关状态
class WindowState {
  // 关闭时最小化到托盘
  final closeMinimize = signal(true);

  // 状态更新方法
  void setCloseMinimize(bool value) {
    closeMinimize.value = value;
  }

  void toggleCloseMinimize() {
    closeMinimize.value = !closeMinimize.value;
  }
}
