import 'dart:io';

import 'package:astral/data/database/persistent_signal_extension.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signals_flutter/signals_flutter.dart';

class BaseState {
  static final BaseState _instance = BaseState._internal();
  factory BaseState() {
    return _instance;
  }

  final currentPage = signal('home');
  /// **********************************************************************************************************

  /// 是否为桌面
  final Signal<bool> isDesktop = signal(false); // 初始化为false
  /// **********************************************************************************************************

  // 添加鼠标悬停状态跟踪
  final Signal<int?> hoveredIndex = signal(null);

  /// 软件名
  final Signal<String> appName = signal('Astral Game'); // 初始化为Astral Game


  /// 获取屏幕分割宽度 区分手机和桌面
  final Signal<double> screenSplitWidth = signal(480); // 初始化为480
  //更新屏幕分割宽度
  void updateScreenSplitWidth(double width) {
    screenSplitWidth.value = width;
    // 判断是否为桌面
    isDesktop.value = width > 480;
  }
  // 构建导航项
  final Signal<int> selectedIndex = Signal(0);

  BaseState._internal() {
    init();
  }

  void init() async {
   
  }


}
