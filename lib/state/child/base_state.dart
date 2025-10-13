import 'package:signals_flutter/signals_flutter.dart';

/// 基础状态管理基类
/// 提供应用中通用的 UI 状态信号与初始化逻辑
class BaseState {
  /// 当前页面信号（用于路由或页面切换）
  final currentPage = signal('home');

  /// 是否为桌面设备（根据屏幕宽度动态计算）
  final Signal<bool> isDesktop = signal(false);

  /// 鼠标悬停索引（用于列表或导航项的 hover 效果）
  final Signal<int?> hoveredIndex = signal(null);

  /// 应用程序名称信号
  final Signal<String> appName = signal('Astral Game');

  /// 屏幕分割宽度（用于区分手机/桌面布局）
  final Signal<double> screenSplitWidth = signal(480.0);

  /// 当前选中的导航项索引
  final Signal<int> selectedIndex = signal(0);

  /// 当前选中的语言信号
  final Signal<String> currentLanguage = signal('zh');

  /// 构造函数：初始化基础状态与副作用监听
  BaseState() {
    _init();
  }

  /// 初始化状态与副作用
  /// - 根据 screenSplitWidth 自动计算 isDesktop
  void _init() {
    effect(() {
      isDesktop.value = screenSplitWidth.value > 480;
    });
  }

  /// 更新屏幕分割宽度
  /// 调用此方法可动态调整 screenSplitWidth 的值
  void updateScreenSplitWidth(double width) {
    screenSplitWidth.value = width;
  }
}