import 'package:astral/core/services/service_manager.dart';
import 'package:astral/shared/widgets/cards/all_user_card.dart';
import 'package:astral/shared/widgets/cards/mini_user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:signals_flutter/signals_flutter.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // 使用 Riverpod 监听节点数据
    return Scaffold(
      // 房间设置按钮已移除（固定房间列表）
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
          // 获取排序选项
          final sortOption = ServiceManager().displayState.sortOption.watch(
            context,
          );
          // 获取排序顺序
          final sortOrder = ServiceManager().displayState.sortOrder.watch(
            context,
          );
          // 获取原始节点列表并固定过滤只显示玩家（排除服务器）
          var nodes =
              netStatus.nodes
                  .where((node) => !node.hostname.startsWith('PublicServer_'))
                  .toList();

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
                      final player = nodes[index];
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
                    childCount: nodes.length,
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
