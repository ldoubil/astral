import 'dart:io';
import 'package:astral/k/services/service_manager.dart';
import 'package:astral/k/mod/small_window_adapter.dart'; // 导入小窗口适配器
import 'package:astral/widgets/theme_selector.dart';
import 'package:astral/widgets/windows_controls.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

// 获取主题模式的文本描述
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

/// 状态栏组件
/// 实现了PreferredSizeWidget接口以指定首选高度
class StatusBar extends StatelessWidget implements PreferredSizeWidget {
  const StatusBar({super.key});

  /// 指定状态栏的首选高度为36
  @override
  Size get preferredSize => const Size.fromHeight(36);

  // 检查是否是圣诞期间
  bool get _isChristmasSeason {
    final now = DateTime.now();
    return now.month == 12 && now.day >= 22 && now.day <= 28;
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前主题的配色方案
    final colorScheme = Theme.of(context).colorScheme;
    final bool isSmallWindow = SmallWindowAdapter.shouldApplyAdapter(context);

    // 在小窗口模式下使用更简洁的状态栏
    if (isSmallWindow) {
      return PreferredSize(
        preferredSize: const Size.fromHeight(36),
        child: AppBar(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          toolbarHeight: 32, // 在小窗口模式下降低高度
          title: Text(
            ServiceManager().appSettingsState.appName.value,
            style: TextStyle(
              fontSize: 14, // 在小窗口模式下使用更小的字体
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                switch (ServiceManager().themeState.themeMode.value) {
                  ThemeMode.light => Icons.wb_sunny,
                  ThemeMode.dark => Icons.nightlight_round,
                  ThemeMode.system => Icons.auto_mode,
                },
                size: 16, // 在小窗口模式下使用更小的图标
              ),
              onPressed: () {
                final currentMode = ServiceManager().themeState.themeMode.value;
                final newMode = switch (currentMode) {
                  ThemeMode.light => ThemeMode.dark,
                  ThemeMode.dark => ThemeMode.system,
                  ThemeMode.system => ThemeMode.light,
                };
                ServiceManager().theme.updateThemeMode(newMode);
              },
              padding: const EdgeInsets.all(4), // 减小内边距
            ),
            PopupMenuButton<Locale>(
              icon: Icon(Icons.language, size: 16),
              tooltip: LocaleKeys.language.tr(),
              onSelected: (Locale locale) {
                String langCode =
                    locale.countryCode != null
                        ? '${locale.languageCode}_${locale.countryCode}'
                        : locale.languageCode;
                ServiceManager().theme.updateLanguage(langCode);
                context.setLocale(locale);
              },
              itemBuilder:
                  (BuildContext context) => [
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
                    PopupMenuItem(
                      value: const Locale('ja'),
                      child: Row(
                        children: [
                          Text('🇯🇵'),
                          SizedBox(width: 8),
                          Text('日本語'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: const Locale('ko'),
                      child: Row(
                        children: [
                          Text('🇰🇷'),
                          SizedBox(width: 8),
                          Text('한국어'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: const Locale('ru'),
                      child: Row(
                        children: [
                          Text('🇷🇺'),
                          SizedBox(width: 8),
                          Text('Русский'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: const Locale('fr'),
                      child: Row(
                        children: [
                          Text('🇫🇷'),
                          SizedBox(width: 8),
                          Text('Français'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: const Locale('de'),
                      child: Row(
                        children: [
                          Text('🇩🇪'),
                          SizedBox(width: 8),
                          Text('Deutsch'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: const Locale('es'),
                      child: Row(
                        children: [
                          Text('🇪🇸'),
                          SizedBox(width: 8),
                          Text('Español'),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
      );
    }

    return PreferredSize(
      // 设置状态栏高度
      preferredSize: const Size.fromHeight(36),
      child: GestureDetector(
        // 处理拖动事件，仅在桌面平台启用窗口拖动
        onPanStart: (details) {
          if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
            windowManager.startDragging();
          }
        },
        child: AppBar(
          // 显示应用名称
          title: ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                ).createShader(bounds),
            child: Text(
              ServiceManager().appSettingsState.appName.value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.white, // 必须设置为白色以显示渐变效果
              ),
            ),
          ),
          // 设置AppBar的背景色和前景色
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          toolbarHeight: 36,
          // 在桌面平台显示窗口控制按钮
          actions: [
            // 圣诞祝福
            if (_isChristmasSeason)
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
            if (_isChristmasSeason) const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                // 根据当前主题模式选择对应图标
                switch (ServiceManager().themeState.themeMode.value) {
                  ThemeMode.light => Icons.wb_sunny,
                  ThemeMode.dark => Icons.nightlight_round,
                  ThemeMode.system => Icons.auto_mode,
                },
                size: 20,
              ),
              onPressed: () {
                final currentMode = ServiceManager().themeState.themeMode.value;
                final newMode = switch (currentMode) {
                  ThemeMode.light => ThemeMode.dark,
                  ThemeMode.dark => ThemeMode.system,
                  ThemeMode.system => ThemeMode.light,
                };
                ServiceManager().theme.updateThemeMode(newMode);
              },
              tooltip: getThemeModeText(
                ServiceManager().themeState.themeMode.value,
              ),
              padding: const EdgeInsets.all(8),
            ),

            IconButton(
              icon: const Icon(Icons.color_lens, size: 20), // 减小图标大小
              onPressed: () => showThemeColorPicker(context),
              tooltip: '选择主题颜色',
              padding: const EdgeInsets.all(4), // 减小内边距
            ),
            PopupMenuButton<Locale>(
              icon: const Icon(Icons.language, size: 20),
              tooltip: LocaleKeys.language.tr(),
              onSelected: (Locale locale) {
                String langCode =
                    locale.countryCode != null
                        ? '${locale.languageCode}_${locale.countryCode}'
                        : locale.languageCode;
                ServiceManager().theme.updateLanguage(langCode);
                context.setLocale(locale);
              },
              itemBuilder:
                  (BuildContext context) => [
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
                    PopupMenuItem(
                      value: const Locale('ja'),
                      child: Row(
                        children: [
                          Text('🇯🇵'),
                          SizedBox(width: 8),
                          Text('日本語'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: const Locale('ko'),
                      child: Row(
                        children: [
                          Text('🇰🇷'),
                          SizedBox(width: 8),
                          Text('한국어'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: const Locale('ru'),
                      child: Row(
                        children: [
                          Text('🇷🇺'),
                          SizedBox(width: 8),
                          Text('Русский'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: const Locale('fr'),
                      child: Row(
                        children: [
                          Text('🇫🇷'),
                          SizedBox(width: 8),
                          Text('Français'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: const Locale('de'),
                      child: Row(
                        children: [
                          Text('🇩🇪'),
                          SizedBox(width: 8),
                          Text('Deutsch'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: const Locale('es'),
                      child: Row(
                        children: [
                          Text('🇪🇸'),
                          SizedBox(width: 8),
                          Text('Español'),
                        ],
                      ),
                    ),
                  ],
            ),
            if (Platform.isWindows || Platform.isMacOS || Platform.isLinux)
              const WindowControls(),
          ],
        ),
      ),
    );
  }
}
