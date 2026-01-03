import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Settings 页面基类
/// 提供统一的UI结构和常用功能
abstract class BaseSettingsPage extends StatelessWidget {
  const BaseSettingsPage({super.key});

  /// 页面标题
  String get title;

  /// AppBar的actions（可选）
  List<Widget>? buildActions(BuildContext context) => null;

  /// 是否显示返回按钮
  bool get showBackButton => true;

  /// 是否使用Watch包装（响应式更新）
  bool get useWatch => true;

  /// 构建页面内容
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        automaticallyImplyLeading: showBackButton,
        actions: buildActions(context),
      ),
      body:
          useWatch
              ? Watch((context) => buildContent(context))
              : buildContent(context),
    );
  }

  /// 构建设置卡片
  Widget buildSettingsCard({
    required BuildContext context,
    required List<Widget> children,
    String? header,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              header,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        Card(child: Column(children: children)),
      ],
    );
  }

  /// 构建分隔线
  Widget buildDivider() => const Divider(height: 1);

  /// 构建空状态
  Widget buildEmptyState({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
            ),
          ],
        ],
      ),
    );
  }
}

/// Stateful Settings 页面基类
abstract class BaseStatefulSettingsPage extends StatefulWidget {
  const BaseStatefulSettingsPage({super.key});

  @override
  BaseStatefulSettingsPageState createState();
}

abstract class BaseStatefulSettingsPageState<T extends BaseStatefulSettingsPage>
    extends State<T> {
  /// 页面标题
  String get title;

  /// AppBar的actions（可选）
  List<Widget>? buildActions(BuildContext context) => null;

  /// FloatingActionButton（可选）
  Widget? buildFloatingActionButton(BuildContext context) => null;

  /// 是否显示返回按钮
  bool get showBackButton => true;

  /// 是否使用Watch包装
  bool get useWatch => true;

  /// 构建页面内容
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        automaticallyImplyLeading: showBackButton,
        actions: buildActions(context),
      ),
      body:
          useWatch
              ? Watch((context) => buildContent(context))
              : buildContent(context),
      floatingActionButton: buildFloatingActionButton(context),
    );
  }

  /// 构建设置卡片
  Widget buildSettingsCard({
    required BuildContext context,
    required List<Widget> children,
    String? header,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              header,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget buildDivider() => const Divider(height: 1);

  Widget buildEmptyState({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
            ),
          ],
        ],
      ),
    );
  }
}
