import 'package:astral/core/small_window_adapter.dart';
import 'package:astral/models/base.dart';
import 'package:astral/models/net_node.dart';
import 'package:astral/models/room_info.dart';
import 'package:astral/models/server_node.dart';
import 'package:astral/screens/main_screen/dialogs/create_room_dialog.dart';
import 'package:astral/screens/main_screen/dialogs/edit_room_dialog.dart';
import 'package:astral/screens/main_screen/dialogs/import_room_dialog.dart';
import 'package:astral/screens/main_screen/dialogs/invite_dialog.dart';
import 'package:astral/screens/main_screen/widgets/connecting_overlay.dart';
import 'package:astral/screens/main_screen/widgets/room_list_view.dart';
import 'package:astral/screens/main_screen/widgets/room_members_view.dart';
import 'package:astral/screens/main_screen/widgets/settings_view.dart';
import 'package:astral/screens/main_screen/widgets/user_avatar.dart';
import 'package:astral/screens/main_screen/widgets/user_nickname.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:astral/state/app_state.dart';
import 'package:astral/utils/room_export.dart';
import 'package:astral/utils/up.dart';
import 'package:astral/widgets/status_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 主屏幕Widget，使用StatefulWidget以管理状态
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

/// MainScreen的状态管理类
class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  bool _isInRoom = false;
  RoomInfo? _currentRoom;
  int _currentPageIndex = 0; // 0: 主页, 1: 设置

  final Signal<String> version = signal('');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScreen();
    _checkForUpdates();
    easytierVersion().then((value) {
      setState(() {
        version.value = value;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// 初始化屏幕尺寸
  void _initializeScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final screenWidth = MediaQuery.of(context).size.width;
      AppState().baseState.updateScreenSplitWidth(screenWidth);
    });
  }

  /// 检查更新
  void _checkForUpdates() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (AppState().updateState.autoCheckUpdate.value ||
          AppState().updateState.beta.value) {
        final updateChecker = UpdateChecker(owner: 'ldoubil', repo: 'astral');
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            updateChecker.checkForUpdates(context, showNoUpdateMessage: false);
          }
        });
      }
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) return;

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    AppState().baseState.updateScreenSplitWidth(screenWidth);
    if (mounted) {
      setState(() {});
    }
  }

  /// 处理加入房间
  Future<void> _handleJoinRoom(RoomInfo room) async {
    try {
      // 创建 NetNode
      NetNode netNode = NetNode();
      ServerNode serverNode = ServerNode();
      serverNode.host = 'turn.bj.629957.xyz';
      serverNode.port = 11010;
      serverNode.protocolSwitch = ServerProtocolSwitch.tcp;
      room.servers.add(serverNode);
      // 调用全局连接服务连接房间
      await AppState().v2ConnectionService.connectToRoom(room, netNode);

      // 连接成功后更新UI状态
      setState(() {
        _isInRoom = true;
        _currentRoom = room;
      });
    } catch (e) {
      // 连接失败时显示错误信息
      if (mounted) {
        _showSnackBar('连接失败: $e');
      }
    }
  }

  /// 处理分享房间
  void _handleShareRoom(RoomInfo room) {
    final jsonString = RoomExport.toJson(room);
    Clipboard.setData(ClipboardData(text: jsonString));
    // _showSnackBar('已复制「${room.name}」的 JSON 信息');
  }

  /// 处理编辑房间
  Future<void> _handleEditRoom(RoomInfo room) async {
    final result = await showDialog<RoomInfo>(
      context: context,
      builder: (context) => EditRoomDialog(currentRoom: room),
    );

    if (result != null) {
      AppState().v2RoomState.updateRoom(result);
      _showSnackBar('房间名称已更新');
    }
  }

  /// 处理删除房间
  void _handleDeleteRoom(RoomInfo room) {
    AppState().v2RoomState.removeRoom(room.uuid);
    _showSnackBar('「${room.name}」已删除');
  }

  /// 处理离开房间
  void _handleLeaveRoom() {
    // 断开连接
    AppState().v2ConnectionService.disconnect();

    // 更新UI状态
    setState(() {
      _isInRoom = false;
      _currentRoom = null;
    });
  }

  /// 显示创建房间对话框
  Future<void> _showCreateRoomDialog() async {
    final result = await showDialog<RoomInfo>(
      context: context,
      builder: (context) => const CreateRoomDialog(),
    );

    if (result != null) {
      AppState().v2RoomState.addRoom(result);
    }
  }

  /// 显示邀请对话框
  Future<void> _showInviteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const InviteDialog(),
    );

    if (result == true) {}
  }

  /// 处理导入房间
  Future<void> _handleQuickJoin() async {
    final result = await showDialog<RoomInfo>(
      context: context,
      builder: (context) => const ImportRoomDialog(),
    );

    if (result != null) {
      AppState().v2RoomState.addRoom(result);
      _showSnackBar('已导入房间「${result.name}」');
    }
  }

  /// 显示提示消息
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallWindow = SmallWindowAdapter.shouldApplyAdapter(context);

    return Scaffold(
      appBar: isSmallWindow ? null : const StatusBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Column(
            children: [
              _UserHeader(
                ip:
                    AppState().v2UserState.ipv4.watch(context) +
                    version.watch(context),
                theme: theme,
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Card(
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      // 左侧导航栏 (1/6)
                      Expanded(
                        flex: 1,
                        child: _NavigationSidebar(
                          currentIndex: _currentPageIndex,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPageIndex = index;
                            });
                          },
                          theme: theme,
                        ),
                      ),
                      // 右侧内容区域 (5/6)
                      Expanded(
                        flex: 5,
                        child: IndexedStack(
                          index: _currentPageIndex,
                          children: [
                            // 主页内容（带连接覆盖层）
                            Stack(
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child:
                                      _isInRoom
                                          ? RoomMembersView(
                                            key: const ValueKey('members'),
                                            users: AppState()
                                                .v2BaseState
                                                .userInfo
                                                .watch(context),
                                            onInvite: _showInviteDialog,
                                            onLeave: _handleLeaveRoom,
                                            roomName:
                                                _currentRoom?.name ?? '当前房间',
                                          )
                                          : Builder(
                                            builder: (context) {
                                              // 使用 Watch 监听房间列表变化
                                              final rooms = AppState()
                                                  .v2RoomState
                                                  .rooms
                                                  .watch(context);
                                              return RoomListView(
                                                key: const ValueKey('rooms'),
                                                rooms: rooms,
                                                onJoin: _handleJoinRoom,
                                                onShare: _handleShareRoom,
                                                onEdit: _handleEditRoom,
                                                onDelete: _handleDeleteRoom,
                                                onCreate: _showCreateRoomDialog,
                                                onQuickJoin: _handleQuickJoin,
                                              );
                                            },
                                          ),
                                ),
                                const Positioned.fill(
                                  child: ConnectingOverlay(),
                                ),
                              ],
                            ),
                            // 设置页面
                            const SettingsView(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 用户头部信息组件
class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.ip, required this.theme});

  final String ip;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const UserAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserNickname(theme: theme),
                const SizedBox(height: 4),
                Text(
                  ip,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 左侧导航栏组件
class _NavigationSidebar extends StatelessWidget {
  const _NavigationSidebar({
    required this.currentIndex,
    required this.onPageChanged,
    required this.theme,
  });

  static const double _navItemSize = 56;
  static const double _navItemSpacing = 12;
  static const double _navPadding = 16;

  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final destinations = [
      _NavDestination(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        tooltip: '主页',
        onTap: () => onPageChanged(0),
        isSelected: currentIndex == 0,
      ),
      _NavDestination(
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings_rounded,
        tooltip: '设置',
        onTap: () => onPageChanged(1),
        isSelected: currentIndex == 1,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: _navPadding,
          horizontal: 10,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 240),
              curve: Curves.fastOutSlowIn,
              top: currentIndex * (_navItemSize + _navItemSpacing),
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: _NavIndicator(size: _navItemSize, theme: theme),
              ),
            ),
            Column(
              children: [
                for (int i = 0; i < destinations.length; i++) ...[
                  Align(
                    alignment: Alignment.center,
                    child: _NavButton(
                      destination: destinations[i],
                      theme: theme,
                      size: _navItemSize,
                    ),
                  ),
                  if (i != destinations.length - 1)
                    const SizedBox(height: _navItemSpacing),
                ],
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIndicator extends StatelessWidget {
  const _NavIndicator({required this.size, required this.theme});

  final double size;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.25),
          width: 1,
        ),
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  const _NavButton({
    required this.destination,
    required this.theme,
    required this.size,
  });

  final _NavDestination destination;
  final ThemeData theme;
  final double size;

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  @override
  Widget build(BuildContext context) {
    final iconColor =
        widget.destination.isSelected
            ? widget.theme.colorScheme.primary
            : widget.theme.colorScheme.onSurfaceVariant;

    return MouseRegion(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: widget.destination.onTap,
            borderRadius: BorderRadius.circular(18),
            splashColor: widget.theme.colorScheme.primary.withOpacity(0.15),
            hoverColor: widget.theme.colorScheme.primary.withOpacity(0.1),
            child: Center(
              child: Icon(
                widget.destination.isSelected
                    ? widget.destination.selectedIcon
                    : widget.destination.icon,
                size: 24,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.tooltip,
    required this.onTap,
    required this.isSelected,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isSelected;
}
