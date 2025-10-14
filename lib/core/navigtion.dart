import 'package:flutter/material.dart';

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget page;

  const NavigationItem({
    required this.icon,
    IconData? activeIcon,
    required this.label,
    required this.page,
  }) : activeIcon = activeIcon ?? icon;
}
