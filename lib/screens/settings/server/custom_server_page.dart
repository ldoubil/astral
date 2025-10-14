import 'package:astral/models/server_node.dart';
import 'package:astral/models/base.dart';
import 'package:astral/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 自定义服务器管理页面
/// 提供添加、删除、编辑自定义服务器的能力，风格参考公共服务器页面
class CustomServerPage extends StatefulWidget {
  const CustomServerPage({super.key});

  @override
  State<CustomServerPage> createState() => _CustomServerPageState();
}

class _CustomServerPageState extends State<CustomServerPage> {
  final _appState = AppState();

  /// 构建页面主体
  /// 使用 signals 的 watch 以监听自定义服务器列表变化并自动刷新
  @override
  Widget build(BuildContext context) {
    final servers = _appState.serverState.serverNodes.watch(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义服务器'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddOrEditDialog(context, null),
            tooltip: '添加服务器',
          ),
        ],
      ),
      body: servers.isEmpty
          ? _buildEmptyWidget()
          : LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                int crossAxisCount = 1;
                if (width >= 1200) {
                  crossAxisCount = 3;
                } else if (width >= 800) {
                  crossAxisCount = 2;
                }

                final padding = const EdgeInsets.all(16);
                if (crossAxisCount == 1) {
                  // 窄屏（手机）使用列表
                  return ListView.builder(
                    padding: padding,
                    itemCount: servers.length,
                    itemBuilder: (context, index) {
                      final server = servers[index];
                      return _buildServerCard(server);
                    },
                  );
                }

                // 宽屏（桌面）使用瀑布流网格，适配不等高卡片
                return MasonryGridView.count(
                  padding: padding,
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  itemCount: servers.length,
                  itemBuilder: (context, index) {
                    final server = servers[index];
                    return _buildServerCard(server);
                  },
                );
              },
            ),
    );
  }

  /// 构建服务器卡片
  /// 展示服务器的基础信息与操作入口（编辑/删除）
  Widget _buildServerCard(ServerNode server) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.dns_outlined, color: cs.primary),
              title: Text(
                server.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                server.port == 0 
                  ? server.host 
                  : '${server.host}:${server.port}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    tooltip: '编辑',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showAddOrEditDialog(context, server),
                  ),
                  IconButton(
                    tooltip: '删除',
                    icon: Icon(Icons.delete_outline, color: cs.error),
                    onPressed: () => _confirmDelete(context, server),
                  ),
                ],
              ),
            ),

            if (server.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                server.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.7),
                    ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  avatar: const Icon(Icons.info_outline, size: 16),
                  label: Text('内核版本 ${server.version.isNotEmpty ? server.version : '未知'}'),
                ),
                Chip(
                  avatar: Icon(
                    server.allowRelay ? Icons.swap_horiz : Icons.block,
                    size: 16,
                  ),
                  label: Text(server.allowRelay ? '可中继' : '不可中继'),
                ),
                Chip(
                  avatar: const Icon(Icons.settings_ethernet, size: 16),
                  label: Text('协议 ${_protocolText(server.protocolSwitch)}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  /// 展示添加/编辑服务器的对话框
  /// existing == null 表示添加；否则为编辑
  Future<void> _showAddOrEditDialog(BuildContext context, ServerNode? existing) async {
    final isEditing = existing != null;

    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final hostCtrl = TextEditingController(text: existing?.host ?? '');
    final portCtrl = TextEditingController(
      text: isEditing 
        ? (existing.port == 0 ? '' : existing.port.toString())
        : ''
    );
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    ServerProtocolSwitch protocol = existing?.protocolSwitch ?? ServerProtocolSwitch.tcp;
    bool allowRelay = existing?.allowRelay ?? false;
    double usagePercentage = existing?.usagePercentage ?? 0.0;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? '编辑服务器' : '添加服务器'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: '名称'),
                    ),
                    TextField(
                      controller: hostCtrl,
                      decoration: const InputDecoration(labelText: '主机地址'),
                    ),
                    TextField(
                      controller: portCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '端口',
                        hintText: '可选，留空使用默认端口',
                      ),
                    ),
                    DropdownButtonFormField<ServerProtocolSwitch>(
                      value: protocol,
                      decoration: const InputDecoration(labelText: '协议'),
                      items: ServerProtocolSwitch.values
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(_protocolText(e)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() {
                            protocol = v;
                          });
                        }
                      },
                    ),
                  
                    TextField(
                      controller: descCtrl,
                      decoration: const InputDecoration(labelText: '描述'),
                      maxLines: 3,
                    ),
                    SwitchListTile(
                      title: const Text('允许中继'),
                      value: allowRelay,
                      onChanged: (v) {
                        setDialogState(() {
                          allowRelay = v;
                        });
                      },
                    ),
                   
                  ],
                ),
               ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final host = hostCtrl.text.trim();
                    final portText = portCtrl.text.trim();
                    final port = portText.isEmpty ? 0 : (int.tryParse(portText) ?? -1);
                    
                    if (name.isEmpty || host.isEmpty || (portText.isNotEmpty && port <= 0)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请填写完整且有效的服务器信息')),
                      );
                      return;
                    }

                    if (isEditing) {
                      final updated = ServerNode()
                        ..id = existing.id
                        ..name = name
                        ..host = host
                        ..port = port
                        ..protocolSwitch = protocol
                        ..description = descCtrl.text.trim()
                        ..allowRelay = allowRelay
                        ..usagePercentage = usagePercentage
                        ..isPublic = false;
                      _appState.serverState.updateServerNode(updated);
                    } else {
                      final created = ServerNode.create(
                        name: name,
                        host: host,
                        port: port,
                        protocolSwitch: protocol,
                        description: descCtrl.text.trim(),
                        allowRelay: allowRelay,
                        usagePercentage: usagePercentage,
                        isPublic: false,
                      );
                      _appState.serverState.addServerNode(created);
                    }

                    Navigator.of(context).pop();
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 删除前确认
  Future<void> _confirmDelete(BuildContext context, ServerNode server) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除服务器'),
          content: Text('确认删除服务器 "${server.name}" 吗？该操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      _appState.serverState.removeServerNode(server.id);
    }
  }

  /// 空状态提示
  Widget _buildEmptyWidget() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.dns_outlined, 
              size: 48, 
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '暂无自定义服务器',
            style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右上角 + 按钮添加服务器',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 将协议枚举转换为显示文本
  String _protocolText(ServerProtocolSwitch p) {
    switch (p) {
      case ServerProtocolSwitch.tcp:
        return 'TCP';
      case ServerProtocolSwitch.udp:
        return 'UDP';
      case ServerProtocolSwitch.ws:
        return 'WS';
      case ServerProtocolSwitch.wss:
        return 'WSS';
      case ServerProtocolSwitch.quic:
        return 'QUIC';
      case ServerProtocolSwitch.wg:
        return 'WG';
      case ServerProtocolSwitch.txt:
        return 'TXT';
      case ServerProtocolSwitch.srv:
        return 'SRV';
      case ServerProtocolSwitch.http:
        return 'HTTP';
      case ServerProtocolSwitch.https:
        return 'HTTPS';
    }
  }
}