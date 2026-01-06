import 'dart:io';
import 'package:astral/features/nat_test/pages/nat_test_page.dart';
import 'package:astral/core/database/app_data.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

/// 游戏服务器项目数据模型
class GameItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const GameItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

/// 探索页面 - 用于服务器分享
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle(context, '联机工具'),
                const SizedBox(height: 12),
                // 魔法墙已移至后台自动运行，无需UI配置
                _buildListTile(
                  context,
                  GameItem(
                    title: 'NAT 类型测试',
                    subtitle: '检测您的网络 NAT 类型',
                    icon: Icons.network_check,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NatTestPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _buildListTile(
                  context,
                  GameItem(
                    title: 'Minecraft局域网修复',
                    subtitle: '..... 开发中 .....',
                    icon: Icons.group,
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 32),

                // 数据管理部分 - 临时禁用
                // _buildSectionTitle(context, '数据管理'),
                // const SizedBox(height: 12),
                // _buildListTile(
                //   context,
                //   GameItem(
                //     title: '导出配置',
                //     subtitle: '导出所有配置数据到文件',
                //     icon: Icons.upload_file,
                //     onTap: _exportDatabase,
                //   ),
                // ),
                // const SizedBox(height: 8),
                // _buildListTile(
                //   context,
                //   GameItem(
                //     title: '导入配置',
                //     subtitle: '从文件导入配置数据',
                //     icon: Icons.download,
                //     onTap: _importDatabase,
                //   ),
                // ),
                // const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  // 导出数据库
  Future<void> _exportDatabase() async {
    try {
      // 获取导出路径
      String? exportPath;

      if (Platform.isAndroid) {
        // Android 使用下载目录
        final directory = await getExternalStorageDirectory();
        exportPath = directory?.path;
      } else {
        // 其他平台使用文件选择器选择目录
        exportPath = await FilePicker.platform.getDirectoryPath(
          dialogTitle: '选择导出路径',
        );
      }

      if (exportPath == null) return;

      // 显示加载对话框
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );
      }

      // 执行导出
      final filePath = await AppDatabase().exportDatabase(exportPath);

      // 关闭加载对话框
      if (mounted) Navigator.of(context).pop();

      // 显示成功消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出成功: $filePath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // 关闭加载对话框
      if (mounted) Navigator.of(context).pop();

      // 显示错误消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 导入数据库
  Future<void> _importDatabase() async {
    try {
      // 选择导入文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['isar'],
        dialogTitle: '选择导入文件',
      );

      if (result == null || result.files.single.path == null) return;

      final filePath = result.files.single.path!;

      // 显示确认对话框
      if (mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('确认导入'),
                content: const Text('导入配置将替换当前所有数据，是否继续？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('确认'),
                  ),
                ],
              ),
        );

        if (confirmed != true) return;
      }

      // 显示加载对话框
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );
      }

      // 执行导入（会自动调用 ServiceManager.reload()）
      await AppDatabase().importDatabase(filePath);

      // 关闭加载对话框
      if (mounted) Navigator.of(context).pop();

      // 显示成功消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('导入成功，配置已刷新'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // 关闭加载对话框
      if (mounted) Navigator.of(context).pop();

      // 显示错误消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildListTile(BuildContext context, GameItem item) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Icon(
          item.icon,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          item.title,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          item.subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: item.onTap,
      ),
    );
  }
}
