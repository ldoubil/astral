import 'package:flutter/material.dart';

/// 编辑昵称对话框
class EditNicknameDialog extends StatefulWidget {
  const EditNicknameDialog({super.key, required this.currentNickname});

  final String currentNickname;

  @override
  State<EditNicknameDialog> createState() => _EditNicknameDialogState();
}

class _EditNicknameDialogState extends State<EditNicknameDialog> {
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nicknameController.text = widget.currentNickname;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  /// 处理确认
  void _handleConfirm() {
    final nickname = _nicknameController.text.trim();
    if (nickname.isNotEmpty) {
      Navigator.of(context).pop(nickname);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑昵称'),
      content: TextField(
        controller: _nicknameController,
        decoration: const InputDecoration(hintText: '输入昵称'),
        autofocus: true,
        maxLength: 20,
        onSubmitted: (_) {
          if (_nicknameController.text.trim().isNotEmpty) {
            _handleConfirm();
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed:
              _nicknameController.text.trim().isNotEmpty
                  ? _handleConfirm
                  : null,
          child: const Text('确定'),
        ),
      ],
    );
  }
}
