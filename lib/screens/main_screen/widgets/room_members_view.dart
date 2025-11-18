import 'package:astral/models/user_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 房间成员视图组件
class RoomMembersView extends StatelessWidget {
  const RoomMembersView({
    super.key,
    required this.users,
    required this.onInvite,
    required this.onLeave,
    required this.roomName,
  });

  final List<UserInfo> users;
  final VoidCallback onInvite;
  final VoidCallback onLeave;
  final String roomName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 房间名一行
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            '$roomName · ${users.length} 人在线',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // 邀请成员和退出房间按钮一行
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onInvite,
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: const Text('邀请成员'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onLeave,
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('退出房间'),
                ),
              ),
            ],
          ),
        ),
        // 成员列表
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final user = users[index];
              return _UserCard(user: user, theme: theme);
            },
          ),
        ),
      ],
    );
  }
}

/// 用户卡片组件
class _UserCard extends StatelessWidget {
  const _UserCard({required this.user, required this.theme});

  final UserInfo user;
  final ThemeData theme;
  static const double _deviceIconSize = 16;
  static final Map<String, ImageProvider> _avatarCache = {};

  /// 复制IP地址到剪贴板
  void _copyIpAddress(BuildContext context, String ip) {
    Clipboard.setData(ClipboardData(text: ip));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已复制 IP: $ip'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// 获取延迟颜色
  Color _getLatencyColor(int latency) {
    if (latency <= 40) {
      return Colors.green;
    } else if (latency <= 80) {
      return Colors.orange;
    } else {
      return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final latencyColor = _getLatencyColor(user.latency);

    return InkWell(
      onTap: () => _copyIpAddress(context, user.ip),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 10),
            // 延迟（缩小，无边框）
            Text(
              '${user.latency}ms',
              style: theme.textTheme.bodySmall?.copyWith(
                color: latencyColor,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 8),
            // 用户名（缩小）
            Expanded(
              child: Text(
                user.name,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 设备标签（图标）
            if (user.device.isNotEmpty) ...[
              const SizedBox(width: 8),
              _buildDeviceIndicator(),
            ],
            const SizedBox(width: 8),
            // IP地址
            Text(
              user.ip,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建设备指示器（使用不同平台图标）
  Widget _buildDeviceIndicator() {
    final device = user.device.toLowerCase();
    IconData? iconData;
    String tooltip = user.device;

    if (device.contains('android')) {
      iconData = Icons.android_rounded;
      tooltip = 'Android';
    } else if (device.contains('ios') || device.contains('iphone')) {
      iconData = Icons.phone_iphone_rounded;
      tooltip = 'iOS';
    } else if (device.contains('windows')) {
      iconData = Icons.window_rounded;
      tooltip = 'Windows';
    } else if (device.contains('mac') || device.contains('darwin')) {
      iconData = Icons.laptop_mac_rounded;
      tooltip = 'macOS';
    } else if (device.contains('linux')) {
      iconData = Icons.laptop_chromebook_rounded;
      tooltip = 'Linux';
    }

    if (iconData == null) {
      return Tooltip(
        message: '未知设备',
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.4),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.help_outline_rounded,
            size: _deviceIconSize,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      );
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          iconData,
          size: _deviceIconSize,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 18,
      backgroundColor: theme.colorScheme.surface,
      child: ClipOval(child: _buildAvatarContent()),
    );
  }

  Widget _buildAvatarContent() {
    final url = user.avatarUrl.trim();
    if (url.isEmpty) {
      return _buildAvatarFallback();
    }

    final provider = _getCachedAvatar(url);

    return Image(
      image: provider,
      width: 36,
      height: 36,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        _avatarCache.remove(url);
        return _buildAvatarFallback();
      },
    );
  }

  ImageProvider _getCachedAvatar(String url) {
    final cached = _avatarCache[url];
    if (cached != null) {
      return cached;
    }

    final provider = NetworkImage(url);
    _avatarCache[url] = provider;
    return provider;
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: theme.colorScheme.primaryContainer.withOpacity(0.4),
      alignment: Alignment.center,
      child: Text(
        user.name.isNotEmpty ? user.name.characters.first : '?',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
