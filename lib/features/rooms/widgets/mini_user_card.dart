import 'package:astral/features/rooms/widgets/mini_user_card_nat.dart';
import 'package:astral/features/rooms/widgets/peer_connection_style.dart';
import 'package:astral/core/ui/app_snack_bars.dart';
import 'package:astral/shared/utils/platform_version_parser.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 将列表项卡片抽取为独立的StatefulWidget
class MiniUserCard extends StatefulWidget {
  final KVNodeInfo player;
  final ColorScheme colorScheme;
  final String? localIPv4;

  const MiniUserCard({
    super.key,
    required this.player,
    required this.colorScheme,
    required this.localIPv4,
  });

  @override
  State<MiniUserCard> createState() => _MiniUserCardState();
}

class _MiniUserCardState extends State<MiniUserCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final localIPv4 = widget.localIPv4 ?? '';
    final player = widget.player;
    final colorScheme = widget.colorScheme;
    final displayName =
        player.hostname.startsWith('PublicServer_')
            ? player.hostname.substring('PublicServer_'.length)
            : player.hostname;
    final connectionType = PeerConnectionStyle.mapConnectionType(
      player.cost,
      player.ipv4,
      localIPv4,
    );
    final connectionTypeColor = PeerConnectionStyle.getConnectionTypeColor(
      connectionType,
      colorScheme,
    );
    final latencyColor = PeerConnectionStyle.getLatencyColor(player.latencyMs);
    final lossColor = PeerConnectionStyle.getPacketLossColor(player.lossRate);
    final natDifficulty = MiniUserCardNat.mapNatType(player.nat);
    final natDifficultyColor = MiniUserCardNat.getNatTypeColor(natDifficulty);
    final natDifficultyIcon = MiniUserCardNat.getNatTypeIcon(natDifficulty);

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isHovered ? colorScheme.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            // 复制IP地址到剪贴板
            Clipboard.setData(ClipboardData(text: player.ipv4));
            AppSnackBars.success(
              context,
              '已复制',
              'IP地址: ${player.ipv4}',
              duration: const Duration(seconds: 2),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 第一行：名称 类型 延迟 丢包
                Row(
                  children: [
                    Icon(Icons.person, color: colorScheme.primary, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Tooltip(
                        message: displayName,
                        child: Text(
                          displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: null, // Plus用户高亮
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: connectionTypeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        connectionType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // 只有不是本机时才显示延迟和丢包
                    if (connectionType != '本机') ...[
                      const SizedBox(width: 10),
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: latencyColor,
                      ),
                      Text(
                        '${player.latencyMs.toStringAsFixed(0)}ms',
                        style: TextStyle(
                          color: latencyColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.error_outline, size: 16, color: lossColor),
                      Text(
                        '${player.lossRate.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: lossColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                // 第二行：IP地址 ET版本 打洞难易
                Row(
                  children: [
                    if (player.ipv4 != '' && player.ipv4 != "0.0.0.0")
                      Icon(
                        Icons.lan_outlined,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Tooltip(
                        message: player.ipv4,
                        child: Text(
                          (player.ipv4 != '' && player.ipv4 != "0.0.0.0")
                              ? player.ipv4
                              : "",
                          style: TextStyle(
                            color: colorScheme.secondary,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      PlatformVersionParser.getPlatformIcon(player.version),
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    Text(
                      PlatformVersionParser.getVersionNumber(player.version),
                      style: TextStyle(
                        color: colorScheme.secondary,
                        fontSize: 13,
                      ),
                    ),
                    if (connectionType != '本机' && player.nat.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Icon(
                        natDifficultyIcon,
                        size: 16,
                        color: natDifficultyColor,
                      ),
                      Text(
                        natDifficulty,
                        style: TextStyle(
                          color: natDifficultyColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    if (player.tunnelProto != '') ...[
                      const SizedBox(width: 10),
                      Icon(
                        Icons.router,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      Text(
                        PeerConnectionStyle.formatTunnelProto(
                          player.tunnelProto,
                        ),
                        style: TextStyle(
                          color: colorScheme.secondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
