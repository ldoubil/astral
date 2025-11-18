import 'package:signals_flutter/signals_flutter.dart';

import '../../core/persistent_signal.dart';

/// 提供应用中通用的 UI 状态信号与初始化逻辑
class V2UserState {
  late final PersistentSignal<String> Name;
  late final PersistentSignal<String> AvatarUrl;
  // ip
  final Signal<String> ipv4 = signal('');
  V2UserState() {
    _initPersistentSignals();
  }
  void _initPersistentSignals() {
    Name = persistentSignal('V2_user_name', '默认用户名');
    AvatarUrl = persistentSignal('V2_user_avatar_url', '');
  }
}
