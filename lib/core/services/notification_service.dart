import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:astral/core/services/service_manager.dart';

/// 连接状态通知服务（仅Android）
///
/// - TUN 模式：连接通知由原生 TauriVpnService 作为前台通知托管，
///   服务/进程销毁时通知由系统一并移除，避免杀进程后残留“连接中”。
/// - NO-TUN 模式：没有 VPN 服务，退回 flutter_local_notifications 普通通知。
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

  /// TUN 模式下通知归原生 VpnService 管理
  bool get _nativeManaged =>
      Platform.isAndroid &&
      !ServiceManager().networkConfigState.noTun.value;

  /// 初始化通知服务
  Future<void> initialize() async {
    final plugin = _plugin;
    if (plugin == null) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await plugin.initialize(settings);
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
    if (!Platform.isAndroid) return;

    if (_nativeManaged) {
      final plugin = ServiceManager().vpn.plugin;
      if (plugin == null) return;
      // 连接中阶段服务尚未启动，原生会在启动时自行显示“连接中”，
      // 这里只处理服务已存在时的更新（已连接后的每秒刷新走不到这里的连接中分支）。
      await plugin.updateNotification(
        status: status,
        ip: ip,
        duration: duration,
      );
      return;
    }

    await _showFlutterNotification(
      status: status,
      ip: ip,
      duration: duration,
    );
  }

  Future<void> _showFlutterNotification({
    required String status,
    required String ip,
    required String duration,
  }) async {
    final plugin = _plugin;
    if (plugin == null) return;
    if (!ServiceManager().appSettingsState.enableConnectionNotification.value) {
      await cancelConnectionNotification();
      return;
    }

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

    await plugin.show(
      _connectionNotificationId,
      'Astral - $status',
      'IP: $ip | 连接时间: $duration',
      details,
    );
  }

  /// 取消连接状态通知
  Future<void> cancelConnectionNotification() async {
    if (!Platform.isAndroid) return;

    if (_nativeManaged) {
      // TUN 模式：服务停止时前台通知由系统移除，无需单独取消
      return;
    }

    final plugin = _plugin;
    if (plugin == null) return;
    await plugin.cancel(_connectionNotificationId);
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
