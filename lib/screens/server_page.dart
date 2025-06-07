import 'package:astral/fun/show_server_dialog.dart';
import 'package:astral/k/app_s/aps.dart';
import 'package:astral/k/models/server_mod.dart';
import 'package:astral/wid/server_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:isar/isar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:astral/wid/server_reorder_sheet.dart';


class ServerPage extends StatefulWidget {
  const ServerPage({super.key});

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
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

  @override
  void initState() {
    super.initState();
    // 初始化时加载所有服务器
    _loadServers();
  }

  Future<void> _loadServers() async {
    await _aps.getAllServers();
  }

  @override
  Widget build(BuildContext context) {
    // 监听连接状态
    final isConnected = _aps.Connec_state.watch(context);
    // 获取当前选中房间（如无此逻辑请替换为你的实际选中房间变量）
    final selectedRoom = _aps.selectroom.watch(context); // 假设有 selectedRoom 字段

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columnCount = _getColumnCount(constraints.maxWidth);
          final servers = _aps.servers.watch(context);
          
          // 强制创建新的列表实例以触发更新
          final List<ServerMod> displayServers = List.from(servers);
          
          // 添加唯一标识符确保布局强制重建
          final layoutKey = ValueKey('layout_${columnCount}_${servers.length}');
          
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
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '点击右下角星球按钮添加公共服务器',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '或点击加号按钮手动添加服务器',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                  key: ValueKey('list_layout_${columnCount}_${servers.hashCode}'),
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
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                  ),
                )
              else
                SliverPadding(
                  key: ValueKey('grid_layout_${columnCount}_${servers.hashCode}'),
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
            heroTag: 'sort',
            onPressed: () async {
              final currentServers = _aps.servers.value;
              final reorderedServers = await ServerReorderSheet.show(context, currentServers);
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
            heroTag: '公共服务器',
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
  void _showPublicServersDialog() async {
    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('正在获取公共服务器列表...'),
          ],
        ),
      ),
    );

    try {
      // 从API获取公共服务器列表
      final response = await http.get(
        Uri.parse('https://astral.fan/server.json'),
        headers: {'Content-Type': 'application/json'},
      );

      // 关闭加载对话框
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final publicServers = jsonData.map((item) => {
          'name': item['name'] as String,
          'url': item['url'] as String,
        }).toList();

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('公共服务器列表'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: ListView.builder(
                itemCount: publicServers.length,
                itemBuilder: (context, index) {
                  final server = publicServers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(
                        server['name']!,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        server['url']!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          _addPublicServer(server['name']!, server['url']!);
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: const Text('添加', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('关闭'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      // 关闭加载对话框（如果还在显示）
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('获取公共服务器列表失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 添加公共服务器
  void _addPublicServer(String name, String url) {
    final server = ServerMod(
      id: Isar.autoIncrement,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已添加服务器: $name')),
    );
  }

  // 显示删除确认对话框
  void _showDeleteConfirmDialog(ServerMod server) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
}
