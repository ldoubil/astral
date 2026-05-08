import 'package:signals_flutter/signals_flutter.dart';

/// 应用设置状态
class AppSettingsState {
  // 应用名称
  final appName = signal('Astral');

  // 监听列表
  final listenList = signal<List<String>>([]);

  // 启用轮播图
  final enableBannerCarousel = signal(true);

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

  // 更新应用名称
  void updateAppName(String name) {
    appName.value = name;
  }

  // 设置监听列表
  void setListenList(List<String> list) {
    listenList.value = list;
  }

  // 更新轮播图开关
  void updateEnableBannerCarousel(bool value) {
    enableBannerCarousel.value = value;
  }

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

  // 添加日志
  void addLog(String log) {
    final list = List<String>.from(logs.value);
    list.add(log);
    logs.value = list;
  }

  // 清空日志
  void clearLogs() {
    logs.value = [];
  }

  // 设置日志列表
  void setLogs(List<String> logList) {
    logs.value = logList;
  }
}
