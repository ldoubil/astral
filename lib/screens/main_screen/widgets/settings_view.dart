import 'package:flutter/material.dart';

/// 设置页面组件
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '设置',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // 这里可以添加具体的设置选项
          Text(
            '设置选项',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          // 占位内容，后续可以添加具体的设置项
          Expanded(
            child: Center(
              child: Text(
                '设置页面内容',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

