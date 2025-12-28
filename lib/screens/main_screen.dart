// 导入所需的包
import 'package:astral/utils/up.dart';
import 'package:astral/k/app_s/aps.dart';
import 'package:astral/k/mod/small_window_adapter.dart'; // 导入小窗口适配器
import 'package:astral/screens/home_page.dart';
import 'package:astral/screens/room_page.dart';
import 'package:astral/screens/explore_page.dart';
import 'package:astral/screens/settings_page.dart';
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
    // create_overlay_window

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
      icon: Icons.room_preferences_outlined,
      activeIcon: Icons.room_preferences,
      label: LocaleKeys.nav_room.tr(),
      page: const RoomPage(),
    ),

    NavigationItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      label: '探索',
      page: const ExplorePage(),
    ),

    NavigationItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: LocaleKeys.nav_settings.tr(),
      page: const SettingsPage(),
    ),
  ];

  // 获取页面列表的getter方法
  List<Widget> get _pages => navigationItems.map((item) => item.page).toList();

  @override
  Widget build(BuildContext context) {
    // 获取当前主题的颜色方案
    final colorScheme = Theme.of(context).colorScheme;
    final isSmallWindow = SmallWindowAdapter.shouldApplyAdapter(context);

    // 确保selectedIndex在有效范围内
    final currentIndex = Aps().selectedIndex.watch(context);
    final itemCount = navigationItems.length;

    // 如果当前索引超出范围（比如禁用了发现页面），自动回到主页
    if (currentIndex >= itemCount && itemCount > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Aps().selectedIndex.value >= itemCount) {
          Aps().selectedIndex.value = 0;
        }
      });
    }

    // 使用安全的索引值，确保不会越界
    final safeIndex =
        (currentIndex >= 0 && currentIndex < itemCount) ? currentIndex : 0;

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
                      safeIndex < navigationItems.length
                          ? navigationItems[safeIndex].label
                          : '',
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
                    index: safeIndex, // 使用安全的索引
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
