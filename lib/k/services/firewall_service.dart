import 'package:astral/k/states/firewall_state.dart';
import 'package:astral/src/rust/api/firewall.dart';

/// 防火墙服务：协调FirewallState和系统API
class FirewallService {
  final FirewallState state;

  FirewallService(this.state);

  // ========== 初始化 ==========

  Future<void> init() async {
    await updateFirewallStatus();
  }

  // ========== 业务方法 ==========

  Future<void> setFirewall(bool value) async {
    state.setFirewallStatus(value);
    await setFirewallStatus(profileIndex: 1, enable: value);
    await setFirewallStatus(profileIndex: 2, enable: value);
    await setFirewallStatus(profileIndex: 3, enable: value);
  }

  Future<void> updateFirewallStatus() async {
    final status =
        await getFirewallStatus(profileIndex: 1) &&
        await getFirewallStatus(profileIndex: 2) &&
        await getFirewallStatus(profileIndex: 3);

    state.setFirewallStatus(status);
  }
}
