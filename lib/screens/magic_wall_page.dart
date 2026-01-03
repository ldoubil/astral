import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:astral/k/models/magic_wall_model.dart';
import 'package:astral/k/database/app_data.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:astral/src/rust/api/magic_wall.dart' as rust_api;

/// 魔法墙主页面
class MagicWallPage extends StatefulWidget {
  const MagicWallPage({super.key});

  @override
  State<MagicWallPage> createState() => _MagicWallPageState();
}

class _MagicWallPageState extends State<MagicWallPage> {
  final _isRunning = signal(false);
  final _rules = signal<List<MagicWallRuleModel>>([]);
  final _activeRulesCount = signal(0);

  @override
  void initState() {
    super.initState();
    _loadRules();
    _checkStatus();
  }

  Future<void> _loadRules() async {
    try {
      final rules =
          await AppDatabase().MagicWallSetting.getAllMagicWallRulesSorted();
      _rules.value = rules;
      _updateActiveCount();
    } catch (e) {
      _showError('加载规则失败: $e');
    }
  }

  Future<void> _checkStatus() async {
    try {
      final status = await rust_api.getMagicWallStatus();
      _isRunning.value = status.isRunning;
      _activeRulesCount.value = status.activeRules.toInt();
    } catch (e) {
      debugPrint('检查状态失败: $e');
    }
  }

  void _updateActiveCount() {
    _activeRulesCount.value = _rules.value.where((r) => r.enabled).length;
  }

  rust_api.MagicWallRule _convertToRustRule(MagicWallRuleModel model) {
    return rust_api.MagicWallRule(
      id: model.ruleId,
      name: model.name,
      enabled: model.enabled,
      action: model.action,
      protocol: model.protocol,
      direction: model.direction,
      appPath: model.appPath,
      remoteIp: model.remoteIp,
      localIp: model.localIp,
      remotePort: model.remotePort,
      localPort: model.localPort,
      description: model.description,
      createdAt: model.createdAt,
    );
  }

  Future<void> _toggleEngine() async {
    try {
      if (_isRunning.value) {
        await rust_api.stopMagicWall();
        _isRunning.value = false;
        _showSuccess('魔法墙已停止');
      } else {
        await rust_api.startMagicWall();
        // 应用所有启用的规则
        for (var rule in _rules.value.where((r) => r.enabled)) {
          await rust_api.addMagicWallRule(rule: _convertToRustRule(rule));
        }
        _isRunning.value = true;
        _showSuccess('魔法墙已启动');
      }
    } catch (e) {
      _showError('操作失败: $e');
    }
  }

  Future<void> _addRule() async {
    final rule = await showDialog<MagicWallRuleModel>(
      context: context,
      builder: (context) => const MagicWallRuleDialog(),
    );

    if (rule != null) {
      try {
        await AppDatabase().MagicWallSetting.addMagicWallRule(rule);
        await _loadRules();

        // 如果引擎正在运行且规则启用,同步到 Rust
        if (_isRunning.value && rule.enabled) {
          await rust_api.addMagicWallRule(rule: _convertToRustRule(rule));
        }

        _showSuccess('规则已添加');
      } catch (e) {
        _showError('添加规则失败: $e');
      }
    }
  }

  Future<void> _editRule(MagicWallRuleModel rule) async {
    final updated = await showDialog<MagicWallRuleModel>(
      context: context,
      builder: (context) => MagicWallRuleDialog(rule: rule),
    );

    if (updated != null) {
      try {
        await AppDatabase().MagicWallSetting.updateMagicWallRule(updated);
        await _loadRules();

        // 如果引擎正在运行,更新 Rust 中的规则
        if (_isRunning.value) {
          if (updated.enabled) {
            await rust_api.updateMagicWallRule(
              rule: _convertToRustRule(updated),
            );
          } else {
            // 如果被禁用了,删除规则
            await rust_api.removeMagicWallRule(ruleId: updated.ruleId);
          }
        }

        _showSuccess('规则已更新');
      } catch (e) {
        _showError('更新规则失败: $e');
      }
    }
  }

