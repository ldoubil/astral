import 'package:astral/state/app_state.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';

class WindowControls extends StatefulWidget {
  const WindowControls({super.key});

  @override
  State<WindowControls> createState() => _WindowControlsState();
}

class _WindowControlsState extends State<WindowControls>
    with TrayListener, WindowListener {
  final TrayManager trayManager = TrayManager.instance;

  @override
  void initState() {
    trayManager.addListener(this);
    windowManager.addListener(this);
    _updateMaximizedStatus();
    // 桌面平台代码
    _initTray();
    super.initState();
  }

  Future<void> _initTray() async {
    if (Platform.isWindows) {
      await trayManager.setIcon('assets/icon.ico');
    } else if (Platform.isMacOS) {
      await trayManager.setIcon('assets/logo.png');
    } else {
      await trayManager.setIcon('assets/logo.png');
    }

    if (!Platform.isLinux) {
      await trayManager.setToolTip('Astral');
    }

    Menu trayMenu = Menu(
      items: [
        MenuItem(key: 'show_window', label: '显示主界面'),
        MenuItem.separator(),
        MenuItem(key: 'exit', label: '退出'),
      ],
    );

    await trayManager.setContextMenu(trayMenu);
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show_window':
        windowManager.show();
      case 'exit':
        exit(0);
    }
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {}

  @override
  void onWindowUnmaximize() {}

  Future<void> _updateMaximizedStatus() async {}

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            if (AppState().applicationState.closeMinimize.value) {
              await windowManager.hide();
            } else {
              await windowManager.close();
            }
          },
          tooltip: '关闭',
          iconSize: 20,
        ),
      ],
    );
  }
}
