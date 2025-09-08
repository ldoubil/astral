import '../../../data/models/server_node.dart';
import '../../../data/models/server_api_response.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import '../../../services/server_api_service.dart';

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
                    : RefreshIndicator(
                      onRefresh: _loadServers,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _publicServers.length,
                        itemBuilder: (context, index) {
                          final server = _publicServers[index];
                          return _buildServerCard(server);
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildServerCard(ServerNode server) {
    final isHealthy = server.isHealthy;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: 添加服务器详情或连接功能
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 服务器名称和状态行
              Row(
                children: [
                  Expanded(
                    child: Text(
                      server.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  // 负载显示
                  _buildLoadIndicator(server),
                ],
              ),
              // 服务器描述（仅在有内容时显示）
              if (server.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  server.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
              const SizedBox(height: 12),
              // 服务器地址信息
              Row(
                children: [
                  Icon(Icons.dns_outlined, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    '${server.host}:${server.port}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
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
    final loadPercentage =
        server.maxConnections > 0
            ? (server.currentConnections / server.maxConnections * 100).clamp(
              0,
              100,
            )
            : 0.0;

    // 根据负载百分比确定颜色
    Color loadColor;
    if (loadPercentage < 50) {
      loadColor = Colors.green;
    } else if (loadPercentage < 80) {
      loadColor = Colors.orange;
    } else {
      loadColor = Colors.red;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // 判断是否为移动设备（宽度小于600px）
        final isMobile = constraints.maxWidth < 600;
        
        if (isMobile) {
          // 移动设备：垂直布局
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 负载显示行
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: loadColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: loadColor.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline, size: 14, color: loadColor),
                    const SizedBox(width: 4),
                    Text(
                      '${server.currentConnections}/${server.maxConnections}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: loadColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: loadPercentage / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: loadColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${loadPercentage.toInt()}%',
                      style: TextStyle(
                        fontSize: 11,
                        color: loadColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // 版本和中继信息行
              Row(
                children: [
                  // 版本信息
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 12,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              server.version,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // 中继状态
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: server.allowRelay 
                          ? Colors.green.withOpacity(0.1) 
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: server.allowRelay 
                            ? Colors.green.withOpacity(0.3) 
                            : Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          server.allowRelay ? Icons.swap_horiz : Icons.block,
                          size: 12,
                          color: server.allowRelay ? Colors.green[700] : Colors.grey[600],
                        ),
                        const SizedBox(width: 3),
                        Text(
                          server.allowRelay ? '可中继' : '不可中继',
                          style: TextStyle(
                            fontSize: 11,
                            color: server.allowRelay ? Colors.green[700] : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          // 桌面设备：水平布局
          return Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              // 负载显示
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: loadColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: loadColor.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline, size: 12, color: loadColor),
                    const SizedBox(width: 3),
                    Text(
                      '${server.currentConnections}/${server.maxConnections}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: loadColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 30,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: loadPercentage / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: loadColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${loadPercentage.toInt()}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: loadColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // 版本信息
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 10, color: Colors.blue[700]),
                    const SizedBox(width: 2),
                    Text(
                      server.version,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // 中转状态
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      server.allowRelay
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color:
                        server.allowRelay
                            ? Colors.green.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      server.allowRelay ? Icons.swap_horiz : Icons.block,
                      size: 10,
                      color: server.allowRelay ? Colors.green[700] : Colors.grey[600],
                    ),
                    const SizedBox(width: 2),
                    Text(
                      server.allowRelay ? '可中转' : '不可中转',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            server.allowRelay ? Colors.green[700] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      },
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
