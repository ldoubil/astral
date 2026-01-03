import 'package:signals_flutter/signals_flutter.dart';

/// 应用设置状态
class AppSettingsState {
  // 应用名称
  final appName = signal('Astral');

  // 监听列表
  final listenList = signal<List<String>>([]);

  // 启用轮播图
  final enableBannerCarousel = signal(true);

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
