import 'dart:io';

import 'package:astral/core/models/room.dart';
import 'package:astral/core/models/server_mod.dart';
import 'package:astral/core/ui/app_snack_bars.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const String npcapTutorialUrl =
    'https://astral.fan/quick-start/download-install/';

bool containsFaketcp(Room room, List<ServerMod> enabledServers) {
  final roomHasFaketcp = room.servers.any(
    (url) => url.toLowerCase().trim().startsWith('faketcp://'),
  );
  final globalHasFaketcp = enabledServers.any(
    (server) =>
        server.faketcp == true ||
        server.url.toLowerCase().trim().startsWith('faketcp://'),
  );
  return roomHasFaketcp || globalHasFaketcp;
}

Future<bool> hasNpcapDriver() async {
  final winDir = Platform.environment['WINDIR'] ?? r'C:\Windows';
  final candidates = <String>[
    '$winDir\\System32\\Npcap\\wpcap.dll',
    '$winDir\\SysWOW64\\Npcap\\wpcap.dll',
    '$winDir\\System32\\drivers\\npcap.sys',
    r'C:\Program Files\Npcap\NPFInstall.exe',
    r'C:\Program Files (x86)\Npcap\NPFInstall.exe',
  ];

  for (final path in candidates) {
    if (await File(path).exists()) {
      return true;
    }
  }

  // 注册表检查（官方安装通常会写入）
  for (final key in const [
    r'HKLM\SOFTWARE\Npcap',
    r'HKLM\SOFTWARE\WOW6432Node\Npcap',
  ]) {
    try {
      final result = await Process.run('reg', ['query', key]);
      if (result.exitCode == 0) {
        return true;
      }
    } catch (_) {
      // 忽略查询异常
    }
  }

  // 服务配置检查：必须能匹配到 Npcap 关键字，避免误判其他同名/兼容驱动
  for (final service in const ['npcap', 'npf']) {
    try {
      final result = await Process.run('sc', ['qc', service]);
      final output = '${result.stdout}\n${result.stderr}'.toLowerCase();
      if (result.exitCode == 0 &&
          (output.contains('npcap') ||
              output.contains(r'\npcap') ||
              output.contains('npcap packet driver'))) {
        return true;
      }
    } catch (_) {
      // 忽略命令不可用等异常，按未安装处理
    }
  }

  return false;
}

Future<bool?> showNpcapRequiredDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          title: const Text('需要 Npcap 驱动'),
          content: const Text(
            '检测到当前连接包含 FakeTCP 服务器。\n'
            'Windows 需要先安装 Npcap 驱动后才能使用 FakeTCP。\n\n'
            '是否前往 astral.fan 查看安装教程？',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('查看教程'),
            ),
          ],
        ),
  );
}

Future<void> openNpcapTutorial(BuildContext context) async {
  final uri = Uri.parse(npcapTutorialUrl);
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) {
    AppSnackBars.error(context, '打开失败', '无法打开教程页面，请手动访问 astral.fan');
  }
}
