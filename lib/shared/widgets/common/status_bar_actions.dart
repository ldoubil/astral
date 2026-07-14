import 'dart:io';

import 'package:astral/core/services/service_manager.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/shared/widgets/common/theme_selector.dart';
import 'package:astral/shared/widgets/common/windows_controls.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 获取主题模式的文本描述
String getThemeModeText(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return '亮色模式';
    case ThemeMode.dark:
      return '暗色模式';
    case ThemeMode.system:
      return '跟随系统';
  }
}

List<PopupMenuEntry<Locale>> buildLanguageMenuItems() {
  return [
    PopupMenuItem(
      value: const Locale('zh'),
      child: Row(
        children: [
          Text('🇨🇳'),
          SizedBox(width: 8),
          Text('简体中文'),
        ],
      ),
    ),
    PopupMenuItem(
      value: const Locale('en'),
      child: Row(
        children: [
          Text('🇺🇸'),
          SizedBox(width: 8),
          Text('English'),
        ],
      ),
    ),
  ];
}

IconData getThemeModeIcon(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => Icons.wb_sunny,
    ThemeMode.dark => Icons.nightlight_round,
    ThemeMode.system => Icons.auto_mode,
  };
}

List<PopupMenuEntry<ThemeMode>> buildThemeModeMenuItems(ThemeMode current) {
  Widget row(ThemeMode mode, String label) {
    return Row(
      children: [
        Icon(getThemeModeIcon(mode), size: 18),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        if (current == mode)
          Icon(Icons.check, size: 18, color: Colors.green.shade600),
      ],
    );
  }

  return [
    PopupMenuItem(
      value: ThemeMode.system,
      child: row(ThemeMode.system, '跟随系统'),
    ),
    PopupMenuItem(
      value: ThemeMode.light,
      child: row(ThemeMode.light, '亮色模式'),
    ),
    PopupMenuItem(
      value: ThemeMode.dark,
      child: row(ThemeMode.dark, '暗色模式'),
    ),
  ];
}

Widget buildThemeModeMenuButton({
  required double iconSize,
  EdgeInsets padding = EdgeInsets.zero,
}) {
  return Watch((context) {
    final mode = ServiceManager().themeState.themeMode.watch(context);

    return PopupMenuButton<ThemeMode>(
      icon: Icon(getThemeModeIcon(mode), size: iconSize),
      tooltip: getThemeModeText(mode),
      padding: padding,
      onSelected: ServiceManager().theme.updateThemeMode,
      itemBuilder: (context) => buildThemeModeMenuItems(mode),
    );
  });
}

/// 小窗口模式状态栏 actions
List<Widget> buildCompactStatusBarActions(BuildContext context) {
  return [
    buildThemeModeMenuButton(
      iconSize: 16,
      padding: const EdgeInsets.all(4),
    ),
    PopupMenuButton<Locale>(
      icon: Icon(Icons.language, size: 16),
      tooltip: LocaleKeys.language.tr(),
      onSelected: (Locale locale) {
        context.setLocale(locale);
      },
      itemBuilder: (BuildContext context) => buildLanguageMenuItems(),
    ),
  ];
}

/// 桌面模式状态栏 actions
List<Widget> buildDesktopStatusBarActions(
  BuildContext context, {
  required bool isChristmasSeason,
  required ColorScheme colorScheme,
}) {
  return [
    if (isChristmasSeason)
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '爱你们的Kevin',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const Text('🎄', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              '圣诞快乐',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 6),
            const Text('🎅', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    if (isChristmasSeason) const SizedBox(width: 8),
    buildThemeModeMenuButton(
      iconSize: 20,
      padding: const EdgeInsets.all(8),
    ),
    IconButton(
      icon: const Icon(Icons.color_lens, size: 20),
      onPressed: () => showThemeColorPicker(context),
      tooltip: '选择主题颜色',
      padding: const EdgeInsets.all(4),
    ),
    PopupMenuButton<Locale>(
      icon: const Icon(Icons.language, size: 20),
      tooltip: LocaleKeys.language.tr(),
      onSelected: (Locale locale) {
        context.setLocale(locale);
      },
      itemBuilder: (BuildContext context) => buildLanguageMenuItems(),
    ),
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux)
      const WindowControls(),
  ];
}
