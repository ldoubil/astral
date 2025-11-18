import 'package:flutter/material.dart';

/// 邀请成员对话框
class InviteDialog extends StatelessWidget {
  const InviteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('邀请成员'),
      content: const Text('将邀请链接复制发送给好友即可加入房间。'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text('复制链接'),
        ),
      ],
    );
  }
}
