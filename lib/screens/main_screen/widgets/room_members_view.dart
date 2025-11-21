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
  static const double _deviceIconSize = 14;
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

    // 统一的卡片圆角值
    const cardBorderRadius = 10.0;

    return InkWell(
      onTap: () => _copyIpAddress(context, user.ip),
      borderRadius: BorderRadius.circular(cardBorderRadius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardBorderRadius),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // 背景装饰层（填充整个容器，包括 padding）
            _buildCardBackground(),
            // 内容层（带 padding）
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cardBorderRadius),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 8),
                  // 中间：用户名和IP（上下排列）
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 用户名（上移一点）
                        Tooltip(
                          message: user.name,
                          child: Text(
                            user.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // IP地址（下面）
                        Text(
                          user.ip,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 右侧：延迟和设备（左右排列）
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 延迟（在左）
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          border: Border.all(color: latencyColor, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${user.latency}ms',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: latencyColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      // 设备标签（图标，在右）
                      if (user.device.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        _buildDeviceIndicator(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建卡片背景装饰
  Widget _buildCardBackground() {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      right: 0, // 缩小一个像素，避免溢出
      child: Stack(
        children: [
          // 基础背景色（完全填充，不留空隙）
          Positioned.fill(
            child: Container(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
            ),
          ),
          // 斜向头像装饰
          Positioned(
            right: -20,
            top: -10,
            child: Transform.rotate(
              angle: 0.3, // 约17度倾斜
              child: Opacity(
                opacity: 0.15,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image:
                        user.avatarUrl.trim().isNotEmpty
                            ? DecorationImage(
                              image: _getCachedAvatar(user.avatarUrl.trim()),
                              fit: BoxFit.cover,
                            )
                            : null,
                    color:
                        user.avatarUrl.trim().isEmpty
                            ? theme.colorScheme.primaryContainer.withOpacity(
                              0.3,
                            )
                            : null,
                  ),
                  child:
                      user.avatarUrl.trim().isEmpty
                          ? Center(
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name.characters.first
                                  : '?',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer
                                    .withOpacity(0.3),
                              ),
                            ),
                          )
                          : null,
                ),
              ),
            ),
          ),
          // 渐变遮罩（从左上到右下）
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface.withOpacity(0.6),
                  theme.colorScheme.surface.withOpacity(0.3),
                  theme.colorScheme.surface.withOpacity(0.7),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ],
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
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.4),
            borderRadius: BorderRadius.circular(4),
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
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(4),
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
      radius: 16,
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
      width: 32,
      height: 32,
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
