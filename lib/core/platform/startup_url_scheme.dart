import 'dart:io';
import 'package:flutter/foundation.dart';

const _taskName = 'Astral';

/// 由 main.dart 在启动时设置，标记当前是否为自动启动
bool isAutostart = false;

Future<void> _removeLegacyStartupShortcut() async {
  if (!Platform.isWindows) return;

  try {
    final startupFolder =
        '${Platform.environment['APPDATA']}\\Microsoft\\Windows\\Start Menu\\Programs\\Startup';
    final shortcutPath = '$startupFolder\\Astral.lnk';
    final shortcut = File(shortcutPath);
    if (await shortcut.exists()) {
      await shortcut.delete();
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Failed to remove legacy startup shortcut: $e');
    }
  }
}

/// 移除旧的注册表 Run 键（如果存在），迁移到 Task Scheduler 方案
Future<void> _removeLegacyRegistryRun() async {
  try {
    await Process.run('reg', [
      'delete',
      'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run',
      '/v',
      'Astral',
      '/f',
    ]);
  } catch (_) {
    // 旧键可能不存在，忽略错误
  }
}

Future<void> handleStartupSetting(bool enable) async {
  if (!Platform.isWindows) return;

  final executablePath = Platform.resolvedExecutable;
  final command = '"$executablePath" --autostart';

  await _removeLegacyStartupShortcut();
  await _removeLegacyRegistryRun();

  if (enable) {
    // 使用 Task Scheduler ONSTART 触发器，系统启动时即运行（登录前）
    final result = await Process.run('schtasks', [
      '/create',
      '/tn',
      _taskName,
      '/tr',
      command,
      '/sc',
      'ONSTART',
      '/rl',
      'HIGHEST',
      '/f',
    ]);
    if (result.exitCode != 0 && kDebugMode) {
      debugPrint('Failed to register startup task: ${result.stderr}');
    }
  } else {
    final result = await Process.run('schtasks', [
      '/delete',
      '/tn',
      _taskName,
      '/f',
    ]);
    if (result.exitCode != 0 && kDebugMode) {
      debugPrint('Failed to remove startup task: ${result.stderr}');
    }
  }
}

class UrlSchemeRegistrar {
  /// 注册 URL scheme 到 Windows 注册表
  static Future<bool> registerUrlScheme() async {
    if (!Platform.isWindows) return true;

    try {
      final executablePath = Platform.resolvedExecutable;

      final commands = [
        [
          'add',
          'HKEY_CURRENT_USER\\Software\\Classes\\astral',
          '/ve',
          '/d',
          'URL:Astral Protocol',
          '/f',
        ],
        [
          'add',
          'HKEY_CURRENT_USER\\Software\\Classes\\astral',
          '/v',
          'URL Protocol',
          '/d',
          '',
          '/f',
        ],
        [
          'add',
          'HKEY_CURRENT_USER\\Software\\Classes\\astral\\DefaultIcon',
          '/ve',
          '/d',
          '"$executablePath",1',
          '/f',
        ],
        [
          'add',
          'HKEY_CURRENT_USER\\Software\\Classes\\astral\\shell\\open\\command',
          '/ve',
          '/d',
          '"$executablePath" "%1"',
          '/f',
        ],
      ];

      for (final command in commands) {
        final result = await Process.run('reg', command);
        if (result.exitCode != 0) {
          if (kDebugMode) {
            debugPrint('Failed to execute reg command: ${command.join(' ')}');
            debugPrint('Error: ${result.stderr}');
          }
          return false;
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error registering URL scheme: $e');
      }
      return false;
    }
  }
}