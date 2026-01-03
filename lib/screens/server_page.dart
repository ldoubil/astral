import 'package:astral/utils/show_server_dialog.dart';
import 'package:astral/k/services/service_manager.dart';
import 'package:astral/k/models/server_mod.dart';
import 'package:astral/widgets/server_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:isar_community/isar.dart';
import 'package:astral/widgets/server_reorder_sheet.dart';

class ServerPage extends StatefulWidget {
  const ServerPage({super.key});

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  int _getColumnCount(double width) {
    if (width >= 1200) {
      return 4;
    } else if (width >= 900) {
      return 3;
    } else if (width >= 600) {
      return 2;
    }
    return 1;
  }

  final _services = ServiceManager();
  late AnimationController _animationController;

  // 用于去抖动的状态变量
  final Map<String, int> _lastPingResults = {};
  final Map<String, int> _stablePingCount = {};
  final Set<String> _skippedServers = {};

  @override
  void initState() {
    super.initState();

    // 使用mixin提供的vsync实现
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 初始加载服务器列表
    _loadServers();

    // 添加生命周期监听
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadServers() async {
    await _services.server.getAllServers();
  }

  @override
  Widget build(BuildContext context) {
    // 获取服务器列表并添加自动监听
    final servers = _services.serverState.servers.value;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columnCount = _getColumnCount(constraints.maxWidth);

          // 强制创建新的列表实例以触发更新
          final List<ServerMod> displayServers = List.from(servers);

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 如果服务器列表为空，显示提示信息
              if (servers.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.dns_outlined,
                          size: 80,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '暂无服务器',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '点击右下角加号按钮手动添加服务器',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else if (columnCount == 1)
                SliverPadding(
                  key: ValueKey(
                    'list_layout_${columnCount}_${servers.hashCode}',
                  ),
                  padding: const EdgeInsets.all(12),
                  sliver: SliverList.separated(
                    itemCount: displayServers.length,
                    itemBuilder: (context, index) {
                      final server = displayServers[index];
                      return ServerCard(
                        key: ValueKey(server.id),
                        server: server,
                        onEdit: () {
                          showEditServerDialog(context, server: server);
                        },
                        onDelete: () {
                          _showDeleteConfirmDialog(server);
                        },
                      );
                    },
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 8),
                  ),
                )
              else
                SliverPadding(
                  key: ValueKey(
                    'grid_layout_${columnCount}_${servers.hashCode}',
                  ),
                  padding: const EdgeInsets.all(12),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: columnCount,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childCount: displayServers.length,
                    itemBuilder: (context, index) {
                      final server = displayServers[index];
                      return ServerCard(
                        server: server,
                        onEdit: () {
                          showEditServerDialog(context, server: server);
                        },
                        onDelete: () {
                          _showDeleteConfirmDialog(server);
                        },
                      );
                    },
                  ),
                ),
              // 添加底部安全区域，防止内容被遮挡
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 20,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'server_sort',
            onPressed: () async {
              final currentServers = _services.serverState.servers.value;
              final reorderedServers = await ServerReorderSheet.show(
                context,
                currentServers,
              );
              if (reorderedServers != null && mounted) {
                await _services.server.reorderServers(reorderedServers);
                // 使用更可靠的状态更新方式
                setState(() {
                  // 使用展开运算符确保生成新列表实例
                  _services.serverState.servers.value = [...reorderedServers];
                });
              }
            },
            child: const Icon(Icons.sort),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: '添加服务器',
            onPressed: () => showAddServerDialog(context),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  // 显示删除确认对话框
  void _showDeleteConfirmDialog(ServerMod server) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('删除服务器'),
            content: Text('确定要删除服务器 "${server.name}" 吗？此操作不可撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  _services.server.deleteServer(server);
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('删除'),
              ),
            ],
          ),
    );
  }

  // 重置去抖状态
  void _resetDebounceState() {
    _lastPingResults.clear();
    _stablePingCount.clear();
    _skippedServers.clear();
    debugPrint('页面重新可见，重置去抖状态，恢复所有服务器更新');
  }
}
