import 'package:astral/k/app_s/aps.dart1';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:astral/data/models/server_model.dart';
import 'package:astral/state/server_list_state.dart';
import 'package:astral/utils/server_dialogs/add_server_dialog.dart';
import 'package:signals_flutter/signals_flutter.dart';

class CustomServerPage extends StatefulWidget {
  const CustomServerPage({super.key});

  @override
  State<CustomServerPage> createState() => _CustomServerPageState();
}

class _CustomServerPageState extends State<CustomServerPage> {
  final ServerListState _serverListState = ServerListState();

  @override
  void initState() {
    super.initState();
    // 初始化时加载服务器列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _serverListState.initialize();
    });
  }

  Future<void> _refreshServers() async {
    await _serverListState.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义服务器'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '添加服务器',
            onPressed: () async {
              final result = await showAddServerDialog(context);
              if (result != null) {
                _serverListState.addServer(result);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshServers,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Watch((context) {
              final servers = _serverListState.serverList.value;
              final isLoading = _serverListState.isLoading.value;
              final errorMessage = _serverListState.errorMessage.value;

              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (errorMessage != null) {
                return _buildErrorWidget(errorMessage);
              }

              if (servers.isEmpty) {
                return _buildEmptyWidget();
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  int crossAxisCount = 1;
                  if (width >= 1200) {
                    crossAxisCount = 3;
                  } else if (width >= 800) {
                    crossAxisCount = 2;
                  }

                  const padding = EdgeInsets.all(16);
                  if (crossAxisCount == 1) {
                    return RefreshIndicator(
                      onRefresh: _refreshServers,
                      child: ListView.builder(
                        padding: padding,
                        itemCount: servers.length,
                        itemBuilder: (context, index) {
                          final server = servers[index];
                          return _buildServerCard(server);
                        },
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshServers,
                    child: MasonryGridView.count(
                      padding: padding,
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      itemCount: servers.length,
                      itemBuilder: (context, index) {
                        final server = servers[index];
                        return _buildServerCard(server);
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildServerCard(ServerModel server) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final result = await showAddServerDialog(context, initial: server);
          if (result != null) {
            _serverListState.updateServer(result);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  server.enable ? Icons.cloud_done : Icons.cloud_off,
                  color: cs.primary,
                ),
                title: Text(
                  server.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      server.url,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (server.description != null &&
                        server.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          server.description!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      final result = await showAddServerDialog(
                        context,
                        initial: server,
                      );
                      if (result != null) {
                        _serverListState.updateServer(result);
                      }
                    } else if (value == 'delete') {
                      final confirmed = await _showDeleteConfirmDialog(
                        server.name,
                      );
                      if (confirmed == true) {
                        _serverListState.removeServer(server.id.toString());
                      }
                    } else if (value == 'toggle') {
                      final updatedServer = server.copyWith(
                        enable: !server.enable,
                        updatedAt: DateTime.now(),
                      );
                      _serverListState.updateServer(updatedServer);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('编辑')),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Text(server.enable ? '禁用' : '启用'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            '删除',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Chip(
                    avatar: const Icon(Icons.swap_calls, size: 16),
                    label: Text(_protocolLabel(server.protocol)),
                  ),
                  Chip(
                    avatar: const Icon(Icons.sort, size: 16),
                    label: Text('排序 ${server.sortOrder}'),
                  ),
                  Chip(
                    avatar: Icon(
                      server.enable ? Icons.check_circle : Icons.cancel,
                      size: 16,
                    ),
                    label: Text(server.enable ? '启用' : '禁用'),
                    backgroundColor:
                        server.enable ? Colors.green[50] : Colors.grey[100],
                  ),
                  Chip(
                    avatar: const Icon(Icons.access_time, size: 16),
                    label: Text(_formatDate(server.createdAt)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.dns_outlined, size: 48, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            '暂无自定义服务器',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右上角"添加"创建你的服务器',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
          ),
          const SizedBox(height: 24),
          Text(
            '加载失败',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!, width: 1),
            ),
            child: Text(
              errorMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.red[700]),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshServers,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmDialog(String serverName) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认删除'),
            content: Text('确定要删除服务器 "$serverName" 吗？此操作不可撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('删除'),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

String _protocolLabel(ProtocolType p) {
  switch (p) {
    case ProtocolType.tcp:
      return 'TCP';
    case ProtocolType.udp:
      return 'UDP';
    case ProtocolType.ws:
      return 'WS';
    case ProtocolType.wss:
      return 'WSS';
    case ProtocolType.quic:
      return 'QUIC';
    case ProtocolType.wg:
      return 'WireGuard';
    case ProtocolType.txt:
      return 'TXT';
    case ProtocolType.srv:
      return 'SRV';
    case ProtocolType.http:
      return 'HTTP';
    case ProtocolType.https:
      return 'HTTPS';
  }
}
