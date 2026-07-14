import 'package:flutter/foundation.dart';
import 'file_logger.dart';

/// 全局错误处理器 - 捕获所有错误和警告
class GlobalErrorHandler {
  static bool _isInitialized = false;

  /// 初始化全局错误处理
  static void initialize() {
    if (_isInitialized) return;

    // 捕获 Flutter 框架错误
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logFlutterError(details);
    };

    // 捕获异步错误
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError('Uncaught async error', error, stack);
      return true;
    };

    // 重写 debugPrint 以同时输出到文件
    final originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      originalDebugPrint(message, wrapWidth: wrapWidth);
      if (message != null) {
        FileLogger().debug(message);
      }
    };

    _isInitialized = true;
    FileLogger().info('GlobalErrorHandler initialized');
  }

  /// 记录 Flutter 错误
  static void _logFlutterError(FlutterErrorDetails details) {
    final logger = FileLogger();

    final errorMessage = details.exception.toString();
    final context = details.context?.toString() ?? 'No context';
    final library = details.library ?? 'Unknown library';

    logger.error(
      'Flutter Error in $library\n'
      'Context: $context\n'
      'Error: $errorMessage',
      stackTrace: details.stack,
    );

    // 如果是布局错误，记录警告而不是错误
    if (details.exception.toString().contains('overflow') ||
        details.exception.toString().contains('RenderFlex')) {
      logger.warning('Layout issue detected: $errorMessage');
    }
  }

  /// 记录一般错误
  static void _logError(String source, Object error, StackTrace stack) {
    FileLogger().error('$source: ${error.toString()}', stackTrace: stack);
  }

  /// 手动记录错误
  static void logError(String message, {Object? error, StackTrace? stack}) {
    final fullMessage = error != null ? '$message: $error' : message;
    FileLogger().error(fullMessage, stackTrace: stack);
  }
}
