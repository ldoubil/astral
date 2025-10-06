import 'package:astral/state/typed_persistent_signal.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 主题设置状态管理类 - 类型化版本
/// 管理应用程序的主题、语言等设置，使用类型化存储系统
class ThemeSettingsState {
  static final ThemeSettingsState _instance = ThemeSettingsState._internal();
  factory ThemeSettingsState() => _instance;

  /// 主题颜色 - 使用类型化自动持久化
  final TypedPersistentSignal<Color> themeColor = TypedPersistentSignal(
    'themeColor',
    Colors.deepOrangeAccent,
  );

  /// 主题模式 - 使用类型化自动持久化
  final TypedPersistentSignal<ThemeMode> themeMode = TypedPersistentSignal(
    'themeMode',
    ThemeMode.system,
  );

  /// 当前语言 - 使用类型化自动持久化
  final TypedPersistentSignal<String> currentLanguage = TypedPersistentSignal(
    'currentLanguage',
    'zh',
  );

  /// 是否启用动画效果
  final TypedPersistentSignal<bool> enableAnimations = TypedPersistentSignal(
    'enableAnimations',
    true,
  );

  /// 字体大小缩放比例
  final TypedPersistentSignal<double> fontScale = TypedPersistentSignal(
    'fontScale',
    1.0,
  );

  /// 是否使用系统字体
  final TypedPersistentSignal<bool> useSystemFont = TypedPersistentSignal(
    'useSystemFont',
    true,
  );

  /// 是否启用高对比度模式
  final TypedPersistentSignal<bool> highContrast = TypedPersistentSignal(
    'highContrast',
    false,
  );

  ThemeSettingsState._internal();

  /// 预定义的主题颜色选项
  static const List<Color> predefinedColors = [
    Colors.deepOrangeAccent,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];

  /// 支持的语言列表
  static const Map<String, String> supportedLanguages = {
    'zh': '中文',
    'en': 'English',
    'ja': '日本語',
    'ko': '한국어',
  };

  /// 设置主题颜色
  void setThemeColor(Color color) {
    themeColor.value = color;
  }

  /// 设置主题模式
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
  }

  /// 设置语言
  void setLanguage(String languageCode) {
    if (supportedLanguages.containsKey(languageCode)) {
      currentLanguage.value = languageCode;
    }
  }

  /// 切换主题模式（在 light、dark、system 之间循环）
  void toggleThemeMode() {
    switch (themeMode.value) {
      case ThemeMode.system:
        themeMode.value = ThemeMode.light;
        break;
      case ThemeMode.light:
        themeMode.value = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        themeMode.value = ThemeMode.system;
        break;
    }
  }

  /// 设置动画效果
  void setEnableAnimations(bool enable) {
    enableAnimations.value = enable;
  }

  /// 设置字体缩放比例
  void setFontScale(double scale) {
    // 限制缩放比例在合理范围内
    if (scale >= 0.8 && scale <= 2.0) {
      fontScale.value = scale;
    }
  }

  /// 设置是否使用系统字体
  void setUseSystemFont(bool useSystem) {
    useSystemFont.value = useSystem;
  }

  /// 设置高对比度模式
  void setHighContrast(bool enable) {
    highContrast.value = enable;
  }

  /// 重置所有设置到默认值
  void resetToDefaults() {
    themeColor.value = Colors.deepOrangeAccent;
    themeMode.value = ThemeMode.system;
    currentLanguage.value = 'zh';
    enableAnimations.value = true;
    fontScale.value = 1.0;
    useSystemFont.value = true;
    highContrast.value = false;
  }

  /// 获取当前语言的显示名称
  String get currentLanguageDisplayName {
    return supportedLanguages[currentLanguage.value] ?? '中文';
  }

  /// 检查是否为深色主题
  bool get isDarkTheme {
    return themeMode.value == ThemeMode.dark;
  }

  /// 检查是否为浅色主题
  bool get isLightTheme {
    return themeMode.value == ThemeMode.light;
  }

  /// 检查是否跟随系统主题
  bool get isSystemTheme {
    return themeMode.value == ThemeMode.system;
  }

  /// 获取主题数据
  ThemeData getThemeData({required bool isDark}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: themeColor.value,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: useSystemFont.value ? null : 'Roboto',
      visualDensity: VisualDensity.adaptivePlatformDensity,
      // 根据设置调整其他主题属性
    );
  }
}
