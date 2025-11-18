import 'package:astral/models/room_info.dart';
import 'package:flutter/material.dart';

/// 创建房间对话框
class CreateRoomDialog extends StatefulWidget {
  const CreateRoomDialog({super.key});

  @override
  State<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends State<CreateRoomDialog> {
  final TextEditingController _roomNameController = TextEditingController();
  bool _canCreate = false;

  @override
  void initState() {
    super.initState();
    // 监听文本变化
    _roomNameController.addListener(_updateCreateButtonState);
  }

  @override
  void dispose() {
    _roomNameController.removeListener(_updateCreateButtonState);
    _roomNameController.dispose();
    super.dispose();
  }

  /// 更新创建按钮状态
  void _updateCreateButtonState() {
    final canCreate = _roomNameController.text.trim().isNotEmpty;
    if (_canCreate != canCreate) {
      setState(() {
        _canCreate = canCreate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('创建房间'),
      content: TextField(
        controller: _roomNameController,
        decoration: const InputDecoration(hintText: '输入房间名称'),
        autofocus: true,
        maxLength: 20,
        onSubmitted: (_) {
          if (_canCreate) {
            _handleCreate(context);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _canCreate ? () => _handleCreate(context) : null,
          child: const Text('创建'),
        ),
      ],
    );
  }

  void _handleCreate(BuildContext context) {
    final roomName = _roomNameController.text.trim();
    if (roomName.isEmpty) return;

    // 创建 RoomInfo 对象
    final room = RoomInfo();
    room.name = roomName;

    Navigator.of(context).pop(room);
  }
}
