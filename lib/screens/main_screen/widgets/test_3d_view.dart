import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 3D测试页面
class Test3DView extends StatefulWidget {
  const Test3DView({super.key});

  @override
  State<Test3DView> createState() => _Test3DViewState();
}

class _Test3DViewState extends State<Test3DView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _rotationX = 0.0;
  double _rotationY = 0.0;
  double _scale = 1.0;
  double _baseScale = 1.0;

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

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 3D旋转立方体
            GestureDetector(
              onScaleStart: (details) {
                _baseScale = _scale;
              },
              onScaleUpdate: (details) {
                setState(() {
                  // 使用 focalPointDelta 处理旋转（单指或双指拖拽）
                  _rotationY += details.focalPointDelta.dx * 0.01;
                  _rotationX -= details.focalPointDelta.dy * 0.01;
                  // 使用 scale 处理缩放（双指捏合）
                  _scale = (_baseScale * details.scale).clamp(0.5, 2.0);
                });
              },
              onScaleEnd: (_) {
                // 更新基准缩放值
                _baseScale = _scale;
              },
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(_rotationX)
                      ..rotateY(_rotationY + _controller.value * 2 * math.pi)
                      ..scale(_scale),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                            theme.colorScheme.tertiary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.view_in_ar,
                          size: 80,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            // 控制说明
            Text(
              '拖拽旋转 · 捏合缩放',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            // 重置按钮
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _rotationX = 0.0;
                  _rotationY = 0.0;
                  _scale = 1.0;
                });
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('重置'),
            ),
          ],
        ),
      ),
    );
  }
}

