import 'package:signals_flutter/signals_flutter.dart';

import 'package:astral/shared/utils/github_proxy_selector.dart';

/// 更新相关状态
class UpdateState {
  /// 是否加入测试版频道
  final beta = signal(false);

  /// 是否自动检查更新
  final autoCheckUpdate = signal(true);

  /// 下载加速前缀（`auto` = 自动测速，`''` = 关闭）
  final downloadAccelerate = signal(GitHubProxySelector.autoMode);

  /// 自动模式下最近一次测速选中的前缀
  final resolvedDownloadAccelerate = signal<String?>(null);

  /// 最近一次检查到的最新版本号
  final latestVersion = signal<String?>(null);

  void setBeta(bool value) {
    beta.value = value;
  }

  void setAutoCheckUpdate(bool value) {
    autoCheckUpdate.value = value;
  }

  void setDownloadAccelerate(String value) {
    downloadAccelerate.value = value;
    if (!GitHubProxySelector.isAutoMode(value)) {
      resolvedDownloadAccelerate.value = null;
    }
  }

  void setResolvedDownloadAccelerate(String? value) {
    resolvedDownloadAccelerate.value = value;
  }

  void setLatestVersion(String? version) {
    latestVersion.value = version;
  }

  /// 仅表示已经拿到可用版本号，不代表一定高于当前版本
  late final hasNewVersion = computed(() {
    final version = latestVersion.value;
    return version != null && version.trim().isNotEmpty;
  });
}
