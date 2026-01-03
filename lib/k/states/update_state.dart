import 'package:signals_flutter/signals_flutter.dart';

/// 更新相关状态
class UpdateState {
  // 参与测试版
  final beta = signal(false);

  // 自动检查更新
  final autoCheckUpdate = signal(true);

  // 下载加速地址
  final downloadAccelerate = signal('https://gh.xmly.dev/');

  // 最新版本号
  final latestVersion = signal<String?>(null);

  // 状态更新方法
  void setBeta(bool value) {
    beta.value = value;
  }

  void setAutoCheckUpdate(bool value) {
    autoCheckUpdate.value = value;
  }

  void setDownloadAccelerate(String value) {
    downloadAccelerate.value = value;
  }

  void setLatestVersion(String? version) {
    latestVersion.value = version;
  }

  void toggleBeta() {
    beta.value = !beta.value;
  }

  void toggleAutoCheckUpdate() {
    autoCheckUpdate.value = !autoCheckUpdate.value;
  }

  // Computed Signal
  late final hasNewVersion = computed(() {
    // TODO: 需要比较当前版本和最新版本
    return latestVersion.value != null;
  });
}
