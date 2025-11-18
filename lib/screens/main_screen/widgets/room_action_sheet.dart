import 'package:astral/models/room_info.dart';
import 'package:flutter/material.dart';

/// 房间操作类型枚举
enum RoomAction { share, delete }

/// 房间操作底部表单组件
class RoomActionSheet extends StatelessWidget {
  const RoomActionSheet({super.key, required this.room});

  final RoomInfo room;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.share_rounded),
            title: const Text('分享房间'),
            onTap: () => Navigator.of(context).pop(RoomAction.share),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded),
            title: const Text('删除房间'),
            onTap: () => Navigator.of(context).pop(RoomAction.delete),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
