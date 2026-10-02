import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'vpn_service_plugin_platform_interface.dart';

class MethodChannelVpnServicePlugin extends VpnServicePluginPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('vpn_service');

  @override
  Future<Map<String, dynamic>> prepareVpn() async {
    final result = await methodChannel.invokeMethod<Map<Object?, Object?>>(
      'prepareVpn',
    );
    return Map<String, dynamic>.from(result ?? {});
  }

  @override
  Future<Map<String, dynamic>> startVpn({
    String? ipv4Addr,
    List<String>? routes,
    String? dns,
    List<String>? disallowedApplications,
    int? mtu,
    bool notificationsEnabled = true,
  }) async {
    final result = await methodChannel
        .invokeMethod<Map<Object?, Object?>>('startVpn', {
          'ipv4Addr': ipv4Addr,
          'routes': routes,
          'dns': dns,
          'disallowedApplications': disallowedApplications,
          'mtu': mtu,
          'notificationsEnabled': notificationsEnabled,
        });
    return Map<String, dynamic>.from(result ?? {});
  }

  @override
  Future<Map<String, dynamic>> stopVpn() async {
    await methodChannel.invokeMethod<void>('stopVpn');
    return {}; // Return an empty map to match the required return type
  }

  @override
  Future<void> updateNotification({
    required String status,
    required String ip,
    required String duration,
  }) async {
    await methodChannel.invokeMethod<void>('updateNotification', {
      'status': status,
      'ip': ip,
      'duration': duration,
    });
  }

  @override
  Future<void> removeNotification() async {
    await methodChannel.invokeMethod<void>('removeNotification');
  }

  @override
  Future<void> startForeground({bool notificationsEnabled = true}) async {
    await methodChannel.invokeMethod<void>('startForeground', {
      'notificationsEnabled': notificationsEnabled,
    });
  }

  @override
  Future<void> showNotification({
    required String status,
    required String ip,
    required String duration,
  }) async {
    await methodChannel.invokeMethod<void>('showNotification', {
      'status': status,
      'ip': ip,
      'duration': duration,
    });
  }
}
