import 'dart:io';

import 'package:astral/core/models/magic_wall_model.dart';
import 'package:astral/core/ui/app_snack_bars.dart';
import 'package:astral/features/magic_wall/dialogs/magic_wall_group_dialog.dart';
import 'package:astral/features/magic_wall/dialogs/magic_wall_rule_dialog.dart';
import 'package:astral/features/magic_wall/services/magic_wall_controller.dart';
import 'package:astral/features/magic_wall/widgets/magic_wall_control_panel.dart';
import 'package:astral/features/magic_wall/widgets/magic_wall_group_list.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class MagicWallPage extends StatefulWidget {
  const MagicWallPage({super.key});

  @override
  State<MagicWallPage> createState() => _MagicWallPageState();
}

class _MagicWallPageState extends State<MagicWallPage> {
  final Set<String> _collapsedGroups = <String>{};
  late final MagicWallController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MagicWallController(
      onSuccess: _showSuccess,
      onError: _showError,
      onValidGroupIdsChanged: _pruneCollapsedGroups,
    );
    _controller.init();
    _controller.loadData().then(
      (_) => _controller.processMonitor.fixIncompleteAppPaths(),
    );
    _controller.checkStatus();
    if (Platform.isWindows) {
      _controller.processMonitor.start();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pruneCollapsedGroups(Set<String> validGroupIds) {
    final toRemove =
        _collapsedGroups.where((id) => !validGroupIds.contains(id)).toList();
    if (toRemove.isNotEmpty && mounted) {
      setState(() {
        _collapsedGroups.removeAll(toRemove);
      });
    }
  }

  void _toggleGroupCollapse(String groupId) {
    if (!mounted) {
      return;
    }
    setState(() {
      if (_collapsedGroups.contains(groupId)) {
        _collapsedGroups.remove(groupId);
      } else {
        _collapsedGroups.add(groupId);
      }
    });
  }

  Future<void> _addRule({String? groupId, bool allowGroupChange = true}) async {
    final groups = _controller.groups.value.map((bundle) => bundle.group).toList();
    if (groups.isEmpty) {
      _showError('请先创建规则组');
      return;
    }

    final targetGroupId = groupId ?? groups.first.groupId;

    final rule = await showDialog<MagicWallRuleModel>(
      context: context,
      builder:
          (context) => MagicWallRuleDialog(
            groups: groups,
            selectedGroupId: targetGroupId,
            allowGroupChange: allowGroupChange,
          ),
    );

    if (rule != null) {
      await _controller.addRule(
        rule,
        targetGroupId: targetGroupId,
        groupsList: groups,
      );
    }
  }

  Future<void> _editRule(MagicWallRuleModel rule) async {
    final groups = _controller.groups.value.map((bundle) => bundle.group).toList();
    if (groups.isEmpty) {
      _showError('请先创建规则组');
      return;
    }

    final updated = await showDialog<MagicWallRuleModel>(
      context: context,
      builder:
          (context) => MagicWallRuleDialog(
            rule: rule,
            groups: groups,
            selectedGroupId: rule.groupId,
          ),
    );

    if (updated != null) {
      await _controller.updateRule(updated, groupsList: groups);
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
      await _controller.deleteRule(rule);
    }
  }

  Future<void> _addGroup() async {
    final group = await showDialog<MagicWallGroupModel>(
      context: context,
      builder: (context) => const MagicWallGroupDialog(),
    );

    if (group != null) {
      await _controller.addGroup(group);
    }
  }

  Future<void> _editGroup(MagicWallGroupModel group) async {
    final updated = await showDialog<MagicWallGroupModel>(
      context: context,
      builder: (context) => MagicWallGroupDialog(group: group),
    );

    if (updated != null) {
      await _controller.updateGroup(updated);
    }
  }

  Future<void> _deleteGroup(MagicWallGroupModel group) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认删除'),
            content: Text('确定要删除规则组 "${group.name}" 吗？'),
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
      await _controller.deleteGroup(group);
    }
  }

  Future<void> _showCreationMenu() async {
    await showModalBottomSheet<void>(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.layers),
                  title: const Text('添加规则组'),
                  onTap: () {
                    Navigator.pop(context);
                    _addGroup();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.playlist_add),
                  title: const Text('添加规则'),
                  enabled: _controller.groups.value.isNotEmpty,
                  onTap:
                      _controller.groups.value.isEmpty
                          ? null
                          : () {
                            Navigator.pop(context);
                            _addRule();
                          },
                ),
              ],
            ),
          ),
    );
  }

  void _showSuccess(String message) {
    AppSnackBars.success(context, '成功', message);
  }

  void _showError(String message) {
    AppSnackBars.error(context, '错误', message);
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
                      _controller.isRunning.value
                          ? Icons.shield
                          : Icons.shield_outlined,
                      color:
                          _controller.isRunning.value
                              ? Colors.green
                              : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_controller.activeRulesCount.value} 条规则',
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
          MagicWallControlPanel(
            isRunning: _controller.isRunning,
            onToggle: _controller.toggleEngine,
          ),
          const Divider(height: 1),
          Expanded(
            child: Watch((context) {
              return MagicWallGroupList(
                groups: _controller.groups.value,
                collapsedGroups: _collapsedGroups,
                onToggleGroupCollapse: _toggleGroupCollapse,
                onToggleGroup: _controller.toggleGroup,
                onEditGroup: _editGroup,
                onDeleteGroup: _deleteGroup,
                onAddRule: _addRule,
                onToggleRule: _controller.toggleRule,
                onEditRule: _editRule,
                onDeleteRule: _deleteRule,
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreationMenu,
        child: const Icon(Icons.add),
      ),
    );
  }
}
