import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String _ip = '192.168.0.1';
  bool _isInRoom = false;
  _RoomInfo? _currentRoom;

  final List<_RoomInfo> _rooms = [
    _RoomInfo(name: '星辰一号'),
    _RoomInfo(name: '远航小队'),
    _RoomInfo(name: '回忆之海'),
  ];

  final List<_UserInfo> _roomUsers = [
    _UserInfo(name: '北风', ip: '10.0.0.12', latency: 32),
    _UserInfo(name: '南屿', ip: '10.0.0.18', latency: 48),
    _UserInfo(name: '西柚', ip: '10.0.0.25', latency: 71),
  ];

  final TextEditingController _roomNameController = TextEditingController();

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(theme),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '会做饭的二哈',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _ip,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    _isInRoom
                        ? _RoomMembersView(
                          users: _roomUsers,
                          onInvite: _showInviteDialog,
                          onLeave: _handleLeaveRoom,
                          roomName: _currentRoom?.name ?? '当前房间',
                        )
                        : _RoomListView(
                          rooms: _rooms,
                          onJoin: _handleJoinRoom,
                          onShare: _handleShareRoom,
                          onDelete: _handleDeleteRoom,
                          onCreate: _showCreateRoomDialog,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleJoinRoom(_RoomInfo room) {
    setState(() {
      _isInRoom = true;
      _currentRoom = room;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已加入「${room.name}」')));
  }

  void _handleShareRoom(_RoomInfo room) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已复制「${room.name}」分享链接')));
  }

  void _handleDeleteRoom(_RoomInfo room) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('「${room.name}」已删除')));
  }

  void _handleLeaveRoom() {
    setState(() {
      _isInRoom = false;
      _currentRoom = null;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已离开房间')));
  }

  void _showCreateRoomDialog() {
    _roomNameController.clear();
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('创建房间'),
          content: TextField(
            controller: _roomNameController,
            decoration: const InputDecoration(hintText: '输入房间名称'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('已创建房间「${_roomNameController.text}」')),
                );
              },
              child: const Text('创建'),
            ),
          ],
        );
      },
    );
  }

  void _showInviteDialog() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('邀请成员'),
          content: const Text('将邀请链接复制发送给好友即可加入房间。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('邀请链接已复制')));
              },
              child: const Text('复制链接'),
            ),
          ],
        );
      },
    );
  }
}

Widget _buildAvatar(ThemeData theme) {
  return CircleAvatar(
    radius: 28,
    backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
    child: Icon(Icons.person, color: theme.colorScheme.primary, size: 28),
  );
}

class _RoomInfo {
  const _RoomInfo({required this.name});

  final String name;
}

class _UserInfo {
  const _UserInfo({
    required this.name,
    required this.ip,
    required this.latency,
  });

  final String name;
  final String ip;
  final int latency;
}

class _RoomMembersView extends StatelessWidget {
  const _RoomMembersView({
    required this.users,
    required this.onInvite,
    required this.onLeave,
    required this.roomName,
  });

  final List<_UserInfo> users;
  final VoidCallback onInvite;
  final VoidCallback onLeave;
  final String roomName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Text(
                '$roomName',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onInvite,
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: const Text('邀请成员'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onLeave,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('离开房间'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final user = users[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _LatencyBadge(latency: user.latency),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: theme.textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            user.ip,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LatencyBadge extends StatelessWidget {
  const _LatencyBadge({required this.latency});

  final int latency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    if (latency <= 40) {
      color = Colors.green;
    } else if (latency <= 80) {
      color = Colors.orange;
    } else {
      color = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${latency}ms',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RoomListView extends StatelessWidget {
  const _RoomListView({
    required this.rooms,
    required this.onJoin,
    required this.onShare,
    required this.onDelete,
    required this.onCreate,
  });

  final List<_RoomInfo> rooms;
  final ValueChanged<_RoomInfo> onJoin;
  final ValueChanged<_RoomInfo> onShare;
  final ValueChanged<_RoomInfo> onDelete;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: rooms.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final room = rooms[index];
              return Dismissible(
                key: ValueKey(room.name),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  final result = await showModalBottomSheet<_RoomAction>(
                    context: context,
                    builder: (_) => _RoomActionSheet(room: room),
                  );
                  if (result == _RoomAction.share) onShare(room);
                  if (result == _RoomAction.delete) onDelete(room);
                  return false;
                },
                background: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.keyboard_double_arrow_left_rounded,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(room.name, style: theme.textTheme.titleMedium),
                            const SizedBox(height: 2),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: () => onJoin(room),
                        child: const Text('加入房间'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('创建房间'),
            ),
          ),
        ),
      ],
    );
  }
}

enum _RoomAction { share, delete }

class _RoomActionSheet extends StatelessWidget {
  const _RoomActionSheet({required this.room});

  final _RoomInfo room;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.share_rounded),
            title: const Text('分享房间'),
            onTap: () => Navigator.of(context).pop(_RoomAction.share),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded),
            title: const Text('删除房间'),
            onTap: () => Navigator.of(context).pop(_RoomAction.delete),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
