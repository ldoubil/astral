import 'dart:io';
import 'package:astral/core/services/magic_wall_auto_service.dart';
import 'package:flutter/material.dart';

/// 魔法墙状态卡片
class MagicWallStatusCard extends StatefulWidget {
  const MagicWallStatusCard({super.key});

  @override
  State<MagicWallStatusCard> createState() => _MagicWallStatusCardState();
}

class _MagicWallStatusCardState extends State<MagicWallStatusCard> {
  final _service = MagicWallAutoService();

  @override
  Widget build(BuildContext context) {
    // 非 Windows 平台不显示
    if (!Platform.isWindows) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final isRunning = _service.isRunning;
    final engineStarted = _service.engineStarted;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 状态图标
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isRunning && engineStarted
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.security,
                color: isRunning && engineStarted ? Colors.green : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // 状态信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '魔法墙',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              isRunning && engineStarted
                                  ? Colors.green
                                  : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isRunning && engineStarted ? '运行中' : '未运行',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 后台运行标记
            if (isRunning && engineStarted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '自动',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
