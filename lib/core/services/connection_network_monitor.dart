import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:astral/core/services/notification_service.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/states/connection_state.dart';
import 'package:astral/shared/utils/network/ip_utils.dart';
import 'package:astral/src/rust/api/simple.dart';

/// 连接成功后的网络状态轮询：IPv4 刷新、子网代理 CIDR、通知/桌面贴片时长。
class ConnectionNetworkMonitor {
  Timer? _timer;
  bool _busy = false;
  int connectionDuration = 0;

  bool get isActive => _timer != null;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      unawaited(tick());
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _busy = false;
  }

  void resetDuration() {
    connectionDuration = 0;
  }

  Future<void> tick() async {
    if (_busy) return;
    _busy = true;
    connectionDuration++;

    try {
      try {
        final runningInfo = await getRunningInfo();
        final data = jsonDecode(runningInfo);
        final ipv4 = extractIpv4Address(data);
        if (isValidRuntimeIpv4(ipv4)) {
          ServiceManager().networkConfig.updateIpv4(ipv4);
        }
      } catch (_) {
        // Keep last known IP if runtime info cannot be read.
      }

      try {
        final netStatus = await getNetworkStatus();
        final previousProxyCidrs = extractProxyCidrs();
                  ServiceManager().connectionState.netStatus.value = netStatus;

        // 当 peer 子网代理路由发生变化时，刷新 Android VPN 路由。
        if (Platform.isAndroid &&
            !ServiceManager().networkConfigState.noTun.value) {
          final currentProxyCidrs = extractProxyCidrs();
          final changed =
              currentProxyCidrs.toSet().difference(previousProxyCidrs.toSet()).isNotEmpty ||
              previousProxyCidrs.toSet().difference(currentProxyCidrs.toSet()).isNotEmpty;
          if (changed) {
            await ServiceManager().vpn.start(
              ipv4Addr: ServiceManager().networkConfigState.ipv4.value,
              mtu: ServiceManager().networkConfigState.mtu.value,
              proxyCidrs: currentProxyCidrs,
            );
          }
        }
      } catch (_) {
        // Notification updates should continue even if network stats fail.
      }

      if (Platform.isAndroid &&
          ServiceManager().connectionState.connectionState.value ==
              CoState.connected) {
        final formattedDuration =
            NotificationService.formatDuration(connectionDuration);

        await ServiceManager().widgets.updateDuration(formattedDuration);

        if (ServiceManager()
            .appSettingsState
            .enableConnectionNotification
            .value) {
          await ServiceManager().notifications.showConnectionNotification(
            status: '已连接',
            ip: notificationDisplayIp(),
            duration: formattedDuration,
          );
        }
      }
    } finally {
      _busy = false;
    }
  }

  /// 从网络状态中提取子网代理路由
  static List<String> extractProxyCidrs() {
    final netStatus = ServiceManager().connectionState.netStatus.value;
    if (netStatus == null) return [];

    final cidrs = <String>[];
    for (final node in netStatus.nodes) {
      for (final cidr in node.proxyCidrs) {
        if (isValidCIDR(cidr) && !cidrs.contains(cidr)) {
          cidrs.add(cidr);
        }
      }
    }
    return cidrs;
  }

  /// 提取 IPv4 地址
  static String extractIpv4Address(Map<String, dynamic> data) {
    final virtualIpv4 = data['my_node_info']?['virtual_ipv4'];
    final addr =
        virtualIpv4?.isEmpty ?? true ? 0 : virtualIpv4['address']['addr'] ?? 0;
    return intToIp(addr);
  }

  static bool isValidRuntimeIpv4(String ip) {
    return ip.isNotEmpty && ip != '0.0.0.0';
  }

  static String notificationDisplayIp() {
    final ipv4 = ServiceManager().networkConfigState.ipv4.value;
    return isValidRuntimeIpv4(ipv4) ? ipv4 : '获取中...';
  }
}
