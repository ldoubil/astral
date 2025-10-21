import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../models/server_node.dart';
import '../../state/app_state.dart';

/// 自定义服务器选择页面
/// 允许用户从现有的自定义服务器中选择要添加到NetNode的服务器
class CustomServerSelectionPage extends StatefulWidget {
  /// 需要排除的服务器列表（已经在NetNode中的服务器）
  final List<ServerNode> excludeServers;

  const CustomServerSelectionPage({
    super.key,
    required this.excludeServers,
  });

  @override
  State<CustomServerSelectionPage> createState() => _CustomServerSelectionPageState();
}

class _CustomServerSelectionPageState extends State<CustomServerSelectionPage> {
  final _appState = AppState();
  final Set<String> _selectedServerIds = <String>{};

  /// 获取可选择的服务器列表（排除已存在的服务器）
  List<ServerNode> _getAvailableServers(List<ServerNode> allServers) {
    final excludeIds = widget.excludeServers.map((s) => s.id).toSet();
    return allServers.where((server) => !excludeIds.contains(server.id)).toList();
  }

  /// 切换服务器选择状态
  void _toggleServerSelection(ServerNode server) {
    setState(() {
      if (_selectedServerIds.contains(server.id)) {
        _selectedServerIds.remove(server.id);
      } else {
        _selectedServerIds.add(server.id);
      }
    });
  }

  /// 返回选中的服务器列表
  void _returnSelectedServers(List<ServerNode> allServers) {
    final selectedServers = allServers
        .where((server) => _selectedServerIds.contains(server.id))
        .toList();
    Navigator.of(context).pop(selectedServers);
  }

  /// 构建服务器卡片
  Widget _buildServerCard(ServerNode server) {
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
              
              // 协议和状态信息
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
                      server.protocolSwitch.name.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  
                  // 中继状态
                  if (server.allowRelay)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '中继',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w500,
                        ),
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
            '暂无可选择的自定义服务器',
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请先在设置中添加自定义服务器',
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
  Widget _buildServerGrid(List<ServerNode> servers) {
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
    final allServers = _appState.serverState.serverNodes.value;
    final availableServers = _getAvailableServers(allServers);

    return Scaffold(
      appBar: AppBar(
        title: const Text('选择自定义服务器'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 点击返回按钮时，如果有选中的服务器则自动返回
            if (_selectedServerIds.isNotEmpty) {
              _returnSelectedServers(allServers);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          if (_selectedServerIds.isNotEmpty)
            TextButton(
              onPressed: () => _returnSelectedServers(allServers),
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
      body: availableServers.isEmpty
          ? _buildEmptyState(colorScheme)
          : _buildServerGrid(availableServers),
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
                  onPressed: () => _returnSelectedServers(allServers),
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