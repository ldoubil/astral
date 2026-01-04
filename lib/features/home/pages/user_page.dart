import 'package:astral/core/services/service_manager.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:astral/shared/widgets/cards/all_user_card.dart';
import 'package:astral/shared/widgets/cards/mini_user_card.dart';
import 'package:astral/shared/widgets/common/network_topology.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:astral/shared/widgets/common/room_settings_sheet.dart';
import 'package:signals_flutter/signals_flutter.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool _showTopology = false; // 是否显示拓扑图

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // 使用 Riverpod 监听节点数据
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'topology_toggle',
            onPressed: () {
              setState(() {
                _showTopology = !_showTopology;
              });
            },
            child: Icon(_showTopology ? Icons.list : Icons.hub),
            tooltip: _showTopology ? '列表视图' : '拓扑图',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'room_settings',
            onPressed: () => RoomSettingsSheet.show(context),
            child: const Icon(Icons.bar_chart),
            tooltip: '房间设置',
          ),
        ],
      ),
      body: Watch((context) {
        final netStatus = ServiceManager().connectionState.netStatus.watch(
          context,
        );
        final isConnecting = ServiceManager().connectionState.isConnecting
            .watch(context);
        if (!isConnecting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: 48,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  '无数据',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        } else if (netStatus == null || netStatus.nodes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: colorScheme.primary.withOpacity(0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  '房间内暂无成员',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '当前没有其他玩家连接到房间',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        } else {
          // 如果显示拓扑图，直接返回拓扑图视图
          if (_showTopology) {
            return const NetworkTopologyView();
          }

          // 获取排序选项
          final sortOption = ServiceManager().displayState.sortOption.watch(
            context,
          );
          // 获取排序顺序
          final sortOrder = ServiceManager().displayState.sortOrder.watch(
            context,
          );
          // 获取显示模式
          final displayMode = ServiceManager().displayState.displayMode.watch(
            context,
          );
          // 获取原始节点列表
          var nodes = netStatus.nodes;

          // 根据排序选项对节点进行排序
          if (sortOption == 1) {
            // 按延迟排序
            nodes.sort((a, b) {
              int comparison = a.latencyMs.compareTo(b.latencyMs);
              return sortOrder == 0 ? comparison : -comparison;
            });
          } else if (sortOption == 2) {
            // 按用户名长度排序
            nodes.sort((a, b) {
              int comparison = a.hostname.length.compareTo(b.hostname.length);
              return sortOrder == 0 ? comparison : -comparison;
            });
          }
          // 如果sortOption为0，则不排序

          // 根据显示模式过滤节点
          List<KVNodeInfo> filteredNodes = nodes;
          if (displayMode == 1) {
            // 仅显示用户（排除服务器）
            filteredNodes =
                nodes
                    .where((node) => !node.hostname.startsWith('PublicServer_'))
                    .toList();
          } else if (displayMode == 2) {
            // 仅显示服务器
            filteredNodes =
                nodes
                    .where((node) => node.hostname.startsWith('PublicServer_'))
                    .toList();
          }

          // 返回一个可滚动的视图
          return CustomScrollView(
            // 始终允许滚动,即使内容不足一屏
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 为网格添加内边距
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                // 使用瀑布流网格布局
                sliver: SliverMasonryGrid(
                  // 配置网格布局参数
                  gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    // 根据屏幕宽度动态计算列数
                    crossAxisCount: _getColumnCount(
                      MediaQuery.of(context).size.width,
                    ),
                  ),
                  // 设置网格项之间的间距
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                  // 配置子项构建器
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // 获取当前索引对应的玩家数据
                      final player = filteredNodes[index];
                      final userListSimple = ServiceManager()
                          .displayState
                          .userListSimple
                          .watch(context);
                      final localIPv4 = ServiceManager().networkConfigState.ipv4
                          .watch(context);
                      // 根据简单列表模式选项返回不同的卡片组件
                      return userListSimple
                          ? MiniUserCard(
                            player: player,
                            colorScheme: colorScheme,
                            localIPv4: localIPv4,
                          )
                          : AllUserCard(
                            player: player,
                            colorScheme: colorScheme,
                            localIPv4: localIPv4,
                          );
                    },
                    // 设置子项数量为过滤后的节点数量
                    childCount: filteredNodes.length,
                  ),
                ),
              ),
            ],
          );
        }
      }),
    );
  }

  // 根据宽度计算列数
  int _getColumnCount(double width) {
    if (width >= 1200) {
      return 3;
    } else if (width >= 900) {
      return 2;
    }
    return 1; // 窄屏使用单列
  }
}

// 新建 StatefulWidget 来管理列表项的悬停状态
class PlayerListItem extends StatefulWidget {
  final KVNodeInfo player;
  final ColorScheme colorScheme;
  final String? localIPv4; // 需要传入本地 IP
  // 将辅助函数作为参数传递，或者定义为顶层/静态函数
  final Color Function(double) getLatencyColor;
  final IconData Function(String) getConnectionIcon;
  final String Function(int, String, String?) mapConnectionType;
  final Widget Function(KVNodeInfo, ColorScheme, Color, IconData, String?)
  buildDesktopPlayerListItem; // 传递构建函数

  const PlayerListItem({
    required Key key,
    required this.player,
    required this.colorScheme,
    required this.localIPv4,
    required this.getLatencyColor,
    required this.getConnectionIcon,
    required this.mapConnectionType,
    required this.buildDesktopPlayerListItem,
  }) : super(key: key);

  @override
  State<PlayerListItem> createState() => _PlayerListItemState();
}

class _PlayerListItemState extends State<PlayerListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // 从 widget 属性获取数据和函数
    final player = widget.player;
    final colorScheme = widget.colorScheme;
    final localIPv4 = widget.localIPv4;

    // 调用传递进来的辅助函数
    final latencyColor = widget.getLatencyColor(player.latencyMs);
    final connectionType = widget.mapConnectionType(
      player.cost,
      player.ipv4,
      localIPv4,
    );
    final connectionIcon = widget.getConnectionIcon(connectionType);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: _isHovered ? colorScheme.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            // 如果需要 onTap 功能，在这里实现
          },
          splashColor: colorScheme.primary.withOpacity(0.3),
          highlightColor: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            // 调用传递进来的桌面布局构建函数
            child: widget.buildDesktopPlayerListItem(
              player,
              colorScheme,
              latencyColor,
              connectionIcon,
              localIPv4, // 可能需要传递 localIPv4 给 desktop builder
            ),
          ),
        ),
      ),
    );
  }
}
