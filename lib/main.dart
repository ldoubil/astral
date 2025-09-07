import 'dart:async';
import 'dart:io';
import 'package:astral/src/rust/api/simple.dart';
import 'package:astral/src/rust/api/utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/utils/up.dart';
import 'package:astral/utils/reg.dart'; // 添加这行导入
import 'package:astral/k/app_s/log_capture.dart';
import 'package:astral/k/database/app_data.dart';
import 'package:astral/k/mod/window_manager.dart';
import 'package:astral/services/app_links/app_link_registry.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:astral/src/rust/frb_generated.dart';
import 'package:astral/app.dart';
import 'package:astral/app_wrapper.dart';
import 'package:flutter/services.dart';
import 'package:astral/data/database/db_base.dart';

void main() async {
  await RustLib.init();
  // initApp();
  
  // 确保在任何UI组件初始化之前先初始化数据库和适配器
  WidgetsFlutterBinding.ensureInitialized();
  
  // 首先初始化Hive数据库和适配器（这必须在ThemeSettingsState使用之前完成）
  await DBbase.instance.initialize();
  
  // Linux 下检测是否为 root 权限
  if (!kIsWeb && Platform.isLinux) {
    final env = Platform.environment;
    if (env['USER'] != 'root' &&
        env['SUDO_USER'] == null &&
        env['UID'] != '0') {
      print('请使用 sudo 运行本程序！');
      exit(1);
    }
  }

  if (Platform.isMacOS) {
    checkSudo().then((elevated) {
      if (!elevated) {
        exit(0); // 当前进程退出，交由新进程运行
      }
    });
  }
  
  await EasyLocalization.ensureInitialized();
  await AppDatabase().init();
  AppInfoUtil.init();

  await LogCapture().startCapture();
  await UrlSchemeRegistrar.registerUrlScheme();
  await _initAppLinks();
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await WindowManagerUtils.initializeWindow();
  }
  _runApp();
}

void _runApp() {
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('zh'),
        Locale('zh', 'TW'),
        Locale('en'),
        Locale('ja'),
        Locale('ko'),
        Locale('ru'),
        Locale('fr'),
        Locale('de'),
        Locale('es'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('zh'),
      child: const AppWrapper(),
    ),
  );
}

Future<void> _initAppLinks() async {
  final registry = AppLinkRegistry();
  await registry.initialize();
}
