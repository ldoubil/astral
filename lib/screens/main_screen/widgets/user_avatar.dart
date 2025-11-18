import 'package:astral/screens/main_screen/dialogs/avatar_url_dialog.dart';
import 'package:astral/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 用户头像组件
/// 支持点击设置在线头像URL
class UserAvatar extends StatefulWidget {
  const UserAvatar({super.key});

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  @override
  void initState() {
    super.initState();
    // 监听信号变化
    effect(() {
      // 访问信号值以建立依赖关系
      AppState().v2UserState.AvatarUrl.value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarUrl = AppState().v2UserState.AvatarUrl.value;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showAvatarUrlDialog(context),
        child: Stack(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                child:
                    avatarUrl.isEmpty
                        ? Icon(
                          Icons.person,
                          color: theme.colorScheme.primary,
                          size: 28,
                        )
                        : ClipOval(
                          child: Image.network(
                            avatarUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // 如果加载失败，显示默认图标
                              return Icon(
                                Icons.person,
                                color: theme.colorScheme.primary,
                                size: 28,
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                strokeWidth: 2,
                              );
                            },
                          ),
                        ),
              ),
            ),
            // 鼠标悬停时显示编辑图标
            const _HoverEditIcon(),
          ],
        ),
      ),
    );
  }

  /// 显示头像URL输入对话框
  Future<void> _showAvatarUrlDialog(BuildContext context) async {
    final currentUrl = AppState().v2UserState.AvatarUrl.value;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AvatarUrlDialog(currentUrl: currentUrl),
    );

    if (result != null && mounted) {
      if (result.isEmpty) {
        // 清空头像
        AppState().v2UserState.AvatarUrl.value = '';
      } else {
        // 设置新头像URL
        AppState().v2UserState.AvatarUrl.value = result;
      }
    }
  }
}

/// 鼠标悬停时显示的编辑图标
class _HoverEditIcon extends StatefulWidget {
  const _HoverEditIcon();

  @override
  State<_HoverEditIcon> createState() => _HoverEditIconState();
}

class _HoverEditIconState extends State<_HoverEditIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedOpacity(
        opacity: _isHovered ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.5),
          ),
          child: const Icon(Icons.edit, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
