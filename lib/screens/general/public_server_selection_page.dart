import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../models/server_node.dart';
import '../../models/base.dart';
import '../../data/models/server_json_node.dart';
import '../../services/server_api_service.dart';

/// 公共服务器选择页面
/// 允许用户从公共服务器列表中选择要添加到NetNode的服务器
/// 需要将ServerJsonNode转换为ServerNode格式
class PublicServerSelectionPage extends StatefulWidget {
  /// 需要排除的服务器列表（已经在NetNode中的服务器）
  final List<ServerNode> excludeServers;

  const PublicServerSelectionPage({
    super.key,
    required this.excludeServers,
  });

  @override
  State<PublicServerSelectionPage> createState() => _PublicServerSelectionPageState();
}

class _PublicServerSelectionPageState extends State<PublicServerSelectionPage> {
  bool _isLoading = false;
  List<ServerJsonNode> _publicServers = [];
  String? _errorMessage;
  final Set<int> _selectedServerIds = <int>{};

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  /// 加载公共服务器列表
  Future<void> _loadServers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ServerApiService.getPublicServers();
      if (response.success) {
        setState(() {
          _publicServers = _getAvailableServers(response.data.items);
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

  /// 获取可选择的服务器列表（排除已存在的服务器）
  List<ServerJsonNode> _getAvailableServers(List<ServerJsonNode> allServers) {
    final excludeHosts = widget.excludeServers
        .map((s) => '${s.host}:${s.port}')
        .toSet();
    
    return allServers.where((server) {
      final serverAddress = '${server.host}:${server.port}';
      return !excludeHosts.contains(serverAddress) && server.isHealthy;
    }).toList();
  }

  /// 将ServerJsonNode转换为ServerNode
  ServerNode _convertToServerNode(ServerJsonNode jsonNode) {
    // 协议转换映射
    ServerProtocolSwitch protocolSwitch;
    switch (jsonNode.protocol.toLowerCase()) {
      case 'udp':
        protocolSwitch = ServerProtocolSwitch.udp;
        break;
      case 'ws':
        protocolSwitch = ServerProtocolSwitch.ws;
        break;
      case 'wss':
        protocolSwitch = ServerProtocolSwitch.wss;
        break;
      case 'quic':
        protocolSwitch = ServerProtocolSwitch.quic;
        break;
      case 'tcp':
      default:
        protocolSwitch = ServerProtocolSwitch.tcp;
        break;
    }

    return ServerNode.create(
      name: jsonNode.name,
      host: jsonNode.host,
      port: jsonNode.port,
      protocolSwitch: protocolSwitch,
      description: jsonNode.description,
      version: jsonNode.version,
      allowRelay: jsonNode.allowRelay,
      usagePercentage: jsonNode.usagePercentage ?? 0.0,
      isPublic: true, // 标记为公共服务器
    );
  }

  /// 切换服务器选择状态
  void _toggleServerSelection(ServerJsonNode server) {
    setState(() {
      if (_selectedServerIds.contains(server.id)) {
        _selectedServerIds.remove(server.id);
      } else {
        _selectedServerIds.add(server.id);
      }
    });
  }

  /// 返回选中的服务器列表（转换为ServerNode格式）
  void _returnSelectedServers() {
    final selectedServers = _publicServers
        .where((server) => _selectedServerIds.contains(server.id))
        .map((jsonNode) => _convertToServerNode(jsonNode))
        .toList();
    Navigator.of(context).pop(selectedServers);
  }

  /// 构建服务器卡片
  Widget _buildServerCard(ServerJsonNode server) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedServerIds.contains(server.id);

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected 
          ? colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      child: InkWell(
        onTap: () => _toggleServerSelection(server),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行
              Row(
                children: [
                  Expanded(
                    child: Text(
                      server.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? colorScheme.primary : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: colorScheme.primary,
                      size: 20,
                    )
                  else
                    Icon(
                      Icons.radio_button_unchecked,
                      color: colorScheme.outline,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // 服务器地址
              Row(
                children: [
                  Icon(
                    Icons.dns_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${server.host}:${server.port}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              // 描述信息
              if (server.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  server.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 8),
              
              // 状态和信息行
              Row(
                children: [
                  // 协议标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      server.protocol.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // 健康状态
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: server.isHealthy 
                          ? colorScheme.primaryContainer
                          : colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      server.statusText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: server.isHealthy 
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  
                  // 负载百分比
                  if (server.usagePercentage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        server.loadPercentageText,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              
              // 中继状态
              if (server.allowRelay) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '支持中继',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 构建加载状态界面
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('正在加载公共服务器列表...'),
        ],
      ),
    );
  }

  /// 构建错误状态界面
  Widget _buildErrorState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            '加载失败',
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? '未知错误',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadServers,
            child: const Text('重试'),
          ),
        ],
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
            '暂无可选择的公共服务器',
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '所有健康的公共服务器都已添加',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建服务器网格列表
  Widget _buildServerGrid(List<ServerJsonNode> servers) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount = 1;
        if (width >= 1200) {
          crossAxisCount = 3;
        } else if (width >= 800) {
          crossAxisCount = 2;
        }

        if (crossAxisCount == 1) {
          // 窄屏使用列表
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: servers.length,
            itemBuilder: (context, index) => _buildServerCard(servers[index]),
          );
        } else {
          // 宽屏使用网格
          return MasonryGridView.count(
            crossAxisCount: crossAxisCount,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: servers.length,
            itemBuilder: (context, index) => _buildServerCard(servers[index]),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('选择公共服务器'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 点击返回按钮时，如果有选中的服务器则自动返回
            if (_selectedServerIds.isNotEmpty) {
              _returnSelectedServers();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          if (_selectedServerIds.isNotEmpty)
            TextButton(
              onPressed: _returnSelectedServers,
              child: Text(
                '确定 (${_selectedServerIds.length})',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
        body: _isLoading
            ? _buildLoadingState()
            : _errorMessage != null
                ? _buildErrorState(colorScheme)
                : _publicServers.isEmpty
                    ? _buildEmptyState(colorScheme)
                    : _buildServerGrid(_publicServers),
      bottomNavigationBar: _selectedServerIds.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _returnSelectedServers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    '添加选中的服务器 (${_selectedServerIds.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}