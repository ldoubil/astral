import 'dart:io';

import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Start/stop and status header for the Magic Wall engine.
class MagicWallControlPanel extends StatelessWidget {
  const MagicWallControlPanel({
    super.key,
    required this.isRunning,
    required this.onToggle,
  });

  final ReadonlySignal<bool> isRunning;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) => Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '魔法墙引擎',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isRunning.value ? '运行中' : '已停止',
                          style: TextStyle(
                            color:
                                isRunning.value ? Colors.green : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isRunning.value,
                    onChanged:
                        Platform.isWindows ? (value) => onToggle() : null,
                  ),
                ],
              ),
              if (!Platform.isWindows) ...[
                const SizedBox(height: 8),
                const Text(
                  '⚠️ 魔法墙仅支持 Windows 平台',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
