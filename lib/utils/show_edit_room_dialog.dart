import 'package:astral/k/services/service_manager.dart';
import 'package:astral/k/models/room.dart';
import 'package:flutter/material.dart';

Future<void> showEditRoomDialog(
  BuildContext context, {
  required Room room,
}) async {
  // 检查是否有自定义参数，如果有则禁止编辑
  if (room.customParam.isNotEmpty) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('无法编辑房间'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              const Text(
                '此房间包含自定义服务器配置',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '含有自定义参数的房间不可编辑，只能删除。如需修改，请删除此房间并重新创建或导入。',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('我知道了'),
            ),
          ],
        );
      },
    );
    return;
  }

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
              ServiceManager().room.updateRoom(room);
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
        ],
      );
    },
  );
}
