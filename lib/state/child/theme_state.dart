import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ThemeState {
    /// 主题颜色值，默认为蓝色
  final Signal<Color> themeColor = signal(Colors.blue);

  /// 主题模式枚举值，默认跟随系统
  final Signal<ThemeMode> themeModeValue = signal(ThemeMode.system);

}