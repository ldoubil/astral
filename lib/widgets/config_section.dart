import 'package:flutter/material.dart';

/// 配置区域组件
/// 用于统一配置页面的分组样式，包含标题和内容卡片
class ConfigSection extends StatelessWidget {
  /// 区域标题
  final String title;
  
  /// 区域内容组件列表
  final List<Widget> children;
  
  /// 标题颜色（可选，默认使用主题色）
  final Color? titleColor;

  const ConfigSection({
    super.key,
    required this.title,
    required this.children,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: titleColor ?? Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}