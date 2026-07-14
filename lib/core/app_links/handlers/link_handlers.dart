import 'package:astral/core/room/room_share_codec.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/ui/app_snack_bars.dart';
import 'package:astral/core/ui/room_navigation.dart';
import 'package:flutter/material.dart';

class LinkHandlers {
  static final _services = ServiceManager();

  // 处理房间分享链接: astral://room?code=JWT_TOKEN
  static Future<void> handleRoom(Uri uri, {BuildContext? context}) async {
    try {
      final code = uri.queryParameters['code'];
      if (code == null || code.isEmpty) {
        AppSnackBars.error(context, '分享链接格式错误', '链接中缺少房间分享码', copyAction: true);
        return;
      }

      // 去除 code 中的所有空格和换行符
      final cleanedCode = code.replaceAll(RegExp(r'\s+'), '');

      // 验证分享码长度
      if (cleanedCode.length < 10) {
        AppSnackBars.error(context, '分享码无效', '分享码格式不正确，请检查链接是否完整', copyAction: true);
        return;
      }

      // 解密获取房间信息
      final room = RoomShareCodec.decryptRoom(cleanedCode);
      if (room == null) {
        AppSnackBars.error(context, '分享码解析失败', '无法解析房间信息，可能是分享码已过期或损坏', copyAction: true);
        return;
      }

      // 验证房间信息完整性
      if (room.name.isEmpty) {
        AppSnackBars.error(context, '房间信息不完整', '房间名称不能为空', copyAction: true);
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
        if (context != null && context.mounted) {
          AppSnackBars.info(
            context,
            '房间已存在',
            '房间"${duplicateRoom.name}"已在您的房间列表中',
          );
        }
        return;
      }
      await _services.room.addRoom(room);

      if (context != null && context.mounted) {
        await RoomNavigation.goToRoom(room, context: context);
        if (context.mounted) {
          AppSnackBars.success(context, '房间添加成功', '已成功添加并选中房间"${room.name}"');
        }
      }
    } catch (e) {
      if (context != null && context.mounted) {
        AppSnackBars.error(context, '处理分享链接失败', '发生未知错误：${e.toString()}', copyAction: true);
      }
    }
  }

  // 处理调试链接: astral://debug
  static Future<void> handleDebug(Uri uri, {BuildContext? context}) async {
    if (context != null) {
      AppSnackBars.info(context, '调试信息', '已触发调试链接: ${uri.host}');
    }
  }
}
