import 'dart:io';
import 'package:flutter/material.dart';

/// 小窗口适配器，用于处理安卓小窗口模式问题
class SmallWindowAdapter {
  /// 检查当前环境是否需要应用小窗口适配
  static bool shouldApplyAdapter(BuildContext context) {
    if (!Platform.isAndroid) return false;

    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final Size screenSize = mediaQuery.size;

    // 检测是否为小窗口模式
    return screenSize.width < 300 || screenSize.height < 400;
  }

  /// 应用小窗口适配
  static MediaQueryData adaptMediaQuery(MediaQueryData original) {
    if (!Platform.isAndroid) return original;

    final Size screenSize = original.size;
    final bool isSmallWindow =
        screenSize.width < 300 || screenSize.height < 400;

    if (!isSmallWindow) return original;

    // 处理安卓小窗口模式下的媒体查询调整
    return original.copyWith(
      padding: original.padding.copyWith(
        top: 24.0, // 为小窗口模式使用合理的顶部内边距
        bottom: 16.0, // 为小窗口模式使用合理的底部内边距
      ),
      viewInsets: original.viewInsets.copyWith(
        bottom:
            isSmallWindow && original.viewInsets.bottom > 0
                ?
                // 确保键盘不会占用太多空间
                original.size.height * 0.3
                : original.viewInsets.bottom,
      ),
      devicePixelRatio: 1.0, // 确保像素比例合理
      textScaler: const TextScaler.linear(0.9), // 在小窗口模式下略微缩小文本
    );
  }

  /// 创建安全区域适配包装器
  static Widget createSafeAreaAdapter(Widget child) {
    return Builder(
      builder: (context) {
        final bool isSmallWindow = shouldApplyAdapter(context);

        if (!isSmallWindow) return child;

        // 在小窗口模式下应用自定义安全区域
        return SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: child,
        );
      },
    );
  }
}
