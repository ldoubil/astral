import 'package:astral/core/persistent_signal.dart';

class UpdateState {
    /// beta - 参与测试版
  late final PersistentSignal<bool> beta;
  /// autoCheckUpdate - 自动检查更新
  late final PersistentSignal<bool> autoCheckUpdate;
    /// 下载加速地址
  late final PersistentSignal<String> downloadAccelerate;

  UpdateState() {
    beta = PersistentSignal('beta', false);
    autoCheckUpdate = PersistentSignal('autoCheckUpdate', true);
    downloadAccelerate = PersistentSignal('downloadAccelerate', 'https://gh.xmly.dev/');
  }
}