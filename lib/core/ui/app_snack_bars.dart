import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 统一的标题 + 正文风格 SnackBar
class AppSnackBars {
  const AppSnackBars._();

  static void show(
    BuildContext? context, {
    required String title,
    required String message,
    required Color backgroundColor,
    IconData icon = Icons.info_outline,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    if (context == null || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (message.isNotEmpty)
                    Text(message, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: action,
      ),
    );
  }

  static void error(
    BuildContext? context,
    String title,
    String message, {
    bool copyAction = false,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    show(
      context,
      title: title,
      message: message,
      backgroundColor: Colors.red.shade700,
      icon: Icons.error_outline,
      duration: duration,
      action:
          action ??
          (copyAction
              ? SnackBarAction(
                label: '复制错误',
                textColor: Colors.white,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: '$title: $message'));
                },
              )
              : null),
    );
  }

  static void success(
    BuildContext? context,
    String title,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      title: title,
      message: message,
      backgroundColor: Colors.green.shade700,
      icon: Icons.check_circle_outline,
      duration: duration,
    );
  }

  static void info(
    BuildContext? context,
    String title,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      title: title,
      message: message,
      backgroundColor: Colors.blue.shade700,
      icon: Icons.info_outline,
      duration: duration,
    );
  }
}
