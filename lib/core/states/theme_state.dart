import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 主题状态（纯Signal，不包含业务逻辑）
class ThemeState {
  final themeColor = signal<Color>(Colors.blue);
  final themeMode = signal<ThemeMode>(ThemeMode.system);

  void updateColor(Color color) {
    themeColor.value = color;
  }

  void updateMode(ThemeMode mode) {
    themeMode.value = mode;
  }

  void updateAll({Color? color, ThemeMode? mode}) {
    if (color != null) themeColor.value = color;
    if (mode != null) themeMode.value = mode;
  }
}
