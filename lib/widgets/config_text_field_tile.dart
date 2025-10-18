import 'package:flutter/material.dart';

/// 可复用的配置文本输入组件
/// 用于统一样式的文本输入设置项
class ConfigTextFieldTile extends StatelessWidget {
  /// 文本控制器
  final TextEditingController controller;
  
  /// 标签文本
  final String labelText;
  
  /// 提示文本（可选）
  final String? hintText;
  
  /// 值改变回调
  final ValueChanged<String>? onChanged;
  
  /// 左侧图标
  final IconData icon;
  
  /// 键盘类型（可选，默认为文本）
  final TextInputType keyboardType;
  
  /// 图标颜色（可选，默认使用主题色）
  final Color? iconColor;
  
  /// 是否必填（可选，默认为false）
  final bool required;

  const ConfigTextFieldTile({
    super.key,
    required this.controller,
    required this.labelText,
    required this.icon,
    this.hintText,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.iconColor,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).colorScheme.primary,
      ),
      title: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: required 
          ? (value) {
              if (value == null || value.isEmpty) {
                return '请输入$labelText';
              }
              return null;
            }
          : null,
      ),
    );
  }
}