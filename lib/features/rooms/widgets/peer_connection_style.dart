import 'package:flutter/material.dart';

/// 节点连接展示共用样式（All / Mini 用户卡共用）
class PeerConnectionStyle {
  const PeerConnectionStyle._();

  static String formatTunnelProto(String proto) {
    return proto
        .split(',')
        .map((p) {
          final trimmed = p.trim();
          if (RegExp(r'^tcp$').hasMatch(trimmed)) return 'tcp4';
          if (RegExp(r'^udp$').hasMatch(trimmed)) return 'udp4';
          return trimmed;
        })
        .join(',');
  }

  static Color getConnectionTypeColor(
    String connectionType,
    ColorScheme colorScheme,
  ) {
    final lowerType = connectionType.toLowerCase();
    if (lowerType.contains('server') || lowerType.contains('服务器')) {
      return Colors.deepPurple;
    }
    if (lowerType.contains('p2p') || lowerType.contains('直链')) {
      return Colors.green;
    }
    if (lowerType.contains('relay') || lowerType.contains('中转')) {
      return Colors.orange;
    }
    if (lowerType.contains('direct') || lowerType.contains('本机')) {
      return colorScheme.primary;
    }
    return Colors.grey;
  }

  static String mapConnectionType(int connType, String ip, String thisip) {
    if (ip == '0.0.0.0') return '服务器';
    if (thisip.isNotEmpty && ip == thisip) return '本机';
    if (connType == 1) return '直链';
    if (connType >= 2) return '中转';
    return '未知';
  }

  static IconData getConnectionIcon(String connectionType) {
    final lowerType = connectionType.toLowerCase();
    if (lowerType.contains('server') || lowerType.contains('服务器')) {
      return Icons.dns;
    }
    if (lowerType.contains('p2p') || lowerType.contains('直链')) {
      return Icons.link;
    }
    if (lowerType.contains('relay') || lowerType.contains('中转')) {
      return Icons.swap_horiz;
    }
    if (lowerType.contains('direct') || lowerType.contains('本机')) {
      return Icons.computer;
    }
    return Icons.device_unknown;
  }

  static Color getLatencyColor(double latency) {
    if (latency < 50) return Colors.green;
    if (latency < 100) return Colors.orange;
    return Colors.red;
  }

  static Color getPacketLossColor(double lossRate) {
    if (lossRate < 1.0) return Colors.green;
    if (lossRate < 5.0) return Colors.orange;
    return Colors.red;
  }
}
