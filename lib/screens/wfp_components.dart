import 'package:flutter/material.dart';
import 'package:astral/k/models/wfp_model.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:isar_community/isar.dart';
import 'package:astral/k/app_s/aps.dart';

// 中文选项常量
const Map<String, String> directionOptions = {
  'inbound': '入站',
  'outbound': '出站',
  'both': '双向',
};

const Map<String, String> actionOptions = {'allow': '允许', 'block': '阻止'};

const Map<String, String> protocolOptions = {'tcp': 'TCP', 'udp': 'UDP'};

// 常量定义
class _Constants {
  static const double cardPadding = 16.0;
  static const double spacing = 8.0;
  static const double borderRadius = 12.0;
  static const double maxDialogWidth = 900.0;
  static const double maxDialogHeight = 700.0;
}

// 卡片内字段展示
class InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const InfoChip({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value', style: TextStyle(color: color)),
      backgroundColor: color?.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_Constants.spacing),
      ),
    );
  }
}

class FieldRow extends StatelessWidget {
  final String label;
  final String value;
  const FieldRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class WfpRulesTable extends StatelessWidget {
  final List<WfpModel> rules;
  final bool isWfpRunning;
  final Function(BuildContext, WfpModel?) onEditRule;
  final Function(BuildContext, WfpModel) onDeleteRule;
  final Function(WfpModel) onToggleRule;

  const WfpRulesTable({
    super.key,
    required this.rules,
    required this.isWfpRunning,
    required this.onEditRule,
    required this.onDeleteRule,
    required this.onToggleRule,
  });

  String getRuleDisplay(String? rule) => rule?.isEmpty ?? true ? '-' : rule!;

  String getAppPathDisplay(String? appPath) =>
      appPath?.isEmpty ?? true
          ? '所有程序'
          : appPath!.split(Platform.pathSeparator).last;

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) return const Center(child: Text('暂无规则'));

    return ListView.builder(
      itemCount: rules.length,
      itemBuilder:
          (context, index) => _RuleCard(
            rule: rules[index],
            isWfpRunning: isWfpRunning,
            onEditRule: onEditRule,
            onDeleteRule: onDeleteRule,
            onToggleRule: onToggleRule,
            getRuleDisplay: getRuleDisplay,
            getAppPathDisplay: getAppPathDisplay,
          ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  final WfpModel rule;
  final bool isWfpRunning;
  final Function(BuildContext, WfpModel?) onEditRule;
  final Function(BuildContext, WfpModel) onDeleteRule;
  final Function(WfpModel) onToggleRule;
  final String Function(String?) getRuleDisplay;
  final String Function(String?) getAppPathDisplay;

  const _RuleCard({
    required this.rule,
    required this.isWfpRunning,
    required this.onEditRule,
    required this.onDeleteRule,
    required this.onToggleRule,
    required this.getRuleDisplay,
    required this.getAppPathDisplay,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: _Constants.spacing,
        horizontal: 4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_Constants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_Constants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: _Constants.spacing),
            _buildInfoChips(),
            const SizedBox(height: _Constants.spacing),
            _buildRuleFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Switch(
          value: rule.enabled ?? false,
          onChanged: isWfpRunning ? null : (value) => onToggleRule(rule),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(width: _Constants.spacing),
        Expanded(
          child: Text(
            rule.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: rule.enabled == true ? null : Colors.grey,
            ),
          ),
        ),
        _buildPopupMenu(context),
      ],
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      enabled: !isWfpRunning,
      tooltip: isWfpRunning ? 'WFP运行时无法操作' : '更多操作',
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEditRule(context, rule);
          case 'delete':
            onDeleteRule(context, rule);
          case 'toggle':
            onToggleRule(rule);
        }
      },
      itemBuilder:
          (context) => [
            _buildMenuItem(
              'toggle',
              rule.enabled == true ? Icons.toggle_off : Icons.toggle_on,
              rule.enabled == true ? '禁用规则' : '启用规则',
              rule.enabled == true ? Colors.orange : Colors.green,
            ),
            _buildMenuItem('edit', Icons.edit, '编辑规则', null),
            _buildMenuItem('delete', Icons.delete, '删除规则', Colors.red),
          ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon,
    String text,
    Color? color,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: _Constants.spacing),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget _buildInfoChips() {
    return Wrap(
      spacing: 16,
      runSpacing: _Constants.spacing,
      children: [
        InfoChip(label: '应用程序', value: getAppPathDisplay(rule.appPath)),
        InfoChip(
          label: '协议',
          value:
              rule.protocol?.isNotEmpty == true
                  ? protocolOptions[rule.protocol!.toLowerCase()] ??
                      rule.protocol!
                  : '不限制',
        ),
        InfoChip(
          label: '方向',
          value: directionOptions[rule.direction] ?? rule.direction,
        ),
        InfoChip(
          label: '动作',
          value: actionOptions[rule.action] ?? rule.action,
          color: rule.action == 'allow' ? Colors.green : Colors.red,
        ),
        InfoChip(label: '优先级', value: rule.priority?.toString() ?? '-'),
      ],
    );
  }

  Widget _buildRuleFields() {
    return Row(
      children: [
        Expanded(
          child: FieldRow(label: '本地规则', value: getRuleDisplay(rule.localRule)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FieldRow(
            label: '远程规则',
            value: getRuleDisplay(rule.remoteRule),
          ),
        ),
      ],
    );
  }
}

Future<void> showEditDialog(BuildContext context, WfpModel? rule) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => _EditRuleDialog(rule: rule),
  );
}

class _EditRuleDialog extends StatefulWidget {
  final WfpModel? rule;
  const _EditRuleDialog({this.rule});

  @override
  State<_EditRuleDialog> createState() => _EditRuleDialogState();
}

class _EditRuleDialogState extends State<_EditRuleDialog> {
  late final bool isEdit;
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController nameController;
  late final TextEditingController appPathController;
  late final TextEditingController localRuleController;
  late final TextEditingController remoteRuleController;
  late final TextEditingController priorityController;
  late String selectedProtocol;
  late String selectedDirection;
  late String selectedAction;
  late bool isEnabled;

  @override
  void initState() {
    super.initState();
    isEdit = widget.rule != null;
    _formKey = GlobalKey<FormState>();
    nameController = TextEditingController(text: widget.rule?.name ?? '');
    appPathController = TextEditingController(text: widget.rule?.appPath ?? '');
    localRuleController = TextEditingController(
      text: widget.rule?.localRule ?? '',
    );
    remoteRuleController = TextEditingController(
      text: widget.rule?.remoteRule ?? '',
    );
    priorityController = TextEditingController(
      text: widget.rule?.priority?.toString() ?? '1000',
    );
    selectedProtocol = widget.rule?.protocol ?? 'tcp';
    selectedDirection = widget.rule?.direction ?? 'both';
    selectedAction = widget.rule?.action ?? 'block';
    isEnabled = widget.rule?.enabled ?? true;
  }

  @override
  void dispose() {
    nameController.dispose();
    appPathController.dispose();
    localRuleController.dispose();
    remoteRuleController.dispose();
    priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: _Constants.maxDialogWidth,
          maxHeight: _Constants.maxDialogHeight,
        ),
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: _buildHeader(colorScheme),
          ),
          body: _buildForm(),
          bottomNavigationBar: _buildFooter(),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return AppBar(
      title: Text(isEdit ? '编辑规则' : '添加新规则'),
      leading: Icon(isEdit ? Icons.edit : Icons.add),
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             _buildBasicSettings(),
             const SizedBox(height: 24),
             _buildRuleConfig(),
             const SizedBox(height: 24),
             _buildNetworkSettings(),

           ],
         ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBasicSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('基本设置'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '规则名称 *',
                  hintText: '为此规则起一个描述性的名称',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (v) => v?.isEmpty == true ? '请输入规则名称' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: appPathController,
                      decoration: const InputDecoration(
                        labelText: '应用程序路径',
                        hintText: '留空则应用于所有程序',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.apps),
                      ),
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.folder_open),
                    onPressed: _selectApp,
                    tooltip: '选择应用程序',
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => appPathController.clear()),
                    tooltip: '清除路径',
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }



  Widget _buildNetworkSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('网络规则设置'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: localRuleController,
                maxLines: 3,
                minLines: 3,
                decoration: const InputDecoration(
                  labelText: '本地规则',
                  hintText: '支持多行规则，每行一个：\n192.168.1.1:80\n:8080\n192.168.1.0/24',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.computer),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: remoteRuleController,
                maxLines: 3,
                minLines: 3,
                decoration: const InputDecoration(
                  labelText: '远程规则',
                  hintText: '支持多行规则，每行一个：\n8.8.8.8:53\ngoogle.com:443\n0.0.0.0/0:80',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.public),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRuleConfig() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedProtocol,
                decoration: const InputDecoration(
                  labelText: '协议',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.settings_ethernet),
                ),
                items:
                    protocolOptions.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => selectedProtocol = value!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedDirection,
                decoration: const InputDecoration(
                  labelText: '方向',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.swap_horiz),
                ),
                items:
                    directionOptions.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                onChanged:
                    (value) => setState(() => selectedDirection = value!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedAction,
                decoration: InputDecoration(
                  labelText: '动作',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(
                    selectedAction == 'allow'
                        ? Icons.check_circle
                        : Icons.block,
                  ),
                ),
                items:
                    actionOptions.entries.map((entry) {
                      return DropdownMenuItem<String>(
                        value: entry.key,
                        child: Row(
                          children: [
                            Icon(
                              entry.key == 'allow'
                                  ? Icons.check_circle
                                  : Icons.block,
                              size: 16,
                            ),
                            const SizedBox(width: _Constants.spacing),
                            Text(entry.value),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => selectedAction = value!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: priorityController,
                decoration: const InputDecoration(
                  labelText: '优先级',
                  hintText: '1-65535',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.priority_high),
                ),
                keyboardType: TextInputType.number,
                validator: _validatePriority,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String? _validatePriority(String? v) {
    if (v?.isEmpty == true) return '请输入优先级';
    final priority = int.tryParse(v!);
    if (priority == null) return '请输入有效的数字';
    if (priority < 1 || priority > 65535) return '范围: 1-65535';
    return null;
  }

  Future<void> _selectApp() async {
    final result = await showAppSelectorDialog(context);
    if (result != null) {
      setState(() => appPathController.text = result);
    }
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (isEdit)
            TextButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text('删除规则'),
              onPressed: () {
                Navigator.of(context).pop();
                showDeleteConfirmDialog(context, widget.rule!);
              },
            ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            icon: Icon(isEdit ? Icons.save : Icons.add),
            label: Text(isEdit ? '保存更改' : '添加规则'),
            onPressed: _saveRule,
          ),
        ],
      ),
    );
  }

  Future<void> _saveRule() async {
    if (!_formKey.currentState!.validate()) return;

    final newRule =
        WfpModel()
          ..id = widget.rule?.id ?? Isar.autoIncrement
          ..name = nameController.text
          ..appPath =
              appPathController.text.isEmpty ? null : appPathController.text
          ..localRule =
              localRuleController.text.isEmpty ? null : localRuleController.text
          ..remoteRule =
              remoteRuleController.text.isEmpty
                  ? null
                  : remoteRuleController.text
          ..protocol = selectedProtocol
          ..direction = selectedDirection
          ..action = selectedAction
          ..priority = int.parse(priorityController.text)
          ..enabled = isEnabled;

    try {
      if (isEdit) {
        await Aps().updateWfpModel(newRule);
      } else {
        await Aps().addWfpModel(newRule);
      }
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? '规则已更新' : '规则已添加'),
            action: SnackBarAction(
              label: '查看',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

}

// 顶级函数
Future<void> showDeleteConfirmDialog(
  BuildContext context,
  WfpModel rule,
) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning),
          SizedBox(width: _Constants.spacing),
          Text('确认删除'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('确定要删除规则 "${rule.name}" 吗？'),
          const SizedBox(height: _Constants.spacing),
          const Text('此操作不可撤销。', style: TextStyle(color: Colors.grey)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () => _deleteRule(context, rule),
          child: const Text('删除'),
        ),
      ],
    ),
  );
}

Future<void> _deleteRule(BuildContext context, WfpModel rule) async {
  try {
    await Aps().deleteWfpModel(rule.id!);
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('规则已删除')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: $e')),
      );
    }
  }
}

Future<String?> showAppSelectorDialog(BuildContext context) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['exe'],
      dialogTitle: '选择应用程序',
    );
    return result?.files.single.path;
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择文件失败: $e')),
      );
    }
    return null;
  }
}
