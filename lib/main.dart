import 'dart:async';
import 'dart:io';
import 'package:astral/src/rust/api/utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/shared/utils/helpers/update_helper.dart';
import 'package:astral/shared/utils/helpers/regex_patterns.dart'; // 添加这行导入
import 'package:astral/core/app_s/log_capture.dart';
import 'package:astral/core/app_s/file_logger.dart';
import 'package:astral/core/app_s/global_error_handler.dart';
import 'package:astral/core/database/app_data.dart';
import 'package:astral/core/constants/window_manager.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/services/app_links/app_link_registry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:astral/src/rust/frb_generated.dart';
import 'package:astral/app.dart';

void main() async {
  // 初始化文件日志系统（Release 模式下不会创建文件）
  await FileLogger().init();
  GlobalErrorHandler.initialize();

  // 使用错误处理包装主应用
  runZonedGuarded(
    () async {
      await _initializeApp();
    },
    (error, stack) {
      // 输出到控制台
      print('\n=== 未捕获的错误 ===');
      print('错误: $error');
      print('堆栈跟踪:\n$stack');
      print('==================\n');

      // 记录到日志文件
      GlobalErrorHandler.logError(
        'Uncaught error in main zone',
        error: error,
        stack: stack,
      );
    },
  );
}

Future<void> _initializeApp() async {
  try {
    await RustLib.init();
    FileLogger().info('RustLib initialized');
    // initApp();

    // Linux 下检测是否为 root 权限
    if (!kIsWeb && Platform.isLinux) {
      final env = Platform.environment;
      if (env['USER'] != 'root' &&
          env['SUDO_USER'] == null &&
          env['UID'] != '0') {
        FileLogger().error('Linux requires sudo privileges');
        print('请使用 sudo 运行本程序！');
        exit(1);
      }
    }

    WidgetsFlutterBinding.ensureInitialized();

    if (Platform.isMacOS) {
      checkSudo().then((elevated) {
        if (!elevated) {
          FileLogger().warning('macOS elevation failed, exiting');
          exit(0); // 当前进程退出，交由新进程运行
        }
      });
    }

    await EasyLocalization.ensureInitialized();
    FileLogger().info('EasyLocalization initialized');

    await AppDatabase().init();
    FileLogger().info('Database initialized');

    // 初始化新的服务管理器
    final services = ServiceManager();
    await services.init();
    FileLogger().info('ServiceManager initialized');

    AppInfoUtil.init();
    FileLogger().info('AppInfoUtil initialized');

    await LogCapture().startCapture();
    FileLogger().info('LogCapture started');

    await UrlSchemeRegistrar.registerUrlScheme();
    FileLogger().info('URL scheme registered');

    await _initAppLinks();

    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      await WindowManagerUtils.initializeWindow();
      FileLogger().info('Window manager initialized');
    }

    _runApp();
  } catch (e, stack) {
    // 输出到控制台
    print('\n=== 应用初始化失败 ===');
    print('错误: $e');
    print('堆栈跟踪:\n$stack');
    print('=====================\n');

    // 记录到日志文件
    GlobalErrorHandler.logError(
      'Failed to initialize app',
      error: e,
      stack: stack,
    );
    rethrow;
  }
}

void _runApp() {
  FileLogger().info('Starting Flutter app');
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
      child: const KevinApp(),
    ),
  );
}

Future<void> _initAppLinks() async {
  try {
    final registry = AppLinkRegistry();
    await registry.initialize();
    FileLogger().info('App links initialized');
  } catch (e, stack) {
    // 输出到控制台
    print('警告: App links 初始化失败 - $e');

    // 记录到日志文件
    GlobalErrorHandler.logError(
      'Failed to initialize app links',
      error: e,
      stack: stack,
    );
  }
}
