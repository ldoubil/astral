import 'package:astral/core/persistent_signal.dart';

/// 启动状态
class StartupState {
  /// 开机自启
  late final PersistentSignal<bool> startup;

  /// 启动后最小化
  late final PersistentSignal<bool> startupMinimize;

  /// 启动后自动连接
  late final PersistentSignal<bool> startupAutoConnect;

  StartupState() {
    startup = PersistentSignal<bool>('startup', false);
    startupMinimize = PersistentSignal<bool>('startupMinimize', false);
    startupAutoConnect = PersistentSignal<bool>('startupAutoConnect', false);
  }
}
