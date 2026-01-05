import 'package:astral/shared/utils/network/astral_udp.dart';
import 'package:astral/core/constants/small_window_adapter.dart'; // 导入小窗口适配器
import 'package:astral/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:signals_flutter/signals_flutter.dart';

class KevinApp extends StatefulWidget {
  const KevinApp({super.key});
  @override
  State<KevinApp> createState() => _KevinAppState();
}

class _KevinAppState extends State<KevinApp> {
  final _services = ServiceManager();

  @override
  void initState() {
    super.initState();
    getIpv4AndIpV6Addresses();
    // 初始化链接服务
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 使用 Watch 监听主题变化
    return Watch((context) {
      // 读取当前主题颜色和模式，这样当它们变化时会自动重建
      final themeColor = _services.themeState.themeColor.value;
      final themeMode = _services.themeState.themeMode.value;

      return MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        // Insert this line
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
        home: MainScreen(),
      );
    });
  }
}
