import 'package:astral/core/platform/small_window_adapter.dart';
import 'package:astral/shared/widgets/common/home_widget_refresh_binder.dart';
import 'package:astral/features/home/pages/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:signals_flutter/signals_flutter.dart';

class KevinApp extends StatelessWidget {
  const KevinApp({super.key});

  @override
  Widget build(BuildContext context) {
    final services = ServiceManager();

    // 使用 Watch 监听主题变化
    return Watch((context) {
      // 读取当前主题颜色和模式，这样当它们变化时会自动重建
      final themeColor = services.themeState.themeColor.value;
      final themeMode = services.themeState.themeMode.value;

      return MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        builder: (BuildContext context, Widget? child) {
          // 处理 MediaQuery 异常问题，特别是小米澎湃系统和安卓小窗口
          MediaQueryData mediaQuery = MediaQuery.of(context);

          // 使用小窗口适配器处理媒体查询
          mediaQuery = SmallWindowAdapter.adaptMediaQuery(mediaQuery);

          return MediaQuery(
            data: mediaQuery,
            child: SmallWindowAdapter.createSafeAreaAdapter(
              child ?? const SizedBox.shrink(),
            ),
          );
        },
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: themeColor, // 使用监听的主题颜色
          brightness: Brightness.light,
        ).copyWith(
          textTheme: Typography.material2021().black.apply(
            fontFamily: 'MiSans',
          ),
          primaryTextTheme: Typography.material2021().black.apply(
            fontFamily: 'MiSans',
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: themeColor, // 使用监听的主题颜色
          brightness: Brightness.dark,
        ).copyWith(
          textTheme: Typography.material2021().white.apply(
            fontFamily: 'MiSans',
          ),
          primaryTextTheme: Typography.material2021().white.apply(
            fontFamily: 'MiSans',
          ),
        ),
        themeMode: themeMode, // 使用监听的主题模式
        home: const HomeWidgetRefreshBinder(child: MainScreen()),
      );
    });
  }
}
