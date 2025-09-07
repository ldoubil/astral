import 'package:astral/data/database/persistent_signal_extension.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ThemeSettingsState {
  static final ThemeSettingsState _instance = ThemeSettingsState._internal();
  factory ThemeSettingsState() {
    return _instance;
  }

  ThemeSettingsState._internal() {
    init();
  }

  void init() async {
    // 设置持久化监听
  }

  // persistWith会自动从数据库加载值，如果没有则保存当前默认值
  final Signal<Color> themeColor = signal(Colors.deepOrangeAccent)
    ..persistWith('theme', 'themeColor');
  final Signal<ThemeMode> themeMode = signal(ThemeMode.system)
    ..persistWith('theme', 'themeMode');
  final Signal<String> currentLanguage = signal('zh')
    ..persistWith('theme', 'currentLanguage');
}
