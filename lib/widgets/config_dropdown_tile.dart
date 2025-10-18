import 'package:flutter/material.dart';

/// 下拉选择项数据模型
class DropdownOption<T> {
  final T value;
  final String label;
  
  const DropdownOption({
    required this.value,
    required this.label,
  });
}

/// 可复用的配置下拉选择组件
/// 用于统一样式的下拉选择设置项
class ConfigDropdownTile<T> extends StatelessWidget {
  /// 标题文本
  final String title;
  
  /// 副标题文本（可选）
  final String? subtitle;
  
  /// 当前选中的值
  final T value;
  
  /// 下拉选项列表
  final List<DropdownOption<T>> options;
  
  /// 值改变回调
  final ValueChanged<T?> onChanged;
  
  /// 左侧图标
  final IconData icon;
  
  /// 图标颜色（可选，默认使用主题色）
  final Color? iconColor;

  const ConfigDropdownTile({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.icon,
    this.subtitle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: DropdownButton<T>(
            value: value,
            items: options.map((option) {
              return DropdownMenuItem<T>(
                value: option.value,
                child: Text(
                  option.label,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}