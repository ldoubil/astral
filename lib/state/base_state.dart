import 'dart:io';
import 'package:signals_flutter/signals_flutter.dart';

/// 基础状态管理类 - 优化版本
/// 管理应用程序的基础 UI 状态
class BaseState {
  static final BaseState _instance = BaseState._internal();
  factory BaseState() => _instance;

  /// 当前页面
  final currentPage = signal('home');

  /// 是否为桌面设备
  final Signal<bool> isDesktop = signal(false);

  /// 鼠标悬停状态跟踪
  final Signal<int?> hoveredIndex = signal(null);

  /// 应用程序名称
  final Signal<String> appName = signal('Astral Game');

  /// 屏幕分割宽度 - 用于区分手机和桌面
  final Signal<double> screenSplitWidth = signal(480.0);

  /// 当前选中的导航项索引
  final Signal<int> selectedIndex = signal(0);

  BaseState._internal() {
    _init();
  }

  /// 初始化状态
  void _init() {
    // 监听屏幕宽度变化，自动更新设备类型
    effect(() {
      isDesktop.value = screenSplitWidth.value > 480;
    });
  }

  /// 更新屏幕分割宽度
  void updateScreenSplitWidth(double width) {
    screenSplitWidth.value = width;
  }

  /// 设置当前页面
  void setCurrentPage(String page) {
    currentPage.value = page;
  }

  /// 设置选中的导航项
  void setSelectedIndex(int index) {
    selectedIndex.value = index;
  }

  /// 设置悬停索引
  void setHoveredIndex(int? index) {
    hoveredIndex.value = index;
  }

  /// 重置所有状态到默认值
  void reset() {
    currentPage.value = 'home';
    hoveredIndex.value = null;
    selectedIndex.value = 0;
    screenSplitWidth.value = 480.0;
  }
}
