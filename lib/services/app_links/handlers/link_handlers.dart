import 'package:astral/core/services/service_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LinkHandlers {
  static final _services = ServiceManager();

  // 房间分享功能已移除（使用固定房间列表）
  static Future<void> handleRoom(Uri uri, {BuildContext? context}) async {
    debugPrint('房间分享功能已禁用（固定房间列表）');
    _showError(context, '功能不可用', '当前版本使用固定房间列表，不支持分享功能');
  }

  // 显示错误信息
  static void _showError(BuildContext? context, String title, String message) {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
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
                    Text(message, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: '复制错误',
            textColor: Colors.white,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: '$title: $message'));
            },
          ),
        ),
      );
    }
  }

  // 显示成功信息
  static void _showSuccess(
    BuildContext? context,
    String title,
    String message,
  ) {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
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
                    Text(message, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // 显示信息提示
  static void _showInfo(BuildContext? context, String title, String message) {
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white),
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
                    Text(message, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blue[700],
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // 处理调试链接: astral://debug
  static Future<void> handleDebug(Uri uri, {BuildContext? context}) async {
    // 打印链接内容
    debugPrint('链接内容: $uri');
    debugPrint('链接类型: ${uri.runtimeType}');

    // 打印链接各个部分
    debugPrint('scheme: ${uri.scheme}');
    debugPrint('host: ${uri.host}');
    debugPrint('path: ${uri.path}');
    debugPrint('query参数: ${uri.queryParameters}');
    debugPrint('fragment: ${uri.fragment}');

    // 如果有上下文，显示调试信息
    if (context != null) {
      _showInfo(context, '调试信息', '链接调试信息已输出到控制台');
    }
  }
}
