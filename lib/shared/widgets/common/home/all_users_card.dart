import 'package:astral/core/services/service_manager.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:astral/shared/widgets/cards/all_user_card.dart';
import 'package:astral/shared/widgets/cards/mini_user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:signals_flutter/signals_flutter.dart';

class AllUsersCard extends StatelessWidget {
  const AllUsersCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Watch((context) {
      final netStatus = ServiceManager().connectionState.netStatus.watch(
        context,
      );
      final isConnecting = ServiceManager().connectionState.isConnecting.watch(
        context,
      );

      // 未连接时显示空状态
      if (!isConnecting) {
        return Card(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: 48,
                  color: colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  '未连接',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // 无玩家时显示空状态
      if (netStatus == null || netStatus.nodes.isEmpty) {
        return Card(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 48,
                  color: colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  '房间内暂无玩家',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // 获取排序选项
      final sortOption = ServiceManager().displayState.sortOption.watch(
        context,
      );
      final sortOrder = ServiceManager().displayState.sortOrder.watch(context);

      // 过滤只显示玩家（排除服务器）
      // 排除条件：1. hostname以PublicServer_开头 2. IP为0.0.0.0（服务器特征）
      var players =
          netStatus.nodes
              .where(
                (node) =>
                    !node.hostname.startsWith('PublicServer_') &&
                    node.ipv4 != '0.0.0.0',
              )
              .toList();

      // 根据排序选项对节点进行排序
      if (sortOption == 1) {
        // 按延迟排序
        players.sort((a, b) {
          int comparison = a.latencyMs.compareTo(b.latencyMs);
          return sortOrder == 0 ? comparison : -comparison;
        });
      } else if (sortOption == 2) {
        // 按用户名长度排序
        players.sort((a, b) {
          int comparison = a.hostname.length.compareTo(b.hostname.length);
          return sortOrder == 0 ? comparison : -comparison;
        });
      }

      final userListSimple = ServiceManager().displayState.userListSimple.watch(
        context,
      );
      final localIPv4 = ServiceManager().networkConfigState.ipv4.watch(context);

      return Card(
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题行
              Row(
                children: [
                  Icon(Icons.people, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '在线玩家',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${players.length}',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 玩家列表
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  return userListSimple
                      ? MiniUserCard(
                        player: player,
                        colorScheme: colorScheme,
                        localIPv4: localIPv4,
                      )
                      : Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AllUserCard(
                          player: player,
                          colorScheme: colorScheme,
                          localIPv4: localIPv4,
                        ),
                      );
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
