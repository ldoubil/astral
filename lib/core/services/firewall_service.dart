import 'package:astral/core/states/firewall_state.dart';
import 'package:astral/src/rust/api/firewall.dart';
import 'package:flutter/foundation.dart';

/// 防火墙服务：协调FirewallState和系统API
class FirewallService {
  final FirewallState state;

  FirewallService(this.state);

  // ========== 初始化 ==========

  Future<void> init() async {
    try {
      await updateFirewallStatus();
    } catch (e) {
      // 防火墙服务初始化失败不应该导致应用崩溃
      // 可能的原因：权限不足、系统关机、服务不可用等
      debugPrint('警告: 防火墙服务初始化失败 - $e');
      // 设置默认状态为 false
      state.setFirewallStatus(false);
    }
  }

  // ========== 业务方法 ==========

  Future<void> setFirewall(bool value) async {
    try {
      state.setFirewallStatus(value);
      await setFirewallStatus(profileIndex: 1, enable: value);
      await setFirewallStatus(profileIndex: 2, enable: value);
      await setFirewallStatus(profileIndex: 3, enable: value);
    } catch (e) {
      debugPrint('设置防火墙失败: $e');
      // 如果设置失败，回滚状态
      await updateFirewallStatus();
      rethrow;
    }
  }

  Future<void> updateFirewallStatus() async {
    try {
      final status =
          await getFirewallStatus(profileIndex: 1) &&
          await getFirewallStatus(profileIndex: 2) &&
          await getFirewallStatus(profileIndex: 3);

      state.setFirewallStatus(status);
    } catch (e) {
      debugPrint('获取防火墙状态失败: $e');
      // 如果无法获取状态，设置为 false（安全起见）
      state.setFirewallStatus(false);
      // 这里不抛出异常，让应用继续运行
    }
  }
}
