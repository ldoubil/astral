import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 连接状态通知服务（仅Android）
class NotificationService {
  static NotificationService? _instance;
  final FlutterLocalNotificationsPlugin? _plugin;
  static const int _connectionNotificationId = 1001;

  NotificationService._()
    : _plugin = Platform.isAndroid ? FlutterLocalNotificationsPlugin() : null;

  /// 获取单例实例
  static NotificationService get instance {
    _instance ??= NotificationService._();
    return _instance!;
  }

  /// 初始化通知服务
  Future<void> initialize() async {
    if (_plugin == null) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin!.initialize(settings);
  }

  /// 显示或更新连接状态通知
  ///
  /// [status] 连接状态文本（如"连接中"、"已连接"）
  /// [ip] IP地址
  /// [duration] 连接时长
  Future<void> showConnectionNotification({
    required String status,
    required String ip,
    required String duration,
  }) async {
    if (_plugin == null) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'astral_connection',
          'Astral 连接状态',
          channelDescription: '显示 Astral 连接状态和信息',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          showWhen: false,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin!.show(
      _connectionNotificationId,
      'Astral - $status',
      'IP: $ip | 连接时间: $duration',
      details,
    );
  }

  /// 取消连接状态通知
  Future<void> cancelConnectionNotification() async {
    if (_plugin == null) return;
    await _plugin!.cancel(_connectionNotificationId);
  }

  /// 格式化连接时长
  ///
  /// 将秒数转换为 HH:MM:SS 或 MM:SS 格式
  static String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }
}
