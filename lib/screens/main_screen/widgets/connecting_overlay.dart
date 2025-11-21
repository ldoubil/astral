import 'package:astral/state/app_state.dart';
import 'package:astral/state/v2/base.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 连接中覆盖层组件
/// 显示连接动画和状态提示
class ConnectingOverlay extends StatelessWidget {
  const ConnectingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Watch(
      (context) {
        final connectionState = AppState().v2BaseState.roomConnectionState.value;

        // 只在连接中时显示
        if (connectionState != RoomConnectionState.connecting) {
          return const SizedBox.shrink();
        }

        return Container(
          color: theme.colorScheme.surface.withOpacity(0.9),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 旋转动画图标
                _ConnectingSpinner(),
                const SizedBox(height: 24),
                Text(
                  '连接中...',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '正在连接到房间',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 连接中旋转动画组件
class _ConnectingSpinner extends StatefulWidget {
  @override
  State<_ConnectingSpinner> createState() => _ConnectingSpinnerState();
}

class _ConnectingSpinnerState extends State<_ConnectingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: Icon(
            Icons.sync,
            size: 64,
            color: theme.colorScheme.primary,
          ),
        );
      },
    );
  }
}





