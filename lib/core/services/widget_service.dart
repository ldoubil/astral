import 'dart:io';
import 'package:astral/core/constants/home_widget_keys.dart';
import 'package:astral/core/database/app_data.dart';
import 'package:astral/core/services/home_widget_theme_sync.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/states/connection_state.dart';
import 'package:home_widget/home_widget.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> homeWidgetBackgroundCallback(Uri? uri) async {
  WidgetsFlutterBinding.ensureInitialized();
  await _ensureWidgetRuntimeReady();
  final services = ServiceManager();

  if (uri != null && uri.scheme == 'astral' && uri.host == 'toggle_connection') {
    final state = services.connectionState.connectionState.value;
    if (state == CoState.idle) {
      await services.connection.connect(isManual: false);
    } else if (state == CoState.connected) {
      await services.connection.disconnect();
    }
  }

  await services.widgets.syncAll();
}

Future<void> _ensureWidgetRuntimeReady() async {
  final db = AppDatabase();
  if (!db.isInitialized) {
    await db.init();
  }
  final services = ServiceManager();
  if (!services.isInitialized) {
    await services.init();
  }
}

class WidgetService {
  static WidgetService? _instance;

  static WidgetService get instance {
    _instance ??= WidgetService._();
    return _instance!;
  }

  WidgetService._();

  /// 初始化并注册状态监听
  void initialize() {
    if (!Platform.isAndroid) return;

    HomeWidget.registerInteractivityCallback(homeWidgetBackgroundCallback);

    HomeWidget.widgetClicked.listen((Uri? uri) {
      if (uri != null &&
          uri.scheme == 'astral' &&
          uri.host == 'toggle_connection') {
        final services = ServiceManager();
        final state = services.connectionState.connectionState.value;
        if (state == CoState.idle) {
          services.connection.connect(isManual: false);
        } else if (state == CoState.connected) {
          services.connection.disconnect();
        }
      }
    });
  }

  /// 同步主题、连接状态、房间与 IP 到所有小部件。
  Future<void> syncAll() async {
    if (!Platform.isAndroid) return;

    final services = ServiceManager();
    final themeState = services.themeState;
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    await syncHomeWidgetTheme(
      seedColor: themeState.themeColor.value,
      themeMode: themeState.themeMode.value,
      platformBrightness: brightness,
    );

    final state = services.connectionState.connectionState.value;
    String statusText = '未连接';
    if (state == CoState.connecting) {
      statusText = '连接中...';
    } else if (state == CoState.connected) {
      statusText = '已连接';
    }
    await HomeWidget.saveWidgetData<String>(
      HomeWidgetKeys.statusText,
      statusText,
    );

    final room = services.roomState.selectedRoom.value;
    await HomeWidget.saveWidgetData<String>(
      HomeWidgetKeys.roomName,
      room?.name ?? '未选择',
    );

    final ip = services.networkConfigState.ipv4.value;
    await HomeWidget.saveWidgetData<String>(
      HomeWidgetKeys.ipText,
      ip.isEmpty ? '--' : ip,
    );

    await _triggerWidgetUpdate();
  }

  /// 更新连接时长（由 ServerConnectionManager 定期调用）
  Future<void> updateDuration(String duration) async {
    if (!Platform.isAndroid) return;
    await HomeWidget.saveWidgetData<String>(
      HomeWidgetKeys.durationText,
      duration,
    );
    await _triggerWidgetUpdate();
  }

  Future<void> _triggerWidgetUpdate() async {
    await HomeWidget.updateWidget(androidName: HomeWidgetKeys.widgetSmall);
    await HomeWidget.updateWidget(androidName: HomeWidgetKeys.widgetMedium);
    await HomeWidget.updateWidget(androidName: HomeWidgetKeys.widgetLarge);
  }
}
