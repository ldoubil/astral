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
import 'package:astral/screens/settings/settings_screen.dart';
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

  final Signal<String> version = signal('');

  /// 构建主页内容
  Widget _buildHomePage(BuildContext context) {
    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child:
              _isInRoom
                  ? RoomMembersView(
                    key: const ValueKey('members'),
                    users: AppState().v2BaseState.userInfo.watch(context),
                    onInvite: _showInviteDialog,
                    onLeave: _handleLeaveRoom,
                    roomName: _currentRoom?.name ?? '当前房间',
                  )
                  : Builder(
                    builder: (context) {
                      final rooms = AppState().v2RoomState.rooms.watch(context);
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
        const Positioned.fill(child: ConnectingOverlay()),
      ],
    );
  }

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

  // 定义导航项列表
  List<NavigationItem> get navigationItems => [
    NavigationItem(
      icon: Icons.home_outlined, // 未选中时的图标
      activeIcon: Icons.home, // 选中时的图标
      label: LocaleKeys.nav_home.tr(), // 导航项标签
      page: const HomePage(), // 对应的页面
    ),
    NavigationItem(
      icon: Icons.room_preferences_outlined, // 未选中时的图标
      activeIcon: Icons.room_preferences, // 选中时的图标Icon(Icons.room_preferences)
      label: LocaleKeys.nav_room.tr(), // 导航项标签
      page: const RoomPage(), // 对应的页面
    ),
    // if (Platform.isWindows)
    //   NavigationItem(
    //     icon: Icons.shield_outlined, // 未选中时的图标（防火墙）
    //     activeIcon: Icons.shield, // 选中时的图标（防火墙）
    //     label: LocaleKeys.nav_firewall.tr(), // 导航项标签
    //     page: const WfpPage(), // 对应的页面
    //   ),
    NavigationItem(
      icon: Icons.dns_outlined, // 未选中时的图标
      activeIcon: Icons.dns, // 选中时的图标Icon(Icons.room_preferences)
      label: LocaleKeys.nav_server.tr(), // 导航项标签
      page: const ServerPage(), // 对应的页面
    ),
    NavigationItem(
      icon: Icons.settings_outlined, // 未选中时的图标
      activeIcon: Icons.settings, // 选中时的图标
      label: LocaleKeys.nav_settings.tr(), // 导航项标签
      page: const SettingsPage(), // 对应的页面
    ),
  ];

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600; // 超过 600px 使用桌面布局

    return Scaffold(
      appBar:
          isSmallWindow
              ? null
              : StatusBar(
                onSettingsTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                isSettingsSelected: false,
              ),
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child:
                      isDesktop
                          ? _buildDesktopLayout(context)
                          : _buildMobileLayout(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 桌面布局：直接显示内容区
  Widget _buildDesktopLayout(BuildContext context) {
    return _buildHomePage(context);
  }

  /// 移动端布局：直接显示内容区
  Widget _buildMobileLayout(BuildContext context) {
    return _buildHomePage(context);
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
