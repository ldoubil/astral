// 导入所需的包
import 'dart:io';

import 'package:astral/utils/up.dart';
import 'package:astral/k/app_s/aps.dart';
import 'package:astral/k/mod/small_window_adapter.dart'; // 导入小窗口适配器
import 'package:astral/screens/home_page.dart';
import 'package:astral/screens/room_page.dart';
import 'package:astral/screens/server_page.dart';
import 'package:astral/screens/settings_main_page.dart';
import 'package:astral/screens/wfp_page.dart';
import 'package:astral/widgets/bottom_nav.dart';
import 'package:astral/widgets/left_nav.dart';
import 'package:astral/widgets/status_bar.dart';
import 'package:flutter/material.dart';
import 'package:astral/k/navigtion.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

// 主屏幕Widget，使用StatefulWidget以管理状态
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// MainScreen的状态管理类
class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this); // 监听屏幕等状态变化
    // 在第一帧渲染完成后获取屏幕宽度并更新分割宽度
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      Aps().updateScreenSplitWidth(screenWidth);
    });

    // 在初始化时进行更新检查
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Aps().autoCheckUpdate.value || Aps().beta.value) {
        final updateChecker = UpdateChecker(owner: 'ldoubil', repo: 'astral');
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              updateChecker.checkForUpdates(
                context,
                showNoUpdateMessage: false,
              );
            }
          });
        }
      }
    });
  }

  // 组件销毁时移除观察者
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 屏幕尺寸变化时的回调
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // 确保context可用
    if (!mounted) return;

    // 屏幕尺寸变化时更新
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // 记录小窗口状态变化
    bool isSmallWindow = screenWidth < 300 || screenHeight < 400;
    print(
      'Screen size changed: $screenWidth x $screenHeight, isSmallWindow: $isSmallWindow',
    );

    // 更新分割宽度
    Aps().updateScreenSplitWidth(screenWidth);

    // 强制刷新UI以适应新的尺寸
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
    if (Platform.isWindows)
      NavigationItem(
        icon: Icons.shield_outlined, // 未选中时的图标（防火墙）
        activeIcon: Icons.shield, // 选中时的图标（防火墙）
        label: LocaleKeys.nav_firewall.tr(), // 导航项标签
        page: const WfpPage(), // 对应的页面
      ),
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
      page: const SettingsMainPage(), // 对应的页面
    ),
  ];

  // 获取页面列表的getter方法
  List<Widget> get _pages => navigationItems.map((item) => item.page).toList();

  @override
  Widget build(BuildContext context) {
    // 获取当前主题的颜色方案
    final colorScheme = Theme.of(context).colorScheme;
    final isSmallWindow = SmallWindowAdapter.shouldApplyAdapter(context);

    // 构建Scaffold组件
    return Scaffold(
      // 自定义应用栏
      appBar: isSmallWindow ? null : StatusBar(),
      // 主体内容：使用Row布局
      body: Row(
        children: [
          // 根据是否为桌面端决定是否显示左侧导航
          if (Aps().isDesktop.watch(context) && !isSmallWindow)
            LeftNav(items: navigationItems, colorScheme: colorScheme),
          // 主要内容区域
          Expanded(
            child: Column(
              children: [
                // 在小窗口模式下显示简化的状态栏
                if (isSmallWindow)
                  Container(
                    height: 36,
                    color: colorScheme.primaryContainer.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      navigationItems[Aps().selectedIndex.watch(context)].label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                // 主内容区域
                Expanded(
                  child: IndexedStack(
                    index: Aps().selectedIndex.watch(context), // 当前选中的页面索引
                    children: _pages, // 页面列表
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // 底部导航栏：在非桌面端或小窗口模式下显示
      bottomNavigationBar:
          (Aps().isDesktop.watch(context) && !isSmallWindow)
              ? null
              : BottomNav(
                navigationItems: navigationItems,
                colorScheme: colorScheme,
              ),
    );
  }
}