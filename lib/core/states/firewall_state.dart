import 'package:signals_flutter/signals_flutter.dart';

/// 防火墙相关状态
class FirewallState {
  final firewallStatus = signal(false);

  void setFirewallStatus(bool value) {
    firewallStatus.value = value;
  }
}
