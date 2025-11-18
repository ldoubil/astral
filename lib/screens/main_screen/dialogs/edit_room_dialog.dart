import 'package:astral/models/room_info.dart';
import 'package:flutter/material.dart';

/// 编辑房间对话框
class EditRoomDialog extends StatefulWidget {
  const EditRoomDialog({super.key, required this.currentRoom});

  final RoomInfo currentRoom;

  @override
  State<EditRoomDialog> createState() => _EditRoomDialogState();
}

class _EditRoomDialogState extends State<EditRoomDialog> {
  final TextEditingController _roomNameController = TextEditingController();
  bool _canSave = false;

  @override
  void initState() {
    super.initState();
    _roomNameController.text = widget.currentRoom.name;
    _canSave = widget.currentRoom.name.isNotEmpty;
    // 监听文本变化
    _roomNameController.addListener(_updateSaveButtonState);
  }

  @override
  void dispose() {
    _roomNameController.removeListener(_updateSaveButtonState);
    _roomNameController.dispose();
    super.dispose();
  }

  /// 更新保存按钮状态
  void _updateSaveButtonState() {
    final canSave = _roomNameController.text.trim().isNotEmpty;
    if (_canSave != canSave) {
      setState(() {
        _canSave = canSave;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑房间'),
      content: TextField(
        controller: _roomNameController,
        decoration: const InputDecoration(hintText: '输入房间名称'),
        autofocus: true,
        maxLength: 20,
        onSubmitted: (_) {
          if (_canSave) {
            _handleSave(context);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _canSave ? () => _handleSave(context) : null,
          child: const Text('保存'),
        ),
      ],
    );
  }

  void _handleSave(BuildContext context) {
    final roomName = _roomNameController.text.trim();
    if (roomName.isEmpty) return;

    // 创建更新后的房间对象
    final updatedRoom = RoomInfo();
    updatedRoom.uuid = widget.currentRoom.uuid;
    updatedRoom.name = roomName;
    updatedRoom.servers = widget.currentRoom.servers;

    Navigator.of(context).pop(updatedRoom);
  }
}
