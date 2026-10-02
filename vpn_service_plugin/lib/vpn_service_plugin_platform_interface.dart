import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'vpn_service_plugin_method_channel.dart';

abstract class VpnServicePluginPlatform extends PlatformInterface {
  VpnServicePluginPlatform() : super(token: _token);

  static final Object _token = Object();
  static VpnServicePluginPlatform _instance = MethodChannelVpnServicePlugin();

  static VpnServicePluginPlatform get instance => _instance;

  static set instance(VpnServicePluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Map<String, dynamic>> prepareVpn() {
    throw UnimplementedError('prepareVpn() 未实现.');
  }

  Future<Map<String, dynamic>> startVpn({
    String? ipv4Addr,
    List<String>? routes,
    String? dns,
    List<String>? disallowedApplications,
    int? mtu,
    bool notificationsEnabled = true,
  }) {
    throw UnimplementedError('startVpn() 未实现.');
  }

  Future<void> stopVpn() {
    throw UnimplementedError('stopVpn() 未实现.');
  }

  Future<void> updateNotification({
    required String status,
    required String ip,
    required String duration,
  }) {
    throw UnimplementedError('updateNotification() 未实现.');
  }

  Future<void> removeNotification() {
    throw UnimplementedError('removeNotification() 未实现.');
  }

  Future<void> startForeground({bool notificationsEnabled = true}) {
    throw UnimplementedError('startForeground() 未实现.');
  }

  Future<void> showNotification({
    required String status,
    required String ip,
    required String duration,
  }) {
    throw UnimplementedError('showNotification() 未实现.');
  }
}
