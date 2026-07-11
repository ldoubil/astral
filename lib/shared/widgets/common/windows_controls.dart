import 'package:astral/core/services/service_manager.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
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
  bool _isMaximized = false;
  final TrayManager trayManager = TrayManager.instance;

  @override
  void initState() {
    trayManager.addListener(this);
    windowManager.addListener(this);
    _updateMaximizedStatus();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initTray());
  }

  Future<void> _initTray() async {
    if (!mounted || ServiceManager().uiState.trayHidden.value) return;

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

    await _updateTrayMenu();
  }

  Future<void> _updateTrayMenu() async {
    if (ServiceManager().uiState.trayHidden.value) return;

    final trayMenu = Menu(
      items: [
        MenuItem(
          key: 'show_window',
          label: LocaleKeys.tray_show_window.tr(),
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'hide_tray',
          label: LocaleKeys.tray_hide.tr(),
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit',
          label: LocaleKeys.tray_exit.tr(),
        ),
      ],
    );

    await trayManager.setContextMenu(trayMenu);
  }

  Future<void> _confirmHideTray() async {
    await windowManager.show();
    await windowManager.focus();
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(LocaleKeys.tray_hide_title.tr()),
        content: Text(LocaleKeys.tray_hide_message.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(LocaleKeys.cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(LocaleKeys.tray_hide_confirm.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _hideTray();
    }
  }

  Future<void> _hideTray() async {
    if (ServiceManager().uiState.trayHidden.value) return;

    ServiceManager().uiState.setTrayHidden(true);
    await trayManager.destroy();
    ServiceManager().uiState.setBackground(true);
    await windowManager.hide();
  }

  @override
  void onTrayIconRightMouseDown() {
    if (ServiceManager().uiState.trayHidden.value) return;
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconMouseDown() {
    if (ServiceManager().uiState.trayHidden.value) return;
    ServiceManager().uiState.setBackground(false);
    windowManager.show();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show_window':
        ServiceManager().uiState.setBackground(false);
        windowManager.show();
      case 'hide_tray':
        _confirmHideTray();
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
  void onWindowMaximize() {
    setState(() => _isMaximized = true);
  }

  @override
  void onWindowUnmaximize() {
    setState(() => _isMaximized = false);
  }

  Future<void> _updateMaximizedStatus() async {
    final maximized = await windowManager.isMaximized();
    if (mounted) {
      setState(() => _isMaximized = maximized);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isWindows && !Platform.isMacOS && !Platform.isLinux) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () async {
            ServiceManager().uiState.setBackground(true);
            await windowManager.minimize();
          },
          tooltip: '最小化',
          iconSize: 20,
        ),
        IconButton(
          icon: Icon(_isMaximized ? Icons.filter_none : Icons.crop_square),
          onPressed: () async {
            if (_isMaximized) {
              await windowManager.unmaximize();
            } else {
              await windowManager.maximize();
            }
          },
          tooltip: _isMaximized ? '还原' : '最大化',
          iconSize: 20,
        ),
        IconButton(
          icon: const Icon(Icons.close),
          // 不要 await：close 会触发 onWindowClose，真正退出时不应卡住标题栏按钮
          onPressed: () {
            windowManager.close();
          },
          tooltip: '关闭',
          iconSize: 20,
        ),
      ],
    );
  }
}
