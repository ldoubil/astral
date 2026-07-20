import 'dart:async';
import 'dart:io';
import 'package:astral/src/rust/api/utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/core/platform/app_info.dart';
import 'package:astral/core/platform/startup_url_scheme.dart';
import 'package:astral/core/bootstrap/log_capture.dart';
import 'package:astral/core/bootstrap/file_logger.dart';
import 'package:astral/core/bootstrap/global_error_handler.dart';
import 'package:astral/core/database/app_data.dart';
import 'package:astral/core/platform/window_manager.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/app_links/app_link_registry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart'
    show ExternalLibrary;
import 'package:path/path.dart' as p;
import 'package:astral/src/rust/frb_generated.dart';
import 'package:astral/app.dart';

void main(List<String> args) async {
  // 检测是否为自动启动
  if (args.contains('--autostart')) {
    isAutostart = true;
  }

  // 初始化文件日志系统（Release 模式下不会创建文件）
  await FileLogger().init();
  GlobalErrorHandler.initialize();

  // 使用错误处理包装主应用
  runZonedGuarded(
    () async {
      await _initializeApp();
    },
    (error, stack) {
      GlobalErrorHandler.logError(
        'Uncaught error in main zone',
        error: error,
        stack: stack,
      );
    },
  );
}

/// 初始化 FRB 动态库。
///
/// 生成代码里 `kDefaultExternalLibraryLoaderConfig` 会优先从
/// `rust/target/release/` 加载；若本机曾单独 `cargo build --release`，
/// 会一直误用那份旧 dll（与当前 Dart 绑定 content hash 不一致）。
/// Flutter Windows 会把 cargokit 编好的 `rust_lib_astral.dll` 放在 exe 同目录，
/// 因此桌面端优先从该路径显式加载。
Future<void> _initRustLib() async {
  if (!kIsWeb && Platform.isWindows) {
    final bundledPath = p.join(
      File(Platform.resolvedExecutable).parent.path,
      'rust_lib_astral.dll',
    );
    if (File(bundledPath).existsSync()) {
      await RustLib.init(
        externalLibrary: ExternalLibrary.open(bundledPath),
      );
      return;
    }
  }
  await RustLib.init();
}

Future<void> _initializeApp() async {
  try {
    await _initRustLib();
    FileLogger().info('RustLib initialized');

    // Linux 下检测是否为 root 权限
    if (!kIsWeb && Platform.isLinux) {
      final env = Platform.environment;
      if (env['USER'] != 'root' &&
          env['SUDO_USER'] == null &&
          env['UID'] != '0') {
        FileLogger().error('Linux requires sudo privileges');
        debugPrint('请使用 sudo 运行本程序！');
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

    // 初始化贴片服务
    services.widgets.initialize();
    if (Platform.isAndroid) {
      await services.widgets.syncAll();
    }
    FileLogger().info('WidgetService initialized');

    try {
      await AppInfoUtil.init().timeout(const Duration(seconds: 3));
      FileLogger().info('AppInfoUtil initialized');
    } catch (e) {
      FileLogger().warning('AppInfoUtil init timeout/failure, continue: $e');
    }

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
        Locale('en'),
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
    FileLogger().warning('App links 初始化失败: $e');
    GlobalErrorHandler.logError(
      'Failed to initialize app links',
      error: e,
      stack: stack,
    );
  }
}
