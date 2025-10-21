import 'package:flutter/material.dart';
import 'package:astral/models/net_node.dart';
import 'package:astral/models/server_node.dart';
import 'package:astral/screens/general/server_selection_dialog.dart';
import 'package:astral/screens/general/custom_server_selection_page.dart';
import 'package:astral/screens/general/public_server_selection_page.dart';

/// 服务器列表管理页面
/// 用于管理NetNode中的peer服务器列表
class ServerListPage extends StatefulWidget {
  final NetNode netNode;

  const ServerListPage({
    super.key,
    required this.netNode,
  });

  @override
  State<ServerListPage> createState() => _ServerListPageState();
}

class _ServerListPageState extends State<ServerListPage> {
  late NetNode _netNode;
  late List<ServerNode> _serverList;

  @override
  void initState() {
    super.initState();
    _netNode = widget.netNode;
    _serverList = List<ServerNode>.from(_netNode.peer);
  }

  /// 保存更改到NetNode
  void _saveChanges() {
    _netNode.peer = List<ServerNode>.from(_serverList);
    Navigator.of(context).pop(_netNode);
  }

  /// 添加服务器
  /// 显示选择弹窗，让用户选择从自定义服务器还是公共服务器添加
  Future<void> _addServer() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const ServerSelectionDialog(),
    );

    if (result != null) {
      List<ServerNode>? selectedServers;
      
      if (result == 'custom') {
        // 导航到自定义服务器选择页面
        selectedServers = await Navigator.of(context).push<List<ServerNode>>(
          MaterialPageRoute(
            builder: (context) => CustomServerSelectionPage(
              excludeServers: _serverList,
            ),
          ),
        );
      } else if (result == 'public') {
        // 导航到公共服务器选择页面
        selectedServers = await Navigator.of(context).push<List<ServerNode>>(
          MaterialPageRoute(
            builder: (context) => PublicServerSelectionPage(
              excludeServers: _serverList,
            ),
          ),
        );
      }

      if (selectedServers != null && selectedServers.isNotEmpty) {
        setState(() {
          // 添加选中的服务器，自动去重
          for (final server in selectedServers!) {
            if (!_serverList.any((existing) => existing.id == server.id)) {
              _serverList.add(server);
            }
          }
        });
      }
    }
  }

  /// 删除服务器
  void _removeServer(ServerNode server) {
    setState(() {
      _serverList.removeWhere((s) => s.id == server.id);
    });
  }

  /// 编辑服务器
  Future<void> _editServer(ServerNode server) async {
    final result = await _showEditServerDialog(server);
    if (result != null) {
      setState(() {
        final index = _serverList.indexWhere((s) => s.id == server.id);
        if (index != -1) {
          _serverList[index] = result;
        }
      });
    }
  }

  /// 显示编辑服务器对话框
  Future<ServerNode?> _showEditServerDialog(ServerNode server) async {
    final nameController = TextEditingController(text: server.name);
    final hostController = TextEditingController(text: server.host);
    final portController = TextEditingController(text: server.port.toString());
    final descController = TextEditingController(text: server.description);

    return showDialog<ServerNode>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('编辑服务器'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '服务器名称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: hostController,
                  decoration: const InputDecoration(
                    labelText: '主机地址',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: portController,
                  decoration: const InputDecoration(
                    labelText: '端口',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: '描述',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
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
                final name = nameController.text.trim();
                final host = hostController.text.trim();
                final portText = portController.text.trim();
                final desc = descController.text.trim();

                if (name.isEmpty || host.isEmpty || portText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请填写完整信息')),
                  );
                  return;
                }

                final port = int.tryParse(portText);
                if (port == null || port <= 0 || port > 65535) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入有效的端口号')),
                  );
                  return;
                }

                final updatedServer = ServerNode.fromData(
                  id: server.id,
                  name: name,
                  host: host,
                  port: port,
                  protocolSwitch: server.protocolSwitch,
                  description: desc,
                  version: server.version,
                  allowRelay: server.allowRelay,
                  usagePercentage: server.usagePercentage,
                  isPublic: server.isPublic,
                );

                Navigator.of(context).pop(updatedServer);
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  /// 确认删除对话框
  Future<void> _confirmDelete(ServerNode server) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除服务器'),
          content: Text('确定要删除服务器 "${server.name}" 吗？'),
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

    if (confirmed == true) {
      _removeServer(server);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('服务器列表'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 点击返回按钮时自动保存并返回
            _saveChanges();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
            tooltip: '保存更改',
          ),
        ],
      ),
        body: _serverList.isEmpty
            ? _buildEmptyState(colorScheme)
            : _buildServerList(),
        floatingActionButton: FloatingActionButton(
          onPressed: _addServer,
          tooltip: '添加服务器',
          child: const Icon(Icons.add),
        ),
    );
  }

  /// 构建空状态界面
  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dns_outlined,
            size: 64,
            color: colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无服务器',
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮添加服务器',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建服务器列表
  Widget _buildServerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _serverList.length,
      itemBuilder: (context, index) {
        final server = _serverList[index];
        return _buildServerCard(server);
      },
    );
  }

  /// 构建服务器卡片
  Widget _buildServerCard(ServerNode server) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dns_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        server.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${server.host}:${server.port}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _editServer(server),
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: '编辑',
                    ),
                    IconButton(
                      onPressed: () => _confirmDelete(server),
                      icon: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                      ),
                      tooltip: '删除',
                    ),
                  ],
                ),
              ],
            ),
            if (server.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                server.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                if (server.isPublic)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '公共',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (server.allowRelay) ...[
                  if (server.isPublic) const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '中继',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  server.protocolSwitch.name.toUpperCase(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}