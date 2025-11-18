import 'package:flutter/material.dart';

/// 延迟徽章组件
/// 根据延迟值显示不同颜色的徽章
class LatencyBadge extends StatelessWidget {
  const LatencyBadge({super.key, required this.latency});

  final int latency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getLatencyColor(latency);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${latency}ms',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 根据延迟值获取对应的颜色
  Color _getLatencyColor(int latency) {
    if (latency <= 40) {
      return Colors.green;
    } else if (latency <= 80) {
      return Colors.orange;
    } else {
      return Colors.redAccent;
    }
  }
}
