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
    final player = widget.player;
    final colorScheme = widget.colorScheme;
    final displayName =
        player.hostname.startsWith('PublicServer_')
            ? player.hostname.substring('PublicServer_'.length)
            : player.hostname;
    final connectionType = _mapConnectionType(
      player.cost,
      player.ipv4,
      widget.localIPv4 ?? "",
    );

    final connectionTypeColor = _getConnectionTypeColor(
      connectionType,
      colorScheme,
    );
    final latencyColor = _getLatencyColor(player.latencyMs);
    final lossColor = _getPacketLossColor(player.lossRate);
    final natTypeString = _mapNatType(player.nat);
    final natTypeColor = _getNatTypeColor(natTypeString);

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
            // 显示提示
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('已复制IP地址: ${player.ipv4}'),
                duration: const Duration(seconds: 2),
              ),
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
                      Icon(Icons.timer_outlined, size: 16, color: latencyColor),
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
                // 第二行：IP地址 ET版本 NAT类型
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
                      Icons.memory_outlined,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    Text(
                      player.version,
                      style: TextStyle(
                        color: colorScheme.secondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      _getNatTypeIcon(natTypeString),
                      size: 16,
                      color: natTypeColor,
                    ),
                    Text(
                      natTypeString,
                      style: TextStyle(color: natTypeColor, fontSize: 13),
                    ),
                    if (player.tunnelProto != '') ...[
                      const SizedBox(width: 10),
                      Icon(Icons.router, size: 16, color: colorScheme.primary),
                      Text(
                        player.tunnelProto,
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

// 将NAT类型转换为中文评级显示
String _mapNatType(String natType) {
  switch (natType) {
    case 'Unknown':
      return '未知';
    case 'OpenInternet':
      return '极好';
    case 'NoPat':
      return '极好';
    case 'FullCone':
      return '优秀';
    case 'Restricted':
      return '良好';
    case 'PortRestricted':
      return '良好';
    case 'Symmetric':
      return '极差';
    case 'SymUdpFirewall':
      return '差';
    case 'SymmetricEasyInc':
      return '差';
    case 'SymmetricEasyDec':
      return '差';
    default:
      return '未知';
  }
}

// 根据NAT类型获取图标
IconData _getNatTypeIcon(String natType) {
  switch (natType) {
    case '极好':
      return Icons.star;
    case '优秀':
      return Icons.public;
    case '良好':
      return Icons.shield;
    case '差':
      return Icons.warning;
    case '极差':
      return Icons.sync_alt;
    default:
      return Icons.help_outline;
  }
}

// 根据NAT类型获取颜色
Color _getNatTypeColor(String natType) {
  switch (natType) {
    case '极好':
      return Colors.purple;
    case '优秀':
      return Colors.green;
    case '良好':
      return Colors.lightGreen;
    case '差':
      return Colors.orange;
    case '极差':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

// 根据连接类型获取颜色
Color _getConnectionTypeColor(String connectionType, ColorScheme colorScheme) {
  // 将连接类型转为小写并进行匹配
  String lowerType = connectionType.toLowerCase();
  if (lowerType.contains('server') || lowerType.contains('服务器')) {
    return Colors.deepPurple;
  } else if (lowerType.contains('p2p') || lowerType.contains('直链')) {
    return Colors.green;
  } else if (lowerType.contains('relay') || lowerType.contains('中转')) {
    return Colors.orange;
  } else if (lowerType.contains('direct') || lowerType.contains('本机')) {
    return colorScheme.primary;
  } else {
    return Colors.grey;
  }
}

// 如果传入数值=1就是p2p 否则是relay 最后判断是不是等于本机IP如果等于就是direct 本机ip传入
String _mapConnectionType(int connType, String ip, String thisip) {
  // 新增服务器IP判断
  if (ip == "0.0.0.0") {
    return '服务器';
  }
  // 如果是本机IP，返回direct
  if (thisip != null && ip == thisip) {
    // 检查 thisip 是否为 null
    return '本机';
  }
  // 根据连接成本判断连接类型
  if (connType == 1) {
    return '直链';
  } else if (connType >= 2) {
    return '中转';
  }
  return '未知';
}

// 根据延迟值获取颜色
Color _getLatencyColor(double latency) {
  if (latency < 50) {
    return Colors.green;
  } else if (latency < 100) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}

// 根据丢包率获取颜色
Color _getPacketLossColor(double lossRate) {
  if (lossRate < 1.0) {
    return Colors.green;
  } else if (lossRate < 5.0) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}
