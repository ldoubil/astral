import 'package:astral/core/models/magic_wall_model.dart';
import 'package:astral/features/magic_wall/models/magic_wall_group_bundle.dart';
import 'package:flutter/material.dart';

/// Group / rules list UI for Magic Wall.
class MagicWallGroupList extends StatelessWidget {
  const MagicWallGroupList({
    super.key,
    required this.groups,
    required this.collapsedGroups,
    required this.onToggleGroupCollapse,
    required this.onToggleGroup,
    required this.onEditGroup,
    required this.onDeleteGroup,
    required this.onAddRule,
    required this.onToggleRule,
    required this.onEditRule,
    required this.onDeleteRule,
  });

  final List<MagicWallGroupBundle> groups;
  final Set<String> collapsedGroups;
  final void Function(String groupId) onToggleGroupCollapse;
  final void Function(MagicWallGroupModel group) onToggleGroup;
  final void Function(MagicWallGroupModel group) onEditGroup;
  final void Function(MagicWallGroupModel group) onDeleteGroup;
  final void Function({String? groupId, bool allowGroupChange}) onAddRule;
  final void Function(MagicWallRuleModel rule) onToggleRule;
  final void Function(MagicWallRuleModel rule) onEditRule;
  final void Function(MagicWallRuleModel rule) onDeleteRule;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return const MagicWallEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final bundle = groups[index];
        return _MagicWallGroupCard(
          bundle: bundle,
          isCollapsed: collapsedGroups.contains(bundle.group.groupId),
          onToggleCollapse: () => onToggleGroupCollapse(bundle.group.groupId),
          onToggleGroup: () => onToggleGroup(bundle.group),
          onEditGroup: () => onEditGroup(bundle.group),
          onDeleteGroup: () => onDeleteGroup(bundle.group),
          onAddRule:
              () => onAddRule(
                groupId: bundle.group.groupId,
                allowGroupChange: false,
              ),
          onToggleRule: onToggleRule,
          onEditRule: onEditRule,
          onDeleteRule: onDeleteRule,
        );
      },
    );
  }
}

class MagicWallEmptyState extends StatelessWidget {
  const MagicWallEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '还没有规则组',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮创建规则组',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _MagicWallGroupCard extends StatelessWidget {
  const _MagicWallGroupCard({
    required this.bundle,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.onToggleGroup,
    required this.onEditGroup,
    required this.onDeleteGroup,
    required this.onAddRule,
    required this.onToggleRule,
    required this.onEditRule,
    required this.onDeleteRule,
  });

  final MagicWallGroupBundle bundle;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final VoidCallback onToggleGroup;
  final VoidCallback onEditGroup;
  final VoidCallback onDeleteGroup;
  final VoidCallback onAddRule;
  final void Function(MagicWallRuleModel rule) onToggleRule;
  final void Function(MagicWallRuleModel rule) onEditRule;
  final void Function(MagicWallRuleModel rule) onDeleteRule;

  @override
  Widget build(BuildContext context) {
    final group = bundle.group;
    final rules = bundle.rules;
    final enabledCount = rules.where((rule) => rule.enabled).length;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            onTap: onToggleCollapse,
            leading: CircleAvatar(
              backgroundColor: group.enabled ? Colors.blue : Colors.grey,
              child: Icon(
                group.enabled ? Icons.layers : Icons.layers_outlined,
                color: Colors.white,
              ),
            ),
            title: Text(
              group.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: group.enabled ? null : Colors.grey,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '进程: ${group.processName.isEmpty ? '未绑定' : group.processName}',
                ),
                Text(
                  '规则: ${rules.length} 项 · 已启用 $enabledCount 项',
                  style: const TextStyle(fontSize: 12),
                ),
                if (group.autoManage)
                  const Text(
                    '自动监听进程',
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    isCollapsed ? Icons.expand_more : Icons.expand_less,
                  ),
                  onPressed: onToggleCollapse,
                ),
                Switch(
                  value: group.enabled,
                  onChanged: (value) => onToggleGroup(),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'addRule') {
                      onAddRule();
                    } else if (value == 'edit') {
                      onEditGroup();
                    } else if (value == 'delete') {
                      onDeleteGroup();
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'addRule',
                          child: Row(
                            children: [
                              Icon(Icons.add, size: 20),
                              SizedBox(width: 8),
                              Text('添加规则'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('编辑规则组'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                '删除规则组',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),
          if (!isCollapsed && rules.isNotEmpty) const Divider(height: 1),
          if (!isCollapsed)
            for (var i = 0; i < rules.length; i++) ...[
              _MagicWallRuleTile(
                group: group,
                rule: rules[i],
                onToggleRule: () => onToggleRule(rules[i]),
                onEditRule: () => onEditRule(rules[i]),
                onDeleteRule: () => onDeleteRule(rules[i]),
              ),
              if (i != rules.length - 1)
                const Divider(indent: 72, endIndent: 16, height: 1),
            ],
          if (!isCollapsed)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(72, 8, 16, 12),
                child: TextButton.icon(
                  onPressed: onAddRule,
                  icon: const Icon(Icons.add),
                  label: const Text('添加规则'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MagicWallRuleTile extends StatelessWidget {
  const _MagicWallRuleTile({
    required this.group,
    required this.rule,
    required this.onToggleRule,
    required this.onEditRule,
    required this.onDeleteRule,
  });

  final MagicWallGroupModel group;
  final MagicWallRuleModel rule;
  final VoidCallback onToggleRule;
  final VoidCallback onEditRule;
  final VoidCallback onDeleteRule;

  @override
  Widget build(BuildContext context) {
    final activeColor =
        rule.enabled && group.enabled ? Colors.green : Colors.grey;

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 72, right: 16),
      leading: CircleAvatar(
        backgroundColor:
            rule.action == 'allow' ? activeColor : Colors.red.shade400,
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
          Text(buildMagicWallRuleDescription(rule)),
          if (rule.description != null && rule.description!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              rule.description!,
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(value: rule.enabled, onChanged: (value) => onToggleRule()),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                onEditRule();
              } else if (value == 'delete') {
                onDeleteRule();
              }
            },
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
          ),
        ],
      ),
      isThreeLine: true,
    );
  }
}

String buildMagicWallRuleDescription(MagicWallRuleModel rule) {
  final parts = <String>[];

  parts.add(rule.action == 'allow' ? '允许' : '阻止');
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
