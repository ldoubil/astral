import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:isar_community/isar.dart';
import 'package:astral/core/models/magic_wall_model.dart';
import 'package:astral/core/ui/app_snack_bars.dart';

/// 规则组编辑对话框
class MagicWallGroupDialog extends StatefulWidget {
  final MagicWallGroupModel? group;

  const MagicWallGroupDialog({super.key, this.group});

  @override
  State<MagicWallGroupDialog> createState() => _MagicWallGroupDialogState();
}

class _MagicWallGroupDialogState extends State<MagicWallGroupDialog> {
  late TextEditingController _nameController;
  late TextEditingController _processController;
  late bool _autoManage;
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    final group = widget.group;
    _nameController = TextEditingController(text: group?.name ?? '');
    _processController = TextEditingController(text: group?.processName ?? '');
    _autoManage = group?.autoManage ?? true;
    _enabled = group?.enabled ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _processController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final process = _processController.text.trim();

    if (name.isEmpty) {
      AppSnackBars.error(context, '无法保存', '请输入规则组名称');
      return;
    }

    if (_autoManage && process.isEmpty) {
      AppSnackBars.error(context, '无法保存', '启用自动监听时需填写进程名称');
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final group =
        MagicWallGroupModel()
          ..id = widget.group?.id ?? Isar.autoIncrement
          ..groupId = widget.group?.groupId ?? const Uuid().v4()
          ..name = name
          ..processName = process
          ..autoManage = _autoManage
          ..enabled = _enabled
          ..createdAt = widget.group?.createdAt ?? now
          ..updatedAt = now;

    Navigator.pop(context, group);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.group == null ? '添加规则组' : '编辑规则组'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '规则组名称 *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.layers),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _processController,
                decoration: const InputDecoration(
                  labelText: '绑定进程名称',
                  hintText: '如: game.exe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.memory),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('自动监听进程'),
                subtitle: const Text('进程启动启用规则组, 进程结束关闭规则组'),
                value: _autoManage,
                onChanged: (value) => setState(() => _autoManage = value),
              ),
              SwitchListTile(
                title: const Text('启用规则组'),
                value: _enabled,
                onChanged: (value) => setState(() => _enabled = value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('保存')),
      ],
    );
  }
}
