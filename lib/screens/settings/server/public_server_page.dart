import '../../../data/models/server_node.dart';
import 'package:flutter/material.dart';
import '../../../services/server_api_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PublicServerPage extends StatefulWidget {
  const PublicServerPage({super.key});

  @override
  State<PublicServerPage> createState() => _PublicServerPageState();
}

class _PublicServerPageState extends State<PublicServerPage> {
  bool _isLoading = false;
  List<ServerNode> _publicServers = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  Future<void> _loadServers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ServerApiService.getPublicServers();
      if (response.success) {
        setState(() {
          _publicServers = response.data.items;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.error ?? '获取服务器列表失败';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('公共服务器'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshServers,
          ),
        ],
      ),
      body: Column(
        children: [
          // 服务器列表
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? _buildErrorWidget()
                    : _publicServers.isEmpty
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
                          return RefreshIndicator(
                            onRefresh: _loadServers,
                            child: ListView.builder(
                              padding: padding,
                              itemCount: _publicServers.length,
                              itemBuilder: (context, index) {
                                final server = _publicServers[index];
                                return _buildServerCard(server);
                              },
                            ),
                          );
                        }

                        // 宽屏（桌面）使用瀑布流网格，适配不等高卡片
                        return RefreshIndicator(
                          onRefresh: _loadServers,
                          child: MasonryGridView.count(
                            padding: padding,
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            itemCount: _publicServers.length,
                            itemBuilder: (context, index) {
                              final server = _publicServers[index];
                              return _buildServerCard(server);
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerCard(ServerNode server) {
    final isHealthy = server.isHealthy;
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // TODO: 添加服务器详情或连接功能
        },
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
                  '${server.host}:${server.port}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: Icon(
                  isHealthy ? Icons.cloud_done : Icons.cloud_off,
                  color: isHealthy ? cs.primary : cs.error,
                ),
              ),

              if (server.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  server.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],

              const SizedBox(height: 12),
              _buildLoadIndicator(server),

              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Chip(
                    avatar: const Icon(Icons.info_outline, size: 16),
                    label: Text('内核版本 ${server.version}'),
                  ),
                  Chip(
                    avatar: Icon(
                      server.allowRelay ? Icons.swap_horiz : Icons.block,
                      size: 16,
                    ),
                    label: Text(server.allowRelay ? '可中继' : '不可中继'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refreshServers() {
    _loadServers();
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
            '暂无公共服务器',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '当前没有可用的公共服务器\n请稍后再试或联系管理员',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshServers,
            icon: const Icon(Icons.refresh),
            label: const Text('刷新'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // 构建负载指示器
  Widget _buildLoadIndicator(ServerNode server) {
    final total = server.maxConnections > 0 ? server.maxConnections : 0;
    final current = server.currentConnections.clamp(0, total);
    final ratio = total > 0 ? current / total : 0.0;

    return Row(
      children: [
        const Icon(Icons.people_outline, size: 16),
        const SizedBox(width: 6),
        Text('$current/$total', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 12),
        Expanded(child: LinearProgressIndicator(value: ratio)),
        const SizedBox(width: 12),
        Text(
          '${(ratio * 100).round()}%',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
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
              _errorMessage ?? '未知错误',
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
}
