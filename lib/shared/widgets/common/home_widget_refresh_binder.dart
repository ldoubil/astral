import 'dart:async';
import 'dart:io';

import 'package:astral/core/services/service_manager.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 监听连接/房间/IP/主题变化，防抖后刷新 Android 桌面小部件。
class HomeWidgetRefreshBinder extends StatefulWidget {
  const HomeWidgetRefreshBinder({super.key, required this.child});

  final Widget child;

  @override
  State<HomeWidgetRefreshBinder> createState() => _HomeWidgetRefreshBinderState();
}

class _HomeWidgetRefreshBinderState extends State<HomeWidgetRefreshBinder>
    with WidgetsBindingObserver {
  Timer? _debounce;
  EffectCleanup? _effectCleanup;

  @override
  void initState() {
    super.initState();
    if (!Platform.isAndroid) return;

    WidgetsBinding.instance.addObserver(this);
    final services = ServiceManager();

    _effectCleanup = effect(() {
      services.connectionState.connectionState.value;
      services.roomState.selectedRoom.value;
      services.networkConfigState.ipv4.value;
      services.themeState.themeColor.value;
      services.themeState.themeMode.value;
      _scheduleSync();
    });
    _scheduleSync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _scheduleSync();
    }
  }

  void _scheduleSync() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ServiceManager().widgets.syncAll();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _effectCleanup?.call();
    if (Platform.isAndroid) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
