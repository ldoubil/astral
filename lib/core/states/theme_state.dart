import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 主题状态（纯Signal，不包含业务逻辑）
class ThemeState {
  // Signal状态
  final themeColor = signal<Color>(Colors.blue);
  final themeMode = signal<ThemeMode>(ThemeMode.system);
  final currentLanguage = signal('zh');

  // 简单的状态更新方法（不涉及持久化）
  void updateColor(Color color) {
    themeColor.value = color;
  }

  void updateMode(ThemeMode mode) {
    themeMode.value = mode;
  }

  void updateLanguage(String language) {
    currentLanguage.value = language;
  }

  // 批量更新
  void updateAll({Color? color, ThemeMode? mode, String? language}) {
    if (color != null) themeColor.value = color;
    if (mode != null) themeMode.value = mode;
    if (language != null) currentLanguage.value = language;
  }
}
