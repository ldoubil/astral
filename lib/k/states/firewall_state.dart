import 'package:signals_flutter/signals_flutter.dart';
import 'package:astral/k/models/forwarding.dart';

/// 防火墙相关状态
class FirewallState {
  // 防火墙状态
  final firewallStatus = signal(false);

  // WFP状态
  final wfpStatus = signal(false);

  // 自动设置MTU
  final autoSetMTU = signal(true);

  // 连接转发规则
  final connections = signal<List<ForwardingConnection>>([]);

  // 状态更新方法
  void setFirewallStatus(bool value) {
    firewallStatus.value = value;
  }

  void setWfpStatus(bool value) {
    wfpStatus.value = value;
  }

  void setAutoSetMTU(bool value) {
    autoSetMTU.value = value;
  }

  void toggleFirewall() {
    firewallStatus.value = !firewallStatus.value;
  }

  void toggleAutoSetMTU() {
    autoSetMTU.value = !autoSetMTU.value;
  }

  // Computed Signal
  late final isFirewallEnabled = computed(() => firewallStatus.value);
}
