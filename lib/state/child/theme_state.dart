import 'package:astral/core/persistent_signal.dart';
import 'package:flutter/material.dart';

class ThemeState {
    /// 主题颜色值，默认为蓝色
  late final PersistentSignal<Color> themeColor;

  /// 主题模式枚举值，默认跟随系统
  late final PersistentSignal<ThemeMode> themeModeValue;

  // init
  ThemeState() {
    themeColor = PersistentSignal("themeColor", Colors.blue);
    themeModeValue = PersistentSignal("themeModeValue", ThemeMode.system);
  }

}