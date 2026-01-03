import 'package:astral/k/models/net_config.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 连接状态
enum CoState { idle, connecting, connected }

class ConnectionState {
  // 连接管理器列表
  final connections = signal<List<ConnectionManager>>([]);

  // 连接状态
  final connectionState = signal(CoState.idle);

  // 是否正在连接
  final isConnecting = signal(false);

  // 网络状态
  final netStatus = signal<KVNetworkStatus?>(null);

  // 状态更新方法
  void setConnections(List<ConnectionManager> list) {
    connections.value = list;
  }

  void addConnection(ConnectionManager conn) {
    final list = List<ConnectionManager>.from(connections.value);
    list.add(conn);
    connections.value = list;
  }

  void removeConnection(int index) {
    final list = List<ConnectionManager>.from(connections.value);
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      connections.value = list;
    }
  }

  void updateConnection(int index, ConnectionManager conn) {
    final list = List<ConnectionManager>.from(connections.value);
    if (index >= 0 && index < list.length) {
      list[index] = conn;
      connections.value = list;
    }
  }

  void setState(CoState newState) {
    connectionState.value = newState;
    isConnecting.value = newState == CoState.connecting;
  }

  void setConnecting() => setState(CoState.connecting);
  void setConnected() => setState(CoState.connected);
  void setIdle() => setState(CoState.idle);

  void setNetStatus(KVNetworkStatus? status) {
    netStatus.value = status;
  }

  // Computed Signals
  late final isConnected = computed(
    () => connectionState.value == CoState.connected,
  );
  late final isIdle = computed(() => connectionState.value == CoState.idle);
  late final canConnect = computed(() => connectionState.value == CoState.idle);
}
