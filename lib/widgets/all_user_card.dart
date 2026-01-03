import 'package:astral/k/services/service_manager.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:astral/utils/platform_version_parser.dart';
import 'package:astral/utils/blocked_servers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 将列表项卡片抽取为独立的StatefulWidget
class AllUserCard extends StatefulWidget {
  final KVNodeInfo player;
  final ColorScheme colorScheme;
  final String? localIPv4;

  const AllUserCard({
    super.key,
    required this.player,
    required this.colorScheme,
    required this.localIPv4,
  });

  @override
  State<AllUserCard> createState() => _AllUserCardState();
}

class _AllUserCardState extends State<AllUserCard> {
  bool isHovered = false;

  // 为桌面设备优化的列表项布局
  Widget _buildDesktopPlayerListItem(
    KVNodeInfo player,
    ColorScheme colorScheme,
    Color latencyColor,
    IconData connectionIcon,
  ) {
    String displayName =
        player.hostname.startsWith('PublicServer_')
            ? player.hostname.substring('PublicServer_'.length)
            : player.hostname;

    // 使用提取后的方法
    latencyColor = _getLatencyColor(player.latencyMs);
    // Pre-calculate connection type string and color
    final connectionType = _mapConnectionType(
      player.cost,
      player.ipv4,
      ServiceManager().networkConfigState.ipv4.value, // Assuming ServiceManager().networkConfigState.ipv4 provides the local IP
    );
    final connectionTypeColor = _getConnectionTypeColor(
      connectionType,
      colorScheme,
    );
    final natTypeString = _mapNatType(player.nat);
    final natTypeColor = _getNatTypeColor(natTypeString);
    final natTypeIcon = _getNatTypeIcon(natTypeString);

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
                          color: _getPacketLossColor(player.lossRate),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${player.lossRate.toStringAsFixed(1)}%', // One decimal place
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getPacketLossColor(player.lossRate),
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
        if (player.connections.isEmpty)
          Center(
            child: Text(
              '无连接数据',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          )
        else
          Column(
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
                child: _buildConnectionStats(
                  // Always display the first connection
                  player.connections[0],
                  colorScheme,
                ),
              ),
            ],
          ),

        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),

        // --- Other Details Section ---
        if (player.ipv4 != '' && player.ipv4 != "0.0.0.0")
          _buildInfoRow(
            Icons.lan_outlined,
            'IP地址',
            player.ipv4,
            colorScheme,
            showCopyButton: true,
          ),
        const SizedBox(height: 8),

        _buildInfoRow(
          PlatformVersionParser.getPlatformIcon(player.version),
          'ET版本',
          PlatformVersionParser.getVersionNumber(player.version),
          colorScheme,
        ),
        const SizedBox(height: 8),

        _buildInfoRow(
          natTypeIcon,
          'NAT类型',
          natTypeString,
          colorScheme,
          valueColor: natTypeColor,
        ),
        if (player.tunnelProto != '') ...[
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.router,
            '隧道类型',
            _formatTunnelProto(player.tunnelProto),
            colorScheme,
          ),
        ],

        // Connection Path / Hops
        if (player.hops.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildHopsInfo(player.hops, colorScheme),
        ],
      ],
    );
  }

  // Helper widget to build the stats for a single connection
  Widget _buildConnectionStats(
    KVNodeConnectionStats connection,
    ColorScheme colorScheme,
  ) {
    final double uploadSpeedKB = connection.txBytes.toDouble();
    final double downloadSpeedKB = connection.rxBytes.toDouble();
    final double sentPackets = connection.txPackets.toDouble();
    final double receivedPackets = connection.rxPackets.toDouble();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatItem(
                Icons.upload_rounded,
                '累计上传',
                _formatSpeed(uploadSpeedKB),
                colorScheme.primary,
                colorScheme,
              ),
              const SizedBox(height: 10),
              _buildStatItem(
                Icons.arrow_upward_rounded,
                '累计发送包',
                '$sentPackets',
                colorScheme.primary,
                colorScheme,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatItem(
                Icons.download_rounded,
                '累计下载',
                _formatSpeed(downloadSpeedKB),
                colorScheme.secondary,
                colorScheme,
              ),
              const SizedBox(height: 10),
              _buildStatItem(
                Icons.arrow_downward_rounded,
                '累计接收包',
                '$receivedPackets',
                colorScheme.secondary,
                colorScheme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper for individual stat items in the Network section
  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
    dynamic colorScheme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Prevent row from taking full width
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.7),
              ), // Subdued label color
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 添加一个速度单位转换的辅助方法
  String _formatSpeed(double speedInB) {
    final units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double value = speedInB;
    int unitIndex = 0;

    // 循环处理单位转换
    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }

    // 格式化数值显示（整数部分不带小数，小数部分保留两位）
    final formattedValue =
        value % 1 == 0
            ? value.toInt().toString()
            : value.toStringAsFixed(2).replaceFirst(RegExp(r'.0+$'), '');

    return '$formattedValue${units[unitIndex]}';
  }

  // 构建信息行
  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme, {
    Color? valueColor,
    bool showCopyButton = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        // 添加复制按钮到标签和值之间
        if (showCopyButton)
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: '复制$label',
            onPressed: () {
              // 复制到剪贴板
              Clipboard.setData(ClipboardData(text: value));
              // 显示提示
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('已复制IP地址: $value'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // 根据连接类型获取颜色
  Color _getConnectionTypeColor(
    String connectionType,
    ColorScheme colorScheme,
  ) {
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

  // 格式化隧道协议显示
  String _formatTunnelProto(String proto) {
    // 分割多个协议（逗号分隔）
    return proto
        .split(',')
        .map((p) {
          final trimmed = p.trim();
          // 使用正则匹配：如果是纯tcp或udp（后面不跟数字），添加4
          if (RegExp(r'^tcp$').hasMatch(trimmed)) return 'tcp4';
          if (RegExp(r'^udp$').hasMatch(trimmed)) return 'udp4';
          return trimmed; // tcp6, udp6等保持原样
        })
        .join(',');
  }

  // 将NAT类型转换为中文
  String _mapNatType(String natType) {
    switch (natType) {
      case 'Unknown':
        return '未知';
      case 'OpenInternet':
        return '开放网络';
      case 'NoPat':
        return '无PAT';
      case 'FullCone':
        return '全锥形';
      case 'Restricted':
        return '受限锥形';
      case 'PortRestricted':
        return '端口受限锥形';
      case 'Symmetric':
        return '对称型';
      case 'SymUdpFirewall':
        return '对称UDP防火墙';
      case 'SymmetricEasyInc':
        return '对称递增型';
      case 'SymmetricEasyDec':
        return '对称递减型';
      default:
        return '未知';
    }
  }

  // 根据NAT类型获取图标
  IconData _getNatTypeIcon(String natType) {
    if (natType.contains('开放') || natType.contains('全锥形')) {
      return Icons.public;
    } else if (natType.contains('受限')) {
      return Icons.shield;
    } else if (natType.contains('端口受限')) {
      return Icons.security;
    } else if (natType.contains('对称')) {
      return Icons.sync_alt;
    } else if (natType.contains('防火墙')) {
      return Icons.fireplace;
    } else if (natType.contains('递增')) {
      return Icons.trending_up;
    } else if (natType.contains('递减')) {
      return Icons.trending_down;
    } else if (natType.contains('无PAT')) {
      return Icons.router;
    } else {
      return Icons.help_outline;
    }
  }

  // 根据NAT类型获取颜色
  Color _getNatTypeColor(String natType) {
    if (natType.contains('开放') ||
        natType.contains('全锥形') ||
        natType.contains('无PAT')) {
      return Colors.green;
    } else if (natType.contains('受限') || natType.contains('端口受限')) {
      return Colors.orange;
    } else if (natType.contains('对称') || natType.contains('防火墙')) {
      return Colors.red;
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

  // 根据连接类型获取图标
  IconData _getConnectionIcon(String connectionType) {
    // 将连接类型转为小写并进行匹配
    String lowerType = connectionType.toLowerCase();
    // 新增服务器图标
    if (lowerType.contains('server') || lowerType.contains('服务器')) {
      return Icons.dns;
    } else if (lowerType.contains('p2p') || lowerType.contains('直链')) {
      return Icons.link;
    } else if (lowerType.contains('relay') || lowerType.contains('中转')) {
      return Icons.swap_horiz;
    } else if (lowerType.contains('direct') || lowerType.contains('本机')) {
      return Icons.computer;
    } else {
      return Icons.device_unknown;
    }
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

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isHovered ? widget.colorScheme.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            // 复制IP地址到剪贴板
            Clipboard.setData(ClipboardData(text: widget.player.ipv4));
            // 显示复制成功提示
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('已复制IP: ${widget.player.ipv4}'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          splashColor: widget.colorScheme.primary.withOpacity(0.3),
          highlightColor: widget.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.all(12),
            width: double.infinity,
            child: _buildDesktopPlayerListItem(
              widget.player,
              widget.colorScheme,
              _getLatencyColor(widget.player.latencyMs),
              _getConnectionIcon(
                _mapConnectionType(
                  widget.player.cost,
                  widget.player.ipv4,
                  ServiceManager().networkConfigState.ipv4.value,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 构建跃点信息显示
Widget _buildHopsInfo(List<NodeHopStats> hops, ColorScheme colorScheme) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(Icons.route, size: 20, color: colorScheme.primary),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('连接路径:', style: TextStyle(fontWeight: FontWeight.bold)),
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
