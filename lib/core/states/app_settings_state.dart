import 'package:signals_flutter/signals_flutter.dart';

/// 应用设置状态
class AppSettingsState {
  // 应用名称
  final appName = signal('Astral');

  // 启用连接状态栏通知
  final enableConnectionNotification = signal(true);

  // 连接失败自动重试
  final autoRetryOnFailure = signal(true);

  // 最大重试次数
  final maxRetryCount = signal(3);

  // 减少动画/拓扑更新频率（降低后台与低性能设备负载）
  final reduceAnimationUpdates = signal(false);

  // 日志列表
  final logs = signal<List<String>>([]);

  // 更新连接状态栏通知开关
  void updateEnableConnectionNotification(bool value) {
    enableConnectionNotification.value = value;
  }

  // 更新连接失败自动重试开关
  void updateAutoRetryOnFailure(bool value) {
    autoRetryOnFailure.value = value;
  }

  // 更新最大重试次数
  void updateMaxRetryCount(int value) {
    maxRetryCount.value = value;
  }

  // 更新减少动画更新开关
  void updateReduceAnimationUpdates(bool value) {
    reduceAnimationUpdates.value = value;
  }
}
