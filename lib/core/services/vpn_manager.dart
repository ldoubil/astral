import 'dart:io';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/shared/utils/network/ip_utils.dart';
import 'package:vpn_service_plugin/vpn_service_plugin.dart';
import 'package:astral/src/rust/api/simple.dart';

/// VPN管理器（仅Android）
class VpnManager {
  static VpnManager? _instance;
  final VpnServicePlugin? _plugin;

  VpnManager._() : _plugin = Platform.isAndroid ? VpnServicePlugin() : null;

  /// 获取单例实例
  static VpnManager get instance {
    _instance ??= VpnManager._();
    return _instance!;
  }

  /// 获取VPN插件实例（用于监听事件）
  VpnServicePlugin? get plugin => _plugin;

  /// 准备VPN服务（请求权限）
  Future<void> prepare() async {
    if (_plugin == null) return;
    await _plugin!.prepareVpn();
  }

  /// 启动VPN服务
  ///
  /// [ipv4Addr] IPv4地址，如果不包含掩码会自动添加 /24
  /// [mtu] 最大传输单元，默认1300
  /// [disallowedApplications] 不使用VPN的应用列表
  Future<void> start({
    required String ipv4Addr,
    int mtu = 1300,
    List<String> disallowedApplications = const ['com.kevin.astral'],
  }) async {
    if (_plugin == null) return;
    if (ipv4Addr.isEmpty || ipv4Addr == "") return;

    // 确保IP地址格式为"IP/掩码"
    String finalIpv4 = ipv4Addr;
    if (!ipv4Addr.contains('/')) {
      finalIpv4 = "$ipv4Addr/24";
    }

    // 获取有效的VPN路由
    final routes =
        ServiceManager().vpnState.customVpn.value
            .where((route) => isValidCIDR(route))
            .toList();

    await _plugin!.startVpn(
      ipv4Addr: finalIpv4,
      mtu: mtu,
      routes: routes,
      disallowedApplications: disallowedApplications,
    );
  }

  /// 停止VPN服务
  Future<void> stop() async {
    if (_plugin == null) return;
    await _plugin!.stopVpn();
  }

  /// 设置TUN文件描述符
  ///
  /// 在VPN服务启动后调用，将文件描述符传递给Rust层
  Future<void> configureTunFd(int fd) async {
    await setTunFd(fd: fd);
  }
}
