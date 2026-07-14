import 'dart:io';

import 'package:astral/core/services/update_service.dart';
import 'package:astral/shared/widgets/common/update_check_ui.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/platform/small_window_adapter.dart';
import 'package:astral/features/home/pages/home_page.dart';
import 'package:astral/features/rooms/pages/room_page.dart';
import 'package:astral/features/tools/pages/tools_page.dart';
import 'package:astral/features/servers/pages/server_page.dart';
import 'package:astral/features/settings/pages/settings_main_page.dart';
import 'package:astral/shared/widgets/navigation/bottom_nav.dart';
import 'package:astral/shared/widgets/navigation/left_nav.dart';
import 'package:astral/shared/widgets/common/status_bar.dart';
import 'package:flutter/material.dart';
import 'package:astral/core/ui/navigation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:window_manager/window_manager.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        WindowListener {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.addListener(this);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      ServiceManager().uiState.updateScreenSplitWidth(screenWidth);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ServiceManager().updateState.autoCheckUpdate.value ||
          ServiceManager().updateState.beta.value) {
        final checker = UpdateChecker(owner: 'ldoubil', repo: 'astral');
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              UpdateCheckUi.checkAndPresent(
                context,
                checker,
                showNoUpdateMessage: false,
                showFailureMessage: false,
              );
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.removeListener(this);
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _setAppBackground(bool isInBackground) {
    if (ServiceManager().uiState.isInBackground.value != isInBackground) {
      ServiceManager().uiState.setBackground(isInBackground);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _setAppBackground(false);
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _setAppBackground(true);
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) return;

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    ServiceManager().uiState.updateScreenSplitWidth(screenWidth);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void onWindowMinimize() {
    _setAppBackground(true);
  }

  @override
  void onWindowBlur() {
    _setAppBackground(true);
  }

  @override
  void onWindowRestore() {
    _setAppBackground(false);
  }

  @override
  void onWindowFocus() {
    _setAppBackground(false);
  }

  @override
  void onWindowClose() async {
    // setPreventClose(true) 时才会拦截；二次 close 时直接放行，避免死循环
    final isPreventClose = await windowManager.isPreventClose();
    if (!isPreventClose) return;

    final services = ServiceManager();
    // 隐藏托盘后，或开启「关闭时最小化」：只隐藏窗口
    if (services.uiState.trayHidden.value ||
        services.windowState.closeMinimize.value) {
      _setAppBackground(true);
      await windowManager.hide();
      return;
    }

    // 真正退出：不要用 destroy()，Windows 上会卡死数秒甚至无响应
    // 见 https://github.com/leanflutter/window_manager/issues/478
    await windowManager.setPreventClose(false);
    await windowManager.close();
  }

  List<NavigationItem> get navigationItems => [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: LocaleKeys.nav_home.tr(),
      page: const HomePage(),
    ),
    NavigationItem(
      icon: Icons.room_preferences_outlined,
      activeIcon: Icons.room_preferences,
      label: LocaleKeys.nav_room.tr(),
      page: const RoomPage(),
    ),
    NavigationItem(
      icon: Icons.build_outlined,
      activeIcon: Icons.build,
      label: '工具',
      page: const ToolsPage(),
    ),
    NavigationItem(
      icon: Icons.dns_outlined,
      activeIcon: Icons.dns,
      label: LocaleKeys.nav_server.tr(),
      page: const ServersPage(),
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: LocaleKeys.nav_settings.tr(),
      page: const SettingsMainPage(),
    ),
  ];

  List<Widget> get _pages => navigationItems.map((item) => item.page).toList();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSmallWindow = SmallWindowAdapter.shouldApplyAdapter(context);

    return Watch((context) {
      final currentIndex = ServiceManager().uiState.selectedIndex.value;
      final itemCount = navigationItems.length;

      if (currentIndex >= itemCount && itemCount > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ServiceManager().uiState.selectedIndex.value >= itemCount) {
            ServiceManager().uiState.selectedIndex.value = 0;
          }
        });
      }

      final safeIndex =
          (currentIndex >= 0 && currentIndex < itemCount) ? currentIndex : 0;

      return Scaffold(
        appBar: isSmallWindow ? null : StatusBar(),
        body: Row(
          children: [
            if (ServiceManager().uiState.isDesktop.value && !isSmallWindow)
              LeftNav(items: navigationItems, colorScheme: colorScheme),
            Expanded(
              child: Column(
                children: [
                  if (isSmallWindow)
                    Container(
                      height: 36,
                      color: colorScheme.primaryContainer.withValues(alpha: 0.4),
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
                  Expanded(
                    child: IndexedStack(
                      index: safeIndex,
                      children: _pages,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar:
            (ServiceManager().uiState.isDesktop.value && !isSmallWindow)
                ? null
                : BottomNav(
                  navigationItems: navigationItems,
                  colorScheme: colorScheme,
                ),
      );
    });
  }
}
