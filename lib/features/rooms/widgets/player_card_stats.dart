import 'package:astral/src/rust/api/simple.dart';
import 'package:astral/core/ui/app_snack_bars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared stats / info-row widgets for player cards.
class PlayerCardStats {
  const PlayerCardStats._();

  static Widget buildConnectionStats(
    KVNodeConnectionStats connection,
    ColorScheme colorScheme,
  ) {
    final double uploadSpeedKB = connection.txBytes.toDouble();
    final double downloadSpeedKB = connection.rxBytes.toDouble();
    final double sentPackets = connection.txPackets.toDouble();
    final double receivedPackets = connection.rxPackets.toDouble();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildStatItem(
                Icons.upload_rounded,
                '累计上传',
                formatSpeed(uploadSpeedKB),
                colorScheme.primary,
                colorScheme,
              ),
              const SizedBox(height: 10),
              buildStatItem(
                Icons.arrow_upward_rounded,
                '累计发送包',
                '$sentPackets',
                colorScheme.primary,
                colorScheme,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildStatItem(
                Icons.download_rounded,
                '累计下载',
                formatSpeed(downloadSpeedKB),
                colorScheme.secondary,
                colorScheme,
              ),
              const SizedBox(height: 10),
              buildStatItem(
                Icons.arrow_downward_rounded,
                '累计接收包',
                '$receivedPackets',
                colorScheme.secondary,
                colorScheme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String formatSpeed(double speedInB) {
    final units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double value = speedInB;
    int unitIndex = 0;

    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }

    final formattedValue =
        value % 1 == 0
            ? value.toInt().toString()
            : value.toStringAsFixed(2).replaceFirst(RegExp(r'.0+$'), '');

    return '$formattedValue${units[unitIndex]}';
  }

  static Widget buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme, {
    Color? valueColor,
    bool showCopyButton = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        if (showCopyButton)
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: '复制$label',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              AppSnackBars.success(
                context,
                '已复制',
                'IP地址: $value',
                duration: const Duration(seconds: 2),
              );
            },
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
