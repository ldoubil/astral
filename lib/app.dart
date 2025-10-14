import 'package:astral/state/app_state.dart';
import 'package:astral/utils/net_astral_udp.dart';
import 'package:astral/core/mod/small_window_adapter.dart'; // 导入小窗口适配器
import 'package:astral/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:signals_flutter/signals_flutter.dart';

class KevinApp extends StatefulWidget {
  const KevinApp({super.key});
  @override
  State<KevinApp> createState() => _KevinAppState();
}

class _KevinAppState extends State<KevinApp> {
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
        colorSchemeSeed: AppState().themeState.themeColor.watch(
          context,
        ), // 设置当前主题颜色,
        brightness: Brightness.light,
      ).copyWith(
        textTheme: Typography.material2021().black.apply(fontFamily: 'MiSans'),
        primaryTextTheme: Typography.material2021().black.apply(
          fontFamily: 'MiSans',
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppState().themeState.themeColor.watch(context),
        brightness: Brightness.dark,
      ).copyWith(
        textTheme: Typography.material2021().white.apply(fontFamily: 'MiSans'),
        primaryTextTheme: Typography.material2021().white.apply(
          fontFamily: 'MiSans',
        ),
      ),
      themeMode: AppState().themeState.themeModeValue.watch(context), // 设置当前主题模式
      home: MainScreen(),
    );
  }
}
