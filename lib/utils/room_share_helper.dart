import 'package:astral/state/base_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:astral/k/models/room.dart';
import 'package:astral/utils/e_d_room.dart';
import 'package:astral/k/app_s/aps.dart';

/// 房间分享助手类
/// 提供完整的房间分享功能，包括链接生成、分享、导入等
class RoomShareHelper {
  static const String appScheme = 'astral';
  static const String roomPath = 'room';

  /// 生成房间分享链接
  ///
  /// [room] 要分享的房间对象
  /// [includeDeepLink] 是否生成深度链接格式
  /// 返回分享链接字符串
  static String generateShareLink(Room room, {bool includeDeepLink = true}) {
    try {
      // 验证房间数据
      final (isValid, errorMessage) = validateRoom(room);
      if (!isValid) {
        throw Exception('房间数据无效: $errorMessage');
      }

      // 清理房间数据
      final cleanedRoom = cleanRoom(room);

      final shareCode = encryptRoomWithJWT(cleanedRoom);

      if (includeDeepLink) {
        return '$appScheme://$roomPath?code=$shareCode';
      } else {
        return shareCode;
      }
    } catch (e) {
      throw Exception('生成分享链接失败: $e');
    }
  }

  /// 生成分享文本
  ///
  /// [room] 要分享的房间对象
  /// [includeInstructions] 是否包含使用说明
  static String generateShareText(
    Room room, {
    bool includeInstructions = true,
  }) {
    final link = generateShareLink(room);
    final roomSummary = generateRoomSummary(room);

    String shareText = '''
🎮 Astral 房间分享

$roomSummary

🔗 分享链接：$link
''';

    if (includeInstructions) {
      shareText += '''

📖 使用说明：
1. 确保已安装 Astral 应用
2. 点击上方链接自动导入房间
3. 或复制分享码在应用内手动导入

⏰ 分享链接有效期：30天
''';
    }

    return shareText;
  }

