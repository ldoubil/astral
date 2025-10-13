import 'package:astral/utils/show_server_dialog.dart';
import 'package:astral/k/app_s/aps.dart1';
import 'package:astral/k/models/server_mod.dart';
import 'package:astral/widgets/server_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:astral/widgets/server_reorder_sheet.dart';
import 'package:astral/widgets/public_servers_dialog.dart'; // 新增公共服务器对话框导入
import 'dart:async'; // 添加Timer导入

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

  final _aps = Aps();
  late AnimationController _animationController;
  Timer? _updateTimer; // 改为可空类型
  bool _isForeground = true;
  bool _isVisible = true;
  bool _isUpdating = false; // 添加更新状态标记

  // 去抖相关变量
  final Map<int, int?> _lastPingResults = {}; // 记录每个服务器的上次ping结果
  final Map<int, int> _stablePingCount = {}; // 记录每个服务器稳定ping值的连续次数
  final Set<int> _skippedServers = {}; // 记录被跳过更新的服务器ID
  static const int _maxStableCount = 3; // 连续相同结果超过3次就跳过更新

  @override
  void initState() {
    super.initState();

    // 使用mixin提供的vsync实现
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 初始化时重置去抖状态
    _resetDebounceState();

    // 初始加载服务器列表
    _loadServers();

    // 添加生命周期监听
    WidgetsBinding.instance.addObserver(this);

    // 启动初始更新定时器
    _startUpdateTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 检查页面可见性
    final isVisible = ModalRoute.of(context)?.isCurrent ?? false;
    if (isVisible != _isVisible) {
      _isVisible = isVisible;

      // 如果页面重新变为可见，重置去抖状态
      if (isVisible) {
        _resetDebounceState();
      }

      _restartUpdateTimer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 更新应用前后台状态
    final isForeground = state == AppLifecycleState.resumed;
    if (isForeground != _isForeground) {
      _isForeground = isForeground;
      _restartUpdateTimer();
    }
  }

  void _startUpdateTimer() {
    // 只有在页面可见且应用在前台时才启动定时器
    if (!_isVisible || !_isForeground) {
      return;
    }

    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (mounted && _isVisible && _isForeground && !_isUpdating) {
        _updateServers();
      }
    });

    // 立即触发一次更新
    if (mounted && _isVisible && _isForeground) {
      _updateServers();
    }
  }

  void _restartUpdateTimer() {
    if (_updateTimer?.isActive == true) {
      _updateTimer?.cancel();
    }
    // 只有在页面可见且应用在前台时才重启定时器
    if (_isVisible && _isForeground) {
      _startUpdateTimer();
    }
  }

  Future<void> _updateServers() async {
    // 只有在页面可见且应用在前台时才执行更新
    if (!_isVisible || !_isForeground || _isUpdating) {
      return;
    }

    _isUpdating = true;

    try {
      await _aps.getAllServers();

      // 批量处理ping操作，避免并发过多
      final servers = _aps.servers.value;
      final futures = <Future<void>>[];

      // 限制并发数量，分批处理
      const batchSize = 5;
      for (int i = 0; i < servers.length; i += batchSize) {
        final batch = servers.skip(i).take(batchSize);
        for (var server in batch) {
          // 检查是否应该跳过这个服务器的更新
          if (!_skippedServers.contains(server.id)) {
            futures.add(_pingServerWithDebounce(server));
          }
        }

        // 等待当前批次完成后再处理下一批
        if (futures.isNotEmpty) {
          await Future.wait(futures, eagerError: false);
          futures.clear();
        }
      }

      if (mounted) {
        setState(() {}); // 强制刷新UI
      }
    } catch (e) {
      // 忽略更新错误，避免影响后续更新
      debugPrint('服务器更新错误: $e');
    } finally {
      _isUpdating = false;
    }
  }

  // 带去抖功能的ping方法
  Future<void> _pingServerWithDebounce(ServerMod server) async {
    try {
      // 执行ping操作
      await _aps.pingServerOnce(server);

      // 从pingResults获取当前ping结果
      final currentPing = _aps.getPingResult(server.url);
      final serverId = server.id;

      // 检查是否与上次结果相同
      if (_lastPingResults[serverId] == currentPing) {
        // 相同结果，增加计数
        _stablePingCount[serverId] = (_stablePingCount[serverId] ?? 0) + 1;

        // 如果连续相同结果超过阈值，加入跳过列表
        if (_stablePingCount[serverId]! >= _maxStableCount) {
          _skippedServers.add(serverId);
          debugPrint('服务器 ${server.name} (ID: $serverId) 延迟稳定，暂停更新');
        }
      } else {
        // 结果不同，重置计数
        _stablePingCount[serverId] = 0;
        _lastPingResults[serverId] = currentPing;
      }
    } catch (e) {
      // ping失败时也重置计数，避免因网络问题导致误判
      final serverId = server.id;
      _stablePingCount[serverId] = 0;
      _lastPingResults[serverId] = null;
      debugPrint('服务器 ${server.name} ping失败: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _updateTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadServers() async {
    await _aps.getAllServers();
  }

  @override
  Widget build(BuildContext context) {
    // 获取服务器列表并添加自动监听
    final servers = _aps.servers.watch(context);

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
                          '点击右下角星球按钮添加公共服务器',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '或点击加号按钮手动添加服务器',
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
                  padding: const EdgeInsets.all(14),
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
                        (context, index) => const SizedBox(height: 12),
                  ),
                )
              else
                SliverPadding(
                  key: ValueKey(
                    'grid_layout_${columnCount}_${servers.hashCode}',
                  ),
                  padding: const EdgeInsets.all(14),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: columnCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
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
              final currentServers = _aps.servers.value;
              final reorderedServers = await ServerReorderSheet.show(
                context,
                currentServers,
              );
              if (reorderedServers != null && mounted) {
                await _aps.reorderServers(reorderedServers);
                // 使用更可靠的状态更新方式
                setState(() {
                  // 使用展开运算符确保生成新列表实例
                  _aps.servers.value = [...reorderedServers];
                });
              }
            },
            child: const Icon(Icons.sort),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'public_servers_dialog',
            onPressed: () => _showPublicServersDialog(),
            child: const Icon(Icons.public),
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

  // 显示公共服务器列表对话框
  void _showPublicServersDialog() {
    PublicServersDialog.show(context, _addPublicServer);
  }

  // 添加公共服务器
  void _addPublicServer(String name, String url) {
    final server = ServerMod(
      id: 1,
      enable: false,
      name: name,
      url: url,
      tcp: true,
      udp: false,
      ws: false,
      wss: false,
      quic: false,
      wg: false,
      txt: false,
      srv: false,
      http: false,
      https: false,
    );

    _aps.addServer(server);
    // 强制触发服务器列表更新
    _aps.servers.value = [..._aps.servers.value];
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已添加服务器: $name')));
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
                  _aps.deleteServer(server);
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
