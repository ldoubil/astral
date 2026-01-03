import 'package:signals_flutter/signals_flutter.dart';

/// 通知相关状态
class NotificationState {
  // 启用轮播图
  final enableBannerCarousel = signal(true);

  // 是否已显示轮播图提示
  final hasShownBannerTip = signal(false);

  // 日志列表
  final logs = signal<List<String>>([]);

  // 状态更新方法
  void setEnableBannerCarousel(bool value) {
    enableBannerCarousel.value = value;
  }

  void setHasShownBannerTip(bool value) {
    hasShownBannerTip.value = value;
  }

  void toggleBannerCarousel() {
    enableBannerCarousel.value = !enableBannerCarousel.value;
  }

  void setLogs(List<String> logList) {
    logs.value = logList;
  }

  void addLog(String log) {
    final list = List<String>.from(logs.value);
    list.add(log);
    logs.value = list;
  }

  void clearLogs() {
    logs.value = [];
  }

  // Computed Signal
  late final logCount = computed(() => logs.value.length);
}
