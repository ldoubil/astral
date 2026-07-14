import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:isar_community/isar.dart';
import 'package:astral/core/models/magic_wall_model.dart';
import 'package:astral/core/ui/app_snack_bars.dart';

/// 规则编辑对话框
class MagicWallRuleDialog extends StatefulWidget {
  final MagicWallRuleModel? rule;
  final List<MagicWallGroupModel> groups;
  final String? selectedGroupId;
  final bool allowGroupChange;

  const MagicWallRuleDialog({
    super.key,
    this.rule,
    required this.groups,
    this.selectedGroupId,
    this.allowGroupChange = true,
  });

  @override
  State<MagicWallRuleDialog> createState() => _MagicWallRuleDialogState();
}

class _MagicWallRuleDialogState extends State<MagicWallRuleDialog> {
  late TextEditingController _nameController;
  late TextEditingController _remoteIpController;
  late TextEditingController _localIpController;
  late TextEditingController _remotePortController;
  late TextEditingController _localPortController;

  late String _action;
  late String _protocol;
  late String _direction;
  late bool _enabled;
  late String _groupId;

  @override
  void initState() {
    super.initState();

    final rule = widget.rule;
    _nameController = TextEditingController(text: rule?.name ?? '');
    _remoteIpController = TextEditingController(text: rule?.remoteIp ?? '');
    _localIpController = TextEditingController(text: rule?.localIp ?? '');
    _remotePortController = TextEditingController(text: rule?.remotePort ?? '');
    _localPortController = TextEditingController(text: rule?.localPort ?? '');

    _action = rule?.action ?? 'block';
    _protocol = rule?.protocol ?? 'both';
    _direction = rule?.direction ?? 'both';
    _enabled = rule?.enabled ?? true;
    _groupId =
        rule?.groupId ??
        widget.selectedGroupId ??
        (widget.groups.isNotEmpty ? widget.groups.first.groupId : '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _remoteIpController.dispose();
    _localIpController.dispose();
    _remotePortController.dispose();
    _localPortController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      AppSnackBars.error(context, '无法保存', '请输入规则名称');
      return;
    }

    if (_groupId.isEmpty) {
      AppSnackBars.error(context, '无法保存', '请选择规则组');
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final existingAppPath = widget.rule?.appPath;

    final rule =
        MagicWallRuleModel()
          ..id = widget.rule?.id ?? Isar.autoIncrement
          ..ruleId = widget.rule?.ruleId ?? const Uuid().v4()
          ..groupId = _groupId
          ..name = _nameController.text.trim()
          ..enabled = _enabled
          ..action = _action
          ..protocol = _protocol
          ..direction = _direction
          ..appPath =
              existingAppPath != null && existingAppPath.isNotEmpty
                  ? existingAppPath
                  : null
          ..remoteIp =
              _remoteIpController.text.trim().isEmpty
                  ? null
                  : _remoteIpController.text.trim()
          ..localIp =
              _localIpController.text.trim().isEmpty
                  ? null
                  : _localIpController.text.trim()
          ..remotePort =
              _remotePortController.text.trim().isEmpty
                  ? null
                  : _remotePortController.text.trim()
          ..localPort =
              _localPortController.text.trim().isEmpty
                  ? null
                  : _localPortController.text.trim()
          ..createdAt = widget.rule?.createdAt ?? now
          ..updatedAt = now
          ..priority = widget.rule?.priority ?? 0;

    Navigator.pop(context, rule);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.rule == null ? '添加规则' : '编辑规则'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.groups.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  initialValue:
                      _groupId.isEmpty ? widget.groups.first.groupId : _groupId,
                  decoration: const InputDecoration(
                    labelText: '所属规则组',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.layers),
                  ),
                  items:
                      widget.groups
                          .map(
                            (group) => DropdownMenuItem(
                              value: group.groupId,
                              child: Text(group.name),
                            ),
                          )
                          .toList(),
                  onChanged:
                      widget.allowGroupChange
                          ? (value) => setState(() => _groupId = value ?? '')
                          : null,
                ),
                const SizedBox(height: 16),
              ],
              // 规则名称
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '规则名称 *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
              ),
              const SizedBox(height: 16),

              // 基本配置：动作、协议、方向
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _action,
                      decoration: const InputDecoration(
                        labelText: '动作',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'allow', child: Text('允许')),
                        DropdownMenuItem(value: 'block', child: Text('阻止')),
                      ],
                      onChanged: (value) => setState(() => _action = value!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _protocol,
                      decoration: const InputDecoration(
                        labelText: '协议',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'tcp', child: Text('TCP')),
                        DropdownMenuItem(value: 'udp', child: Text('UDP')),
                        DropdownMenuItem(value: 'both', child: Text('TCP+UDP')),
                        DropdownMenuItem(value: 'any', child: Text('任意')),
                      ],
                      onChanged: (value) => setState(() => _protocol = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 方向
              DropdownButtonFormField<String>(
                initialValue: _direction,
                decoration: const InputDecoration(
                  labelText: '方向',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.swap_horiz),
                ),
                items: const [
                  DropdownMenuItem(value: 'inbound', child: Text('⬇️ 入站')),
                  DropdownMenuItem(value: 'outbound', child: Text('⬆️ 出站')),
                  DropdownMenuItem(value: 'both', child: Text('↕️ 双向')),
                ],
                onChanged: (value) => setState(() => _direction = value!),
              ),
              const SizedBox(height: 16),

              // 远程配置
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _remoteIpController,
                      decoration: const InputDecoration(
                        labelText: '远程 IP（可选）',
                        hintText: '192.168.1.1 或 192.168.0.0/16',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _remotePortController,
                      decoration: const InputDecoration(
                        labelText: '远程端口（可选）',
                        hintText: '80 或 8000-9000',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 本地配置
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _localIpController,
                      decoration: const InputDecoration(
                        labelText: '本地 IP（可选）',
                        hintText: '192.168.1.1 或 192.168.0.0/16',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _localPortController,
                      decoration: const InputDecoration(
                        labelText: '本地端口（可选）',
                        hintText: '80 或 8000-9000',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text('启用规则'),
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
