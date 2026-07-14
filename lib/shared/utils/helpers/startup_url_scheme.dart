import 'dart:io';
import 'package:flutter/foundation.dart';

const _startupRunKey =
    'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run';
const _startupValueName = 'Astral';

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

Future<void> handleStartupSetting(bool enable) async {
  if (!Platform.isWindows) return;

  final executablePath = Platform.resolvedExecutable;
  final command = '"$executablePath" --autostart';

  await _removeLegacyStartupShortcut();

  if (enable) {
    final result = await Process.run('reg', [
      'add',
      _startupRunKey,
      '/v',
      _startupValueName,
      '/t',
      'REG_SZ',
      '/d',
      command,
      '/f',
    ]);
    if (result.exitCode != 0 && kDebugMode) {
      debugPrint('Failed to register startup: ${result.stderr}');
    }
  } else {
    final result = await Process.run('reg', [
      'delete',
      _startupRunKey,
      '/v',
      _startupValueName,
      '/f',
    ]);
    if (result.exitCode != 0 && kDebugMode) {
      debugPrint('Failed to unregister startup: ${result.stderr}');
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
