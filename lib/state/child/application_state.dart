import 'package:astral/core/persistent_signal.dart';

class ApplicationState {
    /// 是否关闭最小化到托盘
  late final PersistentSignal<bool> closeMinimize ;
    /// 用户列表简约模式
  late final PersistentSignal<bool> userListSimple ;

  ApplicationState() {
    closeMinimize = PersistentSignal('closeMinimize', true);
    userListSimple = PersistentSignal('userListSimple', true);
  }
}