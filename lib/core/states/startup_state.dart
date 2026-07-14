import 'package:signals_flutter/signals_flutter.dart';

/// 启动相关状态
class StartupState {
  final startup = signal(false);
  final startupMinimize = signal(false);
  final startupAutoConnect = signal(false);

  void setStartup(bool value) {
    startup.value = value;
  }

  void setStartupMinimize(bool value) {
    startupMinimize.value = value;
  }

  void setStartupAutoConnect(bool value) {
    startupAutoConnect.value = value;
  }

  void updateAll({
    bool? startup,
    bool? startupMinimize,
    bool? startupAutoConnect,
  }) {
    if (startup != null) this.startup.value = startup;
    if (startupMinimize != null) this.startupMinimize.value = startupMinimize;
    if (startupAutoConnect != null) {
      this.startupAutoConnect.value = startupAutoConnect;
    }
  }
}
