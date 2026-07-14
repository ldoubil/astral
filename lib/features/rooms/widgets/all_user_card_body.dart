import 'package:astral/features/rooms/widgets/peer_connection_style.dart';
import 'package:astral/features/rooms/widgets/player_card_stats.dart';
import 'package:astral/shared/utils/platform_version_parser.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:flutter/material.dart';

/// Body sections for [AllUserCardTile].
class AllUserCardBody {
  const AllUserCardBody._();

  static Widget buildConnectionStatsSection(
    KVNodeInfo player,
    ColorScheme colorScheme,
  ) {
    if (player.connections.isEmpty) {
      return Center(
        child: Text(
          '无连接数据',
          style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.wifi, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              '网络数据:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: PlayerCardStats.buildConnectionStats(
            // Always display the first connection
            player.connections[0],
            colorScheme,
          ),
        ),
      ],
    );
  }

  static Widget buildDetailsSection({
    required BuildContext context,
    required KVNodeInfo player,
    required ColorScheme colorScheme,
    required String natTypeString,
    required Color natTypeColor,
    required IconData natTypeIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (player.ipv4 != '' && player.ipv4 != "0.0.0.0")
          PlayerCardStats.buildInfoRow(
            context,
            Icons.lan_outlined,
            'IP地址',
            player.ipv4,
            colorScheme,
            showCopyButton: true,
          ),
        const SizedBox(height: 8),
        PlayerCardStats.buildInfoRow(
          context,
          PlatformVersionParser.getPlatformIcon(player.version),
          'ET版本',
          PlatformVersionParser.getVersionNumber(player.version),
          colorScheme,
        ),
        const SizedBox(height: 8),
        PlayerCardStats.buildInfoRow(
          context,
          natTypeIcon,
          'NAT类型',
          natTypeString,
          colorScheme,
          valueColor: natTypeColor,
        ),
        if (player.tunnelProto != '') ...[
          const SizedBox(height: 8),
          PlayerCardStats.buildInfoRow(
            context,
            Icons.router,
            '隧道类型',
            PeerConnectionStyle.formatTunnelProto(player.tunnelProto),
            colorScheme,
          ),
        ],
        if (player.hops.isNotEmpty) ...[
          const SizedBox(height: 8),
          buildHopsInfo(player.hops, colorScheme),
        ],
      ],
    );
  }

  static Widget buildHopsInfo(List<NodeHopStats> hops, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.route, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '连接路径:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              // 改为每行显示一个跃点
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < hops.length; i++) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${hops[i].nodeName} '
                        '(${hops[i].latencyMs.toStringAsFixed(0)}ms, '
                        '${hops[i].packetLoss.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    // 在跃点之间添加间距
                    if (i < hops.length - 1) const SizedBox(height: 4),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
