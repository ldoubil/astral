import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/states/connection_state.dart';
import 'package:astral/core/states/display_state.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:astral/shared/utils/network/node_utils.dart';
import 'package:astral/features/rooms/widgets/all_user_card.dart';
import 'package:astral/features/rooms/widgets/mini_user_card.dart';
import 'package:astral/features/rooms/widgets/network_topology.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:astral/features/rooms/widgets/room_settings_sheet.dart';
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
            tooltip: _showTopology ? '列表视图' : '拓扑图',
            child: Icon(_showTopology ? Icons.list : Icons.hub),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'room_settings',
            onPressed: () => RoomSettingsSheet.show(context),
            tooltip: '房间设置',
            child: const Icon(Icons.bar_chart),
          ),
        ],
      ),
      body: Watch((context) {
        final netStatus = ServiceManager().connectionState.netStatus.watch(
          context,
        );
        final connectionState = ServiceManager()
            .connectionState
            .connectionState
            .watch(context);
        final reduceAnimationUpdates = ServiceManager()
            .appSettingsState
            .reduceAnimationUpdates
            .watch(context);
        final isInBackground = ServiceManager().uiState.isInBackground.watch(
          context,
        );
        if (connectionState != CoState.connected) {
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
                  color: colorScheme.primary.withValues(alpha: 0.6),
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
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        } else {
          // 如果显示拓扑图，直接返回拓扑图视图
          if (_showTopology) {
            return NetworkTopologyView(
              nodes: netStatus.nodes,
              reduceUpdates: reduceAnimationUpdates,
              isInBackground: isInBackground,
            );
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
          final userListSimple = ServiceManager().displayState.userListSimple
              .watch(context);
          final localIPv4 = ServiceManager().networkConfigState.ipv4.watch(
            context,
          );
          // 获取原始节点列表
          final nodes = List<KVNodeInfo>.from(netStatus.nodes);

          // 根据排序选项对节点进行排序
          if (sortOption == UserSortOption.latency) {
            // 按延迟排序
            nodes.sort((a, b) {
              int comparison = a.latencyMs.compareTo(b.latencyMs);
              return sortOrder == UserSortOrder.ascending
                  ? comparison
                  : -comparison;
            });
          } else if (sortOption == UserSortOption.nameLength) {
            // 按用户名长度排序
            nodes.sort((a, b) {
              int comparison = a.hostname.length.compareTo(b.hostname.length);
              return sortOrder == UserSortOrder.ascending
                  ? comparison
                  : -comparison;
            });
          }

          // 根据显示模式过滤节点
          List<KVNodeInfo> filteredNodes = nodes;
          if (displayMode == UserDisplayMode.users) {
            // 仅显示用户（排除服务器）
            filteredNodes =
                nodes.where((node) => !isServerNode(node)).toList();
          } else if (displayMode == UserDisplayMode.servers) {
            // 仅显示服务器
            filteredNodes =
                nodes.where((node) => isServerNode(node)).toList();
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
                      // 根据简单列表模式选项返回不同的卡片组件
                      return userListSimple
                          ? MiniUserCard(
                            key: ValueKey(player.peerId),
                            player: player,
                            colorScheme: colorScheme,
                            localIPv4: localIPv4,
                          )
                          : AllUserCard(
                            key: ValueKey(player.peerId),
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
