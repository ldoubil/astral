import 'package:signals_flutter/signals_flutter.dart';

/// 启动相关状态
class StartupState {
  // 开机自启
  final startup = signal(false);

  // 启动后最小化
  final startupMinimize = signal(false);

  // 启动后自动连接
  final startupAutoConnect = signal(false);

  // 状态更新方法
  void setStartup(bool value) {
    startup.value = value;
  }

  void setStartupMinimize(bool value) {
    startupMinimize.value = value;
  }

  void setStartupAutoConnect(bool value) {
    startupAutoConnect.value = value;
  }

  void toggleStartup() {
    startup.value = !startup.value;
  }

  void toggleStartupMinimize() {
    startupMinimize.value = !startupMinimize.value;
  }

  void toggleStartupAutoConnect() {
    startupAutoConnect.value = !startupAutoConnect.value;
  }

  // 批量更新
  void updateAll({
    bool? startup,
    bool? startupMinimize,
    bool? startupAutoConnect,
  }) {
    if (startup != null) this.startup.value = startup;
    if (startupMinimize != null) this.startupMinimize.value = startupMinimize;
    if (startupAutoConnect != null)
      this.startupAutoConnect.value = startupAutoConnect;
  }
}
