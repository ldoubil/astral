import 'package:astral/screens/main_screen/dialogs/edit_nickname_dialog.dart';
import 'package:astral/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 用户昵称组件
/// 支持点击编辑昵称
class UserNickname extends StatefulWidget {
  const UserNickname({super.key, required this.theme});

  final ThemeData theme;

  @override
  State<UserNickname> createState() => _UserNicknameState();
}

class _UserNicknameState extends State<UserNickname> {
  @override
  void initState() {
    super.initState();
    // 监听信号变化
    effect(() {
      // 访问信号值以建立依赖关系
      AppState().v2UserState.Name.value;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final nickname = AppState().v2UserState.Name.value;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showEditNicknameDialog(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              nickname,
              style: widget.theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 4),
            // 鼠标悬停时显示编辑图标
            _HoverEditIcon(),
          ],
        ),
      ),
    );
  }

  /// 显示编辑昵称对话框
  Future<void> _showEditNicknameDialog(BuildContext context) async {
    final currentNickname = AppState().v2UserState.Name.value;
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => EditNicknameDialog(currentNickname: currentNickname),
    );

    if (result != null && mounted && result.isNotEmpty) {
      AppState().v2UserState.Name.value = result;
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
        child: Icon(
          Icons.edit,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
