import 'dart:io';
import 'package:home_widget/home_widget.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/services/server_connection_manager.dart';
import 'package:astral/core/states/connection_state.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  if (uri == null) return;
  if (uri.scheme == 'astral' && uri.host == 'toggle_connection') {
    WidgetsFlutterBinding.ensureInitialized();
    await ServiceManager().init();
    
    final state = ServiceManager().connectionState.connectionState.value;
    if (state == CoState.idle) {
      await ServerConnectionManager.instance.connect();
    } else if (state == CoState.connected) {
      await ServerConnectionManager.instance.disconnect();
    }
  }
}

class WidgetService {
  static WidgetService? _instance;

  static WidgetService get instance {
    _instance ??= WidgetService._();
    return _instance!;
  }

  WidgetService._();

  /// 贴片的 provider 名字
  final String _androidWidgetSmall = 'AstralWidgetProvider';
  final String _androidWidgetMedium = 'AstralWidgetProviderMedium';
  final String _androidWidgetLarge = 'AstralWidgetProviderLarge';

  /// 初始化并注册状态监听
  void initialize() {
    if (!Platform.isAndroid) return;

    // 注册后台回调
    HomeWidget.registerBackgroundCallback(backgroundCallback);

    // 监听前台点击
    HomeWidget.widgetClicked.listen((Uri? uri) {
      if (uri != null && uri.scheme == 'astral' && uri.host == 'toggle_connection') {
        final state = ServiceManager().connectionState.connectionState.value;
        if (state == CoState.idle) {
          ServerConnectionManager.instance.connect();
        } else if (state == CoState.connected) {
          ServerConnectionManager.instance.disconnect();
        }
      }
    });

    // 监听连接状态
    effect(() {
      final state = ServiceManager().connectionState.connectionState.value;
      _updateConnectionState(state);
    });

    // 监听选中的房间
    effect(() {
      final room = ServiceManager().roomState.selectedRoom.value;
      if (room != null) {
        HomeWidget.saveWidgetData<String>('room_name', room.name);
        _triggerWidgetUpdate();
      }
    });

    // 监听 IP 变化
    effect(() {
      final ip = ServiceManager().networkConfigState.ipv4.value;
      HomeWidget.saveWidgetData<String>('ip_text', ip.isEmpty ? '--' : ip);
      _triggerWidgetUpdate();
    });
  }

  /// 更新连接状态文本
  Future<void> _updateConnectionState(CoState state) async {
    String statusText = '未连接';
    if (state == CoState.connecting) {
      statusText = '连接中...';
    } else if (state == CoState.connected) {
      statusText = '已连接';
    }

    await HomeWidget.saveWidgetData<String>('status_text', statusText);
    await _triggerWidgetUpdate();
  }

  /// 更新连接时长（由 ServerConnectionManager 定期调用）
  Future<void> updateDuration(String duration) async {
    if (!Platform.isAndroid) return;
    await HomeWidget.saveWidgetData<String>('duration_text', duration);
    await _triggerWidgetUpdate();
  }

  /// 触发所有 Android 贴片的刷新
  Future<void> _triggerWidgetUpdate() async {
    await HomeWidget.updateWidget(androidName: _androidWidgetSmall);
    await HomeWidget.updateWidget(androidName: _androidWidgetMedium);
    await HomeWidget.updateWidget(androidName: _androidWidgetLarge);
  }
}
