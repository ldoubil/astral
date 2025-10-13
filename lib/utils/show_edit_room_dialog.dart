import 'package:astral/k/app_s/aps.dart1';
import 'package:astral/k/models/room.dart';
import 'package:flutter/material.dart';

Future<void> showEditRoomDialog(
  BuildContext context, {
  required Room room,
}) async {
  String? name = room.name;

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('编辑房间'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: name),
              decoration: const InputDecoration(labelText: '房间名称'),
              onChanged: (value) => room.name = value,
            ),
            const SizedBox(height: 8),
            // 显示房间类型（只读）
            ListTile(
              title: const Text('房间类型'),
              subtitle: Text(room.encrypted ? '加密房间' : '普通房间'),
            ),
            if (!room.encrypted) ...[
              TextField(
                controller: TextEditingController(text: room.roomName),
                decoration: const InputDecoration(labelText: '房间号'),
                onChanged: (value) => room.roomName = value,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: room.password),
                decoration: const InputDecoration(labelText: '房间密码'),
                onChanged: (value) => room.password = value,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Aps().updateRoom(room);
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
        ],
      );
    },
  );
}