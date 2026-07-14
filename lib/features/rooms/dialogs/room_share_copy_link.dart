import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:astral/core/models/room.dart';
import 'package:astral/core/room/room_share_codec.dart';
import 'package:astral/core/ui/app_snack_bars.dart';

/// 复制房间分享链接到剪贴板
///
/// [linkOnly] 是否只复制链接（不包含说明文字）
Future<void> copyRoomShareLink(
  BuildContext context,
  Room room, {
  bool linkOnly = false,
}) async {
  try {
    final content =
        linkOnly
            ? RoomShareCodec.generateShareLink(room)
            : RoomShareCodec.generateShareText(room);

    await Clipboard.setData(ClipboardData(text: content));

    if (context.mounted) {
      AppSnackBars.success(
        context,
        '复制成功',
        linkOnly ? '房间链接已复制到剪贴板' : '房间分享信息已复制到剪贴板',
      );
    }
  } catch (e) {
    if (context.mounted) {
      AppSnackBars.error(context, '复制失败', e.toString());
    }
  }
}
