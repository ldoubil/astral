import 'package:astral/utils/e_d_room.dart';
import 'package:astral/utils/room_share_helper.dart';
import 'package:astral/k/services/service_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LinkHandlers {
  static final _services = ServiceManager();

  // 处理房间分享链接: astral://room?code=JWT_TOKEN
  static Future<void> handleRoom(Uri uri, {BuildContext? context}) async {
    try {
      final code = uri.queryParameters['code'];
      if (code == null || code.isEmpty) {
        debugPrint('房间分享链接缺少 code 参数');
        _showError(context, '分享链接格式错误', '链接中缺少房间分享码');
        return;
      }

      // 去除 code 中的所有空格和换行符
      final cleanedCode = code.replaceAll(RegExp(r'\s+'), '');

      // 验证分享码长度
      if (cleanedCode.length < 10) {
        debugPrint('房间分享码太短，可能无效');
        _showError(context, '分享码无效', '分享码格式不正确，请检查链接是否完整');
        return;
      }

      // 解密 JWT 获取房间信息
      final room = decryptRoomFromJWT(cleanedCode);
      if (room == null) {
        debugPrint('无效的房间分享码');
        _showError(context, '分享码解析失败', '无法解析房间信息，可能是分享码已过期或损坏');
        return;
      }

      // 验证房间信息完整性
      if (room.name.isEmpty) {
        debugPrint('房间信息不完整：房间名为空');
        _showError(context, '房间信息不完整', '房间名称不能为空');
        return;
      }

      // 检查是否已存在相同的房间
      final existingRooms = await _services.room.getAllRooms();
      final duplicateRoom =
          existingRooms.where((existingRoom) {
            if (room.encrypted && existingRoom.encrypted) {
              // 对于加密房间，比较房间名、房间号和密码
              return existingRoom.name == room.name &&
                  existingRoom.roomName == room.roomName &&
                  existingRoom.password == room.password;
            } else if (!room.encrypted && !existingRoom.encrypted) {
              // 对于非加密房间，比较房间号和密码
              return existingRoom.roomName == room.roomName &&
                  existingRoom.password == room.password;
            }
            return false;
          }).firstOrNull;

      if (duplicateRoom != null) {
        debugPrint('房间已存在: ${duplicateRoom.name}');
        _showInfo(context, '房间已存在', '房间"${duplicateRoom.name}"已在您的房间列表中');
        return;
      } // 添加房间到数据库
      await _services.room.addRoom(room);
      debugPrint('成功添加分享房间: ${room.name}');

      // 安全地跳转到房间页面并选中房间
      await RoomShareHelper.navigateToRoomPage(room, context: context);

      // 显示成功提示
      _showSuccess(context, '房间添加成功', '已成功添加并选中房间"${room.name}"');
    } catch (e) {
      debugPrint('处理房间分享链接失败: $e');
      _showError(context, '处理分享链接失败', '发生未知错误：${e.toString()}');
    }
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
