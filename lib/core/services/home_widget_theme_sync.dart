import 'dart:io';

import 'package:astral/core/constants/home_widget_keys.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

/// 将当前 App 主题色写入小组件 SharedPreferences。
Future<void> syncHomeWidgetTheme({
  required Color seedColor,
  required ThemeMode themeMode,
  Brightness platformBrightness = Brightness.light,
}) async {
  if (!Platform.isAndroid) return;

  final brightness = switch (themeMode) {
    ThemeMode.dark => Brightness.dark,
    ThemeMode.light => Brightness.light,
    ThemeMode.system => platformBrightness,
  };
  final scheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  );

  await HomeWidget.saveWidgetData<int>(
    HomeWidgetKeys.themeCard,
    scheme.surface.toARGB32(),
  );
  await HomeWidget.saveWidgetData<int>(
    HomeWidgetKeys.themeCanvas,
    scheme.surfaceContainerHighest.toARGB32(),
  );
  await HomeWidget.saveWidgetData<int>(
    HomeWidgetKeys.themeTextPrimary,
    scheme.onSurface.toARGB32(),
  );
  await HomeWidget.saveWidgetData<int>(
    HomeWidgetKeys.themeTextSecondary,
    scheme.onSurfaceVariant.toARGB32(),
  );
  await HomeWidget.saveWidgetData<int>(
    HomeWidgetKeys.themeAccent,
    scheme.primary.toARGB32(),
  );
}
