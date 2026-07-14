import 'dart:math';

import 'package:astral/core/states/connection_state.dart';
import 'package:flutter/material.dart';

/// 连接按钮图标（含连接中旋转动画）
Widget connectButtonIcon(CoState state, AnimationController animationController) {
  switch (state) {
    case CoState.idle:
      return Icon(
        Icons.power_settings_new_rounded,
        key: const ValueKey('idle_icon'),
      );
    case CoState.connecting:
      return AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Transform.rotate(
            angle: animationController.value * 2 * pi,
            child: const Icon(
              Icons.close_rounded, // 取消图标
              key: ValueKey('connecting_icon'),
            ),
          );
        },
      );
    case CoState.connected:
      return Icon(Icons.link_rounded, key: const ValueKey('connected_icon'));
  }
}

/// 连接按钮文案
Widget connectButtonLabel(CoState state) {
  final String text;
  switch (state) {
    case CoState.idle:
      text = '连接';
    case CoState.connecting:
      text = '点击取消'; // 提示用户可以取消
    case CoState.connected:
      text = '已连接';
  }

  return Text(
    text,
    key: ValueKey('label_$state'),
    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
  );
}

Color connectButtonColor(CoState state, ColorScheme colorScheme) {
  switch (state) {
    case CoState.idle:
      return colorScheme.primary;
    case CoState.connecting:
      return colorScheme.error; // 使用错误色表示可以取消
    case CoState.connected:
      return colorScheme.tertiary;
  }
}

Color connectButtonForegroundColor(CoState state, ColorScheme colorScheme) {
  switch (state) {
    case CoState.idle:
      return colorScheme.onPrimary;
    case CoState.connecting:
      return colorScheme.onError; // 白色文字
    case CoState.connected:
      return colorScheme.onTertiary;
  }
}
