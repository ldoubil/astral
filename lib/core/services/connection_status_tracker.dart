import 'dart:async';
import 'dart:convert';

import 'package:astral/core/services/connection_network_monitor.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/states/connection_state.dart';
import 'package:astral/src/rust/api/simple.dart';

/// Connection wait / timeout / status-check timers for [ServerConnectionManager].
///
/// Orchestration (connect / disconnect / cancel) stays on the manager;
/// this class only owns the timers and polling used while connecting.
class ConnectionStatusTracker {
  Timer? _statusCheckTimer;
  Timer? _timeoutTimer;

  /// Called when the connection timeout fires while still `connecting`.
  Future<void> Function()? onTimeout;

  /// Called when status polling detects a successful connection.
  Future<void> Function()? onConnected;

  void cancelAll() {
    _statusCheckTimer?.cancel();
    _timeoutTimer?.cancel();
    _statusCheckTimer = null;
    _timeoutTimer = null;
  }

  void cancelTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  /// 等待连接结果
  Future<bool> waitForConnectionResult() async {
    final services = ServiceManager();

    // 等待最多30秒来确认连接状态
    for (int i = 0; i < 30; i++) {
      await Future.delayed(Duration(seconds: 1));

      final currentState = services.connectionState.connectionState.value;
      if (currentState == CoState.connected) {
        return true;
      } else if (currentState == CoState.idle) {
        return false;
      }
    }

    // 超时仍未确定状态，视为失败
    return false;
  }

  /// 设置连接超时
  void setupConnectionTimeout({required int timeoutSeconds}) {
    _timeoutTimer = Timer(Duration(seconds: timeoutSeconds), () {
      if (ServiceManager().connectionState.connectionState.value ==
          CoState.connecting) {
        onTimeout?.call();
      }
    });
  }

  /// 启动连接状态检查
  void startConnectionStatusCheck() {
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) async {
      if (ServiceManager().connectionState.connectionState.value !=
          CoState.connecting) {
        timer.cancel();
        return;
      }

      final isConnected = await checkConnectionStatus();
      if (isConnected) {
        timer.cancel();
        await onConnected?.call();
      }
    });
  }

  /// 检查连接状态
  Future<bool> checkConnectionStatus() async {
    try {
      final runningInfo = await getRunningInfo();
      if (runningInfo.isEmpty) return false;

      final data = jsonDecode(runningInfo);
      if (data == null || data is! Map<String, dynamic>) return false;

      final ipv4Address = ConnectionNetworkMonitor.extractIpv4Address(data);
      if (ipv4Address != "0.0.0.0" &&
          ServiceManager().networkConfigState.ipv4.value != ipv4Address) {
        ServiceManager().networkConfig.updateIpv4(ipv4Address);
      }

      return ipv4Address != "0.0.0.0";
    } catch (e) {
      return false;
    }
  }
}
