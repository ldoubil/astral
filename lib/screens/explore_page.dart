import 'package:flutter/material.dart';
import 'package:astral/widgets/minecraft_server_card.dart';

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
                _buildSectionTitle(context, '服务器分享'),
                const SizedBox(height: 12),
                MinecraftServerCard(
                  host: '43.248.189.79',
                  port: 25565,
                  onConnect: () {
                    // TODO: 实现连接服务器功能
                  },
                ),
                const SizedBox(height: 32),

                _buildSectionTitle(context, '快速操作'),
                const SizedBox(height: 12),
                _buildListTile(
                  context,
                  GameItem(
                    title: '社群分享',
                    subtitle: '在社区中分享服务器',
                    icon: Icons.group,
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 32),
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
