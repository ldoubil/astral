import 'package:flutter/material.dart';

/// 可复用的配置开关组件
/// 用于统一样式的开关设置项
class ConfigSwitchTile extends StatelessWidget {
  /// 标题文本
  final String title;
  
  /// 开关状态
  final bool value;
  
  /// 状态改变回调
  final ValueChanged<bool> onChanged;
  
  /// 左侧图标
  final IconData icon;
  
  /// 副标题文本（可选）
  final String? subtitle;
  
  /// 图标颜色（可选，默认使用主题色）
  final Color? iconColor;

  const ConfigSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.icon,
    this.subtitle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      value: value,
      onChanged: onChanged,
      secondary: Icon(
        icon,
        color: iconColor ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}