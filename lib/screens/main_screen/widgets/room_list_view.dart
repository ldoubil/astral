import 'package:astral/models/room_info.dart';
import 'package:flutter/material.dart';

/// 房间列表视图组件
class RoomListView extends StatelessWidget {
  const RoomListView({
    super.key,
    required this.rooms,
    required this.onJoin,
    required this.onShare,
    required this.onEdit,
    required this.onDelete,
    required this.onCreate,
    required this.onQuickJoin,
  });

  final List<RoomInfo> rooms;
  final ValueChanged<RoomInfo> onJoin;
  final ValueChanged<RoomInfo> onShare;
  final ValueChanged<RoomInfo> onEdit;
  final ValueChanged<RoomInfo> onDelete;
  final VoidCallback onCreate;
  final VoidCallback onQuickJoin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child:
              rooms.isEmpty
                  ? _EmptyRoomView(theme: theme)
                  : ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: rooms.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      return _RoomCard(
                        room: room,
                        theme: theme,
                        onJoin: () => onJoin(room),
                        onShare: () => onShare(room),
                        onEdit: () => onEdit(room),
                        onDelete: () => onDelete(room),
                      );
                    },
                  ),
        ),
        _RoomListActions(onCreate: onCreate, onQuickJoin: onQuickJoin),
      ],
    );
  }
}

/// 空房间视图
class _EmptyRoomView extends StatelessWidget {
  const _EmptyRoomView({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.meeting_room_outlined,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无房间',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '创建第一个房间开始联机吧',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// 房间卡片组件
class _RoomCard extends StatefulWidget {
  const _RoomCard({
    required this.room,
    required this.theme,
    required this.onJoin,
    required this.onShare,
    required this.onEdit,
    required this.onDelete,
  });

  final RoomInfo room;
  final ThemeData theme;
  final VoidCallback onJoin;
  final VoidCallback onShare;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<_RoomCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  final GlobalKey _cardKey = GlobalKey();
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    // 滑动到卡片宽度的 55%
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 0.55,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final RenderBox? renderBox =
        _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final cardWidth = renderBox.size.width;
    final deltaRatio = details.delta.dx / cardWidth;

    // 向左滑动（delta.dx < 0）时增加，向右滑动时减少
    final newValue = (_controller.value - deltaRatio).clamp(0.0, 1.0);
    _controller.value = newValue;
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    // 根据滑动位置决定是否保持展开或恢复
    if (_controller.value > 0.2) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _handlePanCancel() {
    setState(() {
      _isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: _handlePanStart,
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          onPanCancel: _handlePanCancel,
          child: Stack(
            key: _cardKey,
            clipBehavior: Clip.none,
            children: [
              // 背景操作按钮（在卡片后面）
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _slideAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: widget.theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.only(right: 16),
                      alignment: Alignment.centerRight,
                      child: Opacity(
                        opacity: (_slideAnimation.value / 0.55).clamp(0.0, 1.0),
                        child: IgnorePointer(
                          ignoring: _isDragging,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ActionButton(
                                icon: Icons.share_rounded,
                                color: Colors.blue,
                                onTap: () {
                                  _controller.reverse();
                                  widget.onShare();
                                },
                              ),
                              const SizedBox(width: 8),
                              _ActionButton(
                                icon: Icons.edit_rounded,
                                color: Colors.orange,
                                onTap: () {
                                  _controller.reverse();
                                  widget.onEdit();
                                },
                              ),
                              const SizedBox(width: 8),
                              _ActionButton(
                                icon: Icons.delete_rounded,
                                color: Colors.red,
                                onTap: () {
                                  _controller.reverse();
                                  widget.onDelete();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // 主卡片内容（滑动时向左移动）
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      -constraints.maxWidth * _slideAnimation.value,
                      0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: widget.theme.colorScheme.surfaceVariant
                            .withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.room.name,
                                  style: widget.theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                          FilledButton.tonal(
                            onPressed: widget.onJoin,
                            child: const Text('加入房间'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 圆形操作按钮
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}

/// 房间列表操作按钮
class _RoomListActions extends StatelessWidget {
  const _RoomListActions({required this.onCreate, required this.onQuickJoin});

  final VoidCallback onCreate;
  final VoidCallback onQuickJoin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('创建房间'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.tonal(
              onPressed: onQuickJoin,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.login_rounded, size: 20),
                  SizedBox(width: 8),
                  Text('导入房间'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
