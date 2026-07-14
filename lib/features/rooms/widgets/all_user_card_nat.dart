import 'package:flutter/material.dart';

/// 大卡：技术 NAT 文案与颜色
class AllUserCardNat {
  const AllUserCardNat._();

  static String mapNatType(String natType) {
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

  static IconData getNatTypeIcon(String natType) {
    if (natType.contains('开放') || natType.contains('全锥形')) {
      return Icons.public;
    }
    if (natType.contains('端口受限')) {
      return Icons.security;
    }
    if (natType.contains('受限')) {
      return Icons.shield;
    }
    if (natType.contains('对称')) {
      return Icons.sync_alt;
    }
    if (natType.contains('防火墙')) {
      return Icons.fireplace;
    }
    if (natType.contains('递增')) {
      return Icons.trending_up;
    }
    if (natType.contains('递减')) {
      return Icons.trending_down;
    }
    if (natType.contains('无PAT')) {
      return Icons.router;
    }
    return Icons.help_outline;
  }

  static Color getNatTypeColor(String natType) {
    if (natType.contains('开放') ||
        natType.contains('全锥形') ||
        natType.contains('无PAT')) {
      return Colors.green;
    }
    if (natType.contains('受限') || natType.contains('端口受限')) {
      return Colors.orange;
    }
    if (natType.contains('对称') || natType.contains('防火墙')) {
      return Colors.red;
    }
    return Colors.grey;
  }
}
