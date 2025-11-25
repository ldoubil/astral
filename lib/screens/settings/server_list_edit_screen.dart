import 'package:astral/models/base.dart';
import 'package:astral/models/server_node.dart';
import 'package:astral/state/v2/server.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 服务器列表编辑页面（MD3 风格）
class ServerListEditScreen extends StatefulWidget {
  const ServerListEditScreen({super.key});

  @override
  State<ServerListEditScreen> createState() => _ServerListEditScreenState();
}

class _ServerListEditScreenState extends State<ServerListEditScreen> {
  final V2ServerState _serverState = V2ServerState();

  @override
  void initState() {
    super.initState();
    // 如果列表为空，添加默认服务器
    if (_serverState.serverNodes.value.isEmpty) {
      final defaultServer = ServerNode();
      defaultServer.host = 'turn.bj.629957.xyz';
      defaultServer.port = 11010;
      defaultServer.protocolSwitch = ServerProtocolSwitch.tcp;
      _serverState.addServerNode(defaultServer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('服务器列表'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '添加服务器',
            onPressed: () => _showAddServerDialog(context),
          ),
        ],
      ),
      body: Watch((context) {
        final servers = _serverState.serverNodes.value;

        if (servers.isEmpty) {
          return _buildEmptyState(theme);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: servers.length,
          itemBuilder: (context, index) {
            final server = servers[index];
            return _buildServerCard(context, theme, server);
          },
        );
      }),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dns_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无服务器',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右上角按钮添加服务器',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerCard(
    BuildContext context,
    ThemeData theme,
    ServerNode server,
  ) {
    final address = '${server.host}:${server.port}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.dns,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          address,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          'TCP',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditServerDialog(context, server),
              tooltip: '编辑',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmDialog(context, server),
              tooltip: '删除',
            ),
          ],
        ),
      ),
    );
  }

  void _showAddServerDialog(BuildContext context) {
    _showServerDialog(context, null);
  }

  void _showEditServerDialog(BuildContext context, ServerNode server) {
    _showServerDialog(context, server);
  }

  void _showServerDialog(BuildContext context, ServerNode? server) {
    final isEdit = server != null;

    // 表单控制器
    final hostController = TextEditingController(text: server?.host ?? '');
    final portController = TextEditingController(
      text: server?.port.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEdit ? '编辑服务器' : '添加服务器'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 主机地址
                TextField(
                  controller: hostController,
                  decoration: const InputDecoration(
                    labelText: '主机地址',
                    hintText: '例如: turn.bj.629957.xyz',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: !isEdit,
                ),
                const SizedBox(height: 16),
                // 端口
                TextField(
                  controller: portController,
                  decoration: const InputDecoration(
                    labelText: '端口',
                    hintText: '例如: 11010',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                final host = hostController.text.trim();
                final portText = portController.text.trim();
                final port = int.tryParse(portText);

                // 验证输入
                if (host.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入主机地址')),
                  );
                  return;
                }

                if (port == null || port <= 0 || port > 65535) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('请输入有效的端口号 (1-65535)'),
                    ),
                  );
                  return;
                }

                // 创建或更新服务器节点，协议固定为 TCP
                if (isEdit) {
                  server.host = host;
                  server.port = port;
                  server.protocolSwitch = ServerProtocolSwitch.tcp;
                  _serverState.updateServerNode(server);
                } else {
                  final newServer = ServerNode();
                  newServer.host = host;
                  newServer.port = port;
                  newServer.protocolSwitch = ServerProtocolSwitch.tcp;
                  _serverState.addServerNode(newServer);
                }

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit ? '服务器已更新' : '服务器已添加'),
                  ),
                );
              },
              child: Text(isEdit ? '保存' : '添加'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, ServerNode server) {
    final address = '${server.host}:${server.port}';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('删除服务器'),
          content: Text('确定要删除服务器 "$address" 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                _serverState.removeServerNode(server.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('服务器已删除')),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }
}

