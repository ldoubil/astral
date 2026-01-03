import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String message) async {
  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('错误提示'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('确定'),
          ),
        ],
      );
    },
  );
}