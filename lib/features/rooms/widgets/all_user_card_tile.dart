import 'package:astral/src/rust/api/simple.dart';
import 'package:astral/features/rooms/widgets/all_user_card_body.dart';
import 'package:astral/features/rooms/widgets/all_user_card_nat.dart';
import 'package:astral/features/rooms/widgets/peer_connection_style.dart';
import 'package:flutter/material.dart';

/// Desktop list-item body for [AllUserCard].
class AllUserCardTile extends StatelessWidget {
  final KVNodeInfo player;
  final ColorScheme colorScheme;
  final String localIPv4;

  const AllUserCardTile({
    super.key,
    required this.player,
    required this.colorScheme,
    required this.localIPv4,
  });

  @override
  Widget build(BuildContext context) {
    String displayName =
        player.hostname.startsWith('PublicServer_')
            ? player.hostname.substring('PublicServer_'.length)
            : player.hostname;

    final latencyColor = PeerConnectionStyle.getLatencyColor(player.latencyMs);
    final connectionType = PeerConnectionStyle.mapConnectionType(
      player.cost,
      player.ipv4,
      localIPv4,
    );
    final connectionIcon = PeerConnectionStyle.getConnectionIcon(connectionType);
    final connectionTypeColor = PeerConnectionStyle.getConnectionTypeColor(
      connectionType,
      colorScheme,
    );
    final natTypeString = AllUserCardNat.mapNatType(player.nat);
    final natTypeColor = AllUserCardNat.getNatTypeColor(natTypeString);
    final natTypeIcon = AllUserCardNat.getNatTypeIcon(natTypeString);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Header Section (Name, Connection Type, Latency, Loss) ---
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.person, color: colorScheme.primary, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Tooltip(
                      message: displayName, // Show full name on hover
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: null, // 金色高亮
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          // 移除 Chip 标签
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16), // Spacing
            // Network Status Icons/Badges (Right Aligned)
            Wrap(
              spacing: 12.0,
              runSpacing: 4.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.end,
              children: [
                // Connection Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: connectionTypeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(connectionIcon, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        connectionType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // 只有不是本机时才显示延迟和丢包
                if (connectionType != '本机') ...[
                  // Latency
                  Tooltip(
                    message: "延迟",
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 18,
                          color: latencyColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${player.latencyMs.toStringAsFixed(0)} ms', // No decimal for ms
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: latencyColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Packet Loss
                  Tooltip(
                    message: "丢包率",
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 18,
                          color: PeerConnectionStyle.getPacketLossColor(
                            player.lossRate,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${player.lossRate.toStringAsFixed(1)}%', // One decimal place
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: PeerConnectionStyle.getPacketLossColor(
                              player.lossRate,
                            ),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 12),

        // Network Connection Stats Section
        AllUserCardBody.buildConnectionStatsSection(player, colorScheme),

        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),

        // --- Other Details Section ---
        AllUserCardBody.buildDetailsSection(
          context: context,
          player: player,
          colorScheme: colorScheme,
          natTypeString: natTypeString,
          natTypeColor: natTypeColor,
          natTypeIcon: natTypeIcon,
        ),
      ],
    );
  }
}
