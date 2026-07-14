import 'package:flutter/material.dart';

/// 小卡：等级制 NAT 文案与颜色
class MiniUserCardNat {
  const MiniUserCardNat._();

  static String mapNatType(String natType) {
    switch (natType) {
      case 'Unknown':
        return '未知';
      case 'OpenInternet':
      case 'NoPat':
        return '传奇';
      case 'FullCone':
        return '史诗';
      case 'Restricted':
      case 'PortRestricted':
        return '优质';
      case 'Symmetric':
        return '困难';
      case 'SymUdpFirewall':
      case 'SymmetricEasyInc':
      case 'SymmetricEasyDec':
        return '普通';
      default:
        return '未知';
    }
  }

  static IconData getNatTypeIcon(String natType) {
    switch (natType) {
      case '传奇':
        return Icons.workspace_premium;
      case '史诗':
        return Icons.military_tech;
      case '优质':
        return Icons.verified;
      case '普通':
        return Icons.circle;
      case '困难':
        return Icons.block;
      default:
        return Icons.help_outline;
    }
  }

  static Color getNatTypeColor(String natType) {
    switch (natType) {
      case '传奇':
        return const Color(0xFFFF6B00);
      case '史诗':
        return const Color(0xFFA335EE);
      case '优质':
        return const Color(0xFF0070DD);
      case '普通':
        return const Color(0xFF1EFF00);
      case '困难':
        return const Color(0xFF9D9D9D);
      default:
        return Colors.grey;
    }
  }
}