  Future<void> _deleteRule(MagicWallRuleModel rule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认删除'),
            content: Text('确定要删除规则 "${rule.name}" 吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('删除'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        // 如果引擎正在运行且规则启用,从 Rust 中删除
        if (_isRunning.value && rule.enabled) {
          await rust_api.removeMagicWallRule(ruleId: rule.ruleId);
        }

        await AppDatabase().MagicWallSetting.deleteMagicWallRule(rule.id);
        await _loadRules();
        _showSuccess('规则已删除');
      } catch (e) {
        _showError('删除规则失败: $e');
      }
    }
  }

  Future<void> _toggleRule(MagicWallRuleModel rule) async {
    try {
      await AppDatabase().MagicWallSetting.toggleMagicWallRule(rule.id);
      await _loadRules();

      // 如果引擎正在运行,应用/移除规则
      if (_isRunning.value) {
        final updatedRule = _rules.value.firstWhere((r) => r.id == rule.id);
        if (updatedRule.enabled) {
          await rust_api.addMagicWallRule(
            rule: _convertToRustRule(updatedRule),
          );
        } else {
          await rust_api.removeMagicWallRule(ruleId: updatedRule.ruleId);
        }
      }
    } catch (e) {
      _showError('切换规则状态失败: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('魔法墙'),
        actions: [
          // 状态指示器
          Watch(
            (context) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isRunning.value ? Icons.shield : Icons.shield_outlined,
                      color: _isRunning.value ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_activeRulesCount.value} 条规则',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 控制面板
          _buildControlPanel(),

          const Divider(height: 1),

          // 规则列表
          Expanded(
            child: Watch((context) {
              if (_rules.value.isEmpty) {
                return _buildEmptyState();
              }
              return _buildRulesList();
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRule,
        icon: const Icon(Icons.add),
        label: const Text('添加规则'),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Watch(
      (context) => Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '魔法墙引擎',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isRunning.value ? '运行中' : '已停止',
                          style: TextStyle(
                            color:
                                _isRunning.value ? Colors.green : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isRunning.value,
                    onChanged: (value) => _toggleEngine(),
                  ),
                ],
              ),
              if (!Platform.isWindows) ...[
                const SizedBox(height: 8),
                const Text(
                  '⚠️ 魔法墙仅支持 Windows 平台',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '还没有规则',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮添加第一条规则',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _rules.value.length,
      itemBuilder: (context, index) {
        final rule = _rules.value[index];
        return _buildRuleCard(rule);
      },
    );
  }

  Widget _buildRuleCard(MagicWallRuleModel rule) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              rule.enabled
                  ? (rule.action == 'allow' ? Colors.green : Colors.red)
                  : Colors.grey,
          child: Icon(
            rule.action == 'allow' ? Icons.check : Icons.block,
            color: Colors.white,
          ),
        ),
        title: Text(
          rule.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: rule.enabled ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(_buildRuleDescription(rule)),
            if (rule.description != null && rule.description!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                rule.description!,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: rule.enabled,
              onChanged: (value) => _toggleRule(rule),
            ),
            PopupMenuButton(
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('编辑'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('删除', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
              onSelected: (value) {
                if (value == 'edit') {
                  _editRule(rule);
                } else if (value == 'delete') {
                  _deleteRule(rule);
                }
              },
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  String _buildRuleDescription(MagicWallRuleModel rule) {
    final parts = <String>[];

    parts.add('${rule.action == 'allow' ? '允许' : '阻止'}');
    parts.add(rule.protocol.toUpperCase());

    if (rule.direction != 'both') {
      parts.add(rule.direction == 'inbound' ? '入站' : '出站');
    }

    if (rule.remoteIp != null) {
      parts.add('从 ${rule.remoteIp}');
    }

    if (rule.remotePort != null) {
      parts.add('端口 ${rule.remotePort}');
    }

    return parts.join(' · ');
  }
}

/// 规则编辑对话框
class MagicWallRuleDialog extends StatefulWidget {
  final MagicWallRuleModel? rule;

  const MagicWallRuleDialog({super.key, this.rule});

  @override
  State<MagicWallRuleDialog> createState() => _MagicWallRuleDialogState();
}

class _MagicWallRuleDialogState extends State<MagicWallRuleDialog> {
  late TextEditingController _nameController;
  late TextEditingController _appPathController;
  late TextEditingController _remoteIpController;
  late TextEditingController _localIpController;
  late TextEditingController _remotePortController;
  late TextEditingController _localPortController;

  late String _action;
  late String _protocol;
  late String _direction;
  late bool _enabled;

  @override
  void initState() {
    super.initState();

    final rule = widget.rule;
    _nameController = TextEditingController(text: rule?.name ?? '');
    _appPathController = TextEditingController(text: rule?.appPath ?? '');
    _remoteIpController = TextEditingController(text: rule?.remoteIp ?? '');
    _localIpController = TextEditingController(text: rule?.localIp ?? '');
    _remotePortController = TextEditingController(text: rule?.remotePort ?? '');
    _localPortController = TextEditingController(text: rule?.localPort ?? '');

    _action = rule?.action ?? 'block';
    _protocol = rule?.protocol ?? 'both';
    _direction = rule?.direction ?? 'both';
    _enabled = rule?.enabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _appPathController.dispose();
    _remoteIpController.dispose();
    _localIpController.dispose();
    _remotePortController.dispose();
    _localPortController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入规则名称')));
      return;
    }

    if (_appPathController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入应用程序路径')));
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final rule =
        MagicWallRuleModel()
          ..id = widget.rule?.id ?? 0
          ..ruleId = widget.rule?.ruleId ?? const Uuid().v4()
          ..name = _nameController.text.trim()
          ..enabled = _enabled
          ..action = _action
          ..protocol = _protocol
          ..direction = _direction
          ..appPath = _appPathController.text.trim()
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
                      value: _action,
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
                      value: _protocol,
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
                value: _direction,
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

              // 应用程序
              TextField(
                controller: _appPathController,
                decoration: const InputDecoration(
                  labelText: '应用程序路径 *',
                  hintText: '如: C:\\Program Files\\app.exe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.apps),
                ),
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