  /// 复制房间分享链接到剪贴板
  ///
  /// [context] 上下文，用于显示提示信息
  /// [room] 要分享的房间对象
  /// [linkOnly] 是否只复制链接（不包含说明文字）
  static Future<void> copyShareLink(
    BuildContext context,
    Room room, {
    bool linkOnly = false,
  }) async {
    try {
      final content =
          linkOnly ? generateShareLink(room) : generateShareText(room);

      await Clipboard.setData(ClipboardData(text: content));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '复制成功',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        linkOnly ? '房间链接已复制到剪贴板' : '房间分享信息已复制到剪贴板',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('复制失败: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// 使用系统分享功能分享房间
  ///
  /// [context] 上下文
  /// [room] 要分享的房间对象
  static Future<void> shareRoom(BuildContext context, Room room) async {
    try {
      final shareText = generateShareText(room);

      // 由于没有share_plus包，直接复制到剪贴板并提示用户
      await Clipboard.setData(ClipboardData(text: shareText));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '已复制分享信息',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        '请粘贴到其他应用分享给好友',
                        style: TextStyle(fontSize: 12),
                      ),
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
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分享失败: ${e.toString()}'),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 显示房间分享选项对话框
  ///
  /// [context] 上下文
  /// [room] 要分享的房间对象
  static Future<void> showShareDialog(BuildContext context, Room room) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.share),
              const SizedBox(width: 8),
              Expanded(child: Text('分享房间 - ${room.name}')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('复制分享链接'),
                subtitle: const Text('复制房间链接到剪贴板'),
                onTap: () {
                  Navigator.pop(context);
                  copyShareLink(context, room, linkOnly: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.description),
                title: const Text('复制详细信息'),
                subtitle: const Text('复制包含说明的完整分享信息'),
                onTap: () {
                  Navigator.pop(context);
                  copyShareLink(context, room, linkOnly: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('分享给好友'),
                subtitle: const Text('使用系统分享功能'),
                onTap: () {
                  Navigator.pop(context);
                  shareRoom(context, room);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  /// 从剪贴板导入房间
  ///
  /// [context] 上下文
  /// 返回是否成功导入
  static Future<bool> importFromClipboard(BuildContext context) async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final clipboardText = clipboardData?.text?.trim() ?? '';

      if (clipboardText.isEmpty) {
        _showError(context, '剪贴板为空', '请先复制房间分享码或链接');
        return false;
      }

      return await importRoom(context, clipboardText);
    } catch (e) {
      _showError(context, '读取剪贴板失败', e.toString());
      return false;
    }
  }

  /// 导入房间
  ///
  /// [context] 上下文
  /// [shareText] 分享码或链接
  /// 返回是否成功导入
  static Future<bool> importRoom(BuildContext context, String shareText) async {
    try {
      String shareCode = shareText.trim();

      // 如果是深度链接格式，提取分享码
      if (shareCode.startsWith('$appScheme://')) {
        final uri = Uri.tryParse(shareCode);
        if (uri == null || uri.host != roomPath) {
          _showError(context, '链接格式错误', '不是有效的房间分享链接');
          return false;
        }
        shareCode = uri.queryParameters['code'] ?? '';
      }

      // 清理分享码
      shareCode = shareCode.replaceAll(RegExp(r'\s+'), '');

      if (shareCode.isEmpty) {
        _showError(context, '分享码为空', '请提供有效的房间分享码');
        return false;
      }

      // 验证分享码格式
      if (!isValidShareCode(shareCode)) {
        _showError(context, '分享码格式错误', '分享码格式不正确，请检查是否完整');
        return false;
      }

      // 解密房间信息
      final room = decryptRoomFromJWT(shareCode);
      if (room == null) {
        _showError(context, '分享码无效', '无法解析房间信息，请检查分享码是否正确或已过期');
        return false;
      }

      // 验证房间数据完整性
      final (isValid, errorMessage) = validateRoom(room);
      if (!isValid) {
        _showError(context, '房间数据无效', errorMessage ?? '房间数据不符合要求');
        return false;
      }

      // 清理房间数据
      final cleanedRoom = cleanRoom(room);

      // 检查重复
      final existingRooms = await Aps().getAllRooms();
      final duplicate =
          existingRooms.where((existing) {
            if (cleanedRoom.encrypted && existing.encrypted) {
              return existing.name == cleanedRoom.name &&
                  existing.roomName == cleanedRoom.roomName &&
                  existing.password == cleanedRoom.password;
            } else if (!cleanedRoom.encrypted && !existing.encrypted) {
              return existing.roomName == cleanedRoom.roomName &&
                  existing.password == cleanedRoom.password;
            }
            return false;
          }).firstOrNull;

      if (duplicate != null) {
        _showInfo(context, '房间已存在', '房间"${duplicate.name}"已在您的房间列表中');
        return false;
      }

      // 添加房间
      await Aps().addRoom(cleanedRoom);

      // 安全地跳转到房间页面并选中房间
      await navigateToRoomPage(cleanedRoom, context: context);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '导入成功',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '已成功添加并选中房间"${cleanedRoom.name}"',
                        style: const TextStyle(fontSize: 12),
                      ),
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

      return true;
    } catch (e) {
      _showError(context, '导入失败', e.toString());
      return false;
    }
  }

  /// 显示错误信息
  static void _showError(BuildContext context, String title, String message) {
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
      ),
    );
  }

  /// 显示信息提示
  static void _showInfo(BuildContext context, String title, String message) {
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

  /// 安全地跳转到房间页面并选中房间
  ///
  /// [room] 要选中的房间
  /// [context] 上下文（可选）
  static Future<void> navigateToRoomPage(
    Room room, {
    BuildContext? context,
  }) async {
    try {
      // 使用 Future.microtask 确保在下一个事件循环中执行
      // 这样可以避免在应用初始化过程中出现问题
      await Future.microtask(() async {
        // 跳转到房间页面
        BaseState().selectedIndex.set(1);

        // 延迟一点时间确保页面已经切换
        await Future.delayed(const Duration(milliseconds: 100));

        // 选中房间
        await Aps().setRoom(room);
      });

      debugPrint('已跳转到房间页面并选中房间: ${room.name}');
    } catch (e) {
      debugPrint('跳转到房间页面失败: $e');
      if (context != null) {
        _showError(context, '跳转失败', '无法跳转到房间页面: $e');
      }
    }
  }
}
