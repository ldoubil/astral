import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

/// 文件日志管理器 - 输出到 exe 目录下的 log 文件
class FileLogger {
  static FileLogger? _instance;
  File? _logFile;
  IOSink? _logSink;
  final int _maxFileSize = 10 * 1024 * 1024; // 10MB
  bool _isInitialized = false;
  final _logQueue = <String>[];
  Timer? _flushTimer;

  // 工厂构造函数，获取单例实例
  factory FileLogger() {
    _instance ??= FileLogger._internal();
    return _instance!;
  }

  FileLogger._internal();

  /// 初始化文件日志系统
  Future<void> init() async {
    if (_isInitialized) return;

    // 只在 Debug 模式下初始化文件日志
    if (!kDebugMode) {
      _isInitialized = true; // 标记为已初始化，但不创建文件
      return;
    }

    try {
      // 获取可执行文件所在目录
      final executablePath = Platform.resolvedExecutable;
      final executableDir = Directory(executablePath).parent.path;
      final logDir = Directory(path.join(executableDir, 'log'));

      // 确保日志目录存在
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      // 日志文件路径
      final logFilePath = path.join(
        logDir.path,
        'astral_${DateTime.now().toString().split(' ')[0]}.log',
      );

      _logFile = File(logFilePath);

      // 每次启动清空日志文件
      if (await _logFile!.exists()) {
        await _logFile!.delete();
      }
      await _logFile!.create();

      // 打开写入流
      _logSink = _logFile!.openWrite(mode: FileMode.append);

      // 写入启动信息
      await _writeLog('=' * 80);
      await _writeLog('应用启动时间: ${DateTime.now()}');
      await _writeLog('可执行文件: $executablePath');
      await _writeLog('日志文件: $logFilePath');
      await _writeLog('=' * 80);

      _isInitialized = true;

      // 设置定时刷新（每秒）
      _flushTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _flushQueue();
      });

      debugPrint('FileLogger initialized: $logFilePath');
    } catch (e) {
      debugPrint('Failed to initialize FileLogger: $e');
    }
  }

  /// 记录日志（带级别）
  Future<void> log(
    String level,
    String message, {
    StackTrace? stackTrace,
  }) async {
    // Release 模式下不写入文件
    if (!kDebugMode || !_isInitialized) return;

    final timestamp = DateTime.now().toString();
    final logEntry = '[$timestamp] [$level] $message';

    _logQueue.add(logEntry);

    if (stackTrace != null) {
      _logQueue.add('Stack Trace:\n$stackTrace');
    }

    // 如果队列过大，立即刷新
    if (_logQueue.length > 10) {
      await _flushQueue();
    }
  }

  /// 记录信息日志
  Future<void> info(String message) => log('INFO', message);

  /// 记录警告日志
  Future<void> warning(String message) => log('WARNING', message);

  /// 记录错误日志
  Future<void> error(String message, {StackTrace? stackTrace}) =>
      log('ERROR', message, stackTrace: stackTrace);

  /// 记录严重错误日志
  Future<void> severe(String message, {StackTrace? stackTrace}) =>
      log('SEVERE', message, stackTrace: stackTrace);

  /// 记录调试日志
  Future<void> debug(String message) => log('DEBUG', message);

  /// 刷新队列中的日志到文件
  Future<void> _flushQueue() async {
    if (_logQueue.isEmpty || _logSink == null) return;

    try {
      // 检查文件大小
      if (_logFile != null && await _logFile!.exists()) {
        final fileSize = await _logFile!.length();
        if (fileSize >= _maxFileSize) {
          // 文件超过10MB，轮转日志
          await _rotateLog();
        }
      }

      // 批量写入
      final logsToWrite = List<String>.from(_logQueue);
      _logQueue.clear();

      for (final log in logsToWrite) {
        _logSink!.writeln(log);
      }

      await _logSink!.flush();
    } catch (e) {
      debugPrint('Failed to flush log queue: $e');
    }
  }

  /// 轮转日志文件（超过10MB时）
  Future<void> _rotateLog() async {
    try {
      await _logSink?.close();

      // 重命名旧文件
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final oldPath = _logFile!.path;
      final newPath = oldPath.replaceFirst('.log', '_$timestamp.log');
      await _logFile!.rename(newPath);

      debugPrint('Log file rotated: $newPath');

      // 创建新文件
      _logFile = File(oldPath);
      await _logFile!.create();
      _logSink = _logFile!.openWrite(mode: FileMode.append);

      // 清理旧日志（保留最近5个）
      await _cleanOldLogs();
    } catch (e) {
      debugPrint('Failed to rotate log file: $e');
    }
  }

  /// 清理旧日志文件，只保留最近的5个
  Future<void> _cleanOldLogs() async {
    try {
      final logDir = _logFile!.parent;
      final logFiles =
          await logDir
              .list()
              .where((entity) => entity is File && entity.path.endsWith('.log'))
              .cast<File>()
              .toList();

      if (logFiles.length > 5) {
        // 按修改时间排序
        logFiles.sort(
          (a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()),
        );

        // 删除最旧的文件
        for (var i = 0; i < logFiles.length - 5; i++) {
          await logFiles[i].delete();
          debugPrint('Deleted old log file: ${logFiles[i].path}');
        }
      }
    } catch (e) {
      debugPrint('Failed to clean old logs: $e');
    }
  }

  /// 直接写入日志（不经过队列）
  Future<void> _writeLog(String message) async {
    try {
      _logSink?.writeln(message);
      await _logSink?.flush();
    } catch (e) {
      debugPrint('Failed to write log: $e');
    }
  }

  /// 关闭日志系统
  Future<void> close() async {
    _flushTimer?.cancel();
    await _flushQueue();
    await _logSink?.close();
    _logSink = null;
    _isInitialized = false;
    debugPrint('FileLogger closed');
  }

  /// 获取日志文件路径
  String? get logFilePath => _logFile?.path;

  /// 检查是否已初始化
  bool get isInitialized => _isInitialized;
}
