import 'package:astral/k/states/connection_state.dart';
import 'package:astral/k/repositories/connection_repository.dart';
import 'package:astral/k/models/net_config.dart';
import 'package:astral/src/rust/api/simple.dart';

/// 连接服务：协调ConnectionState和ConnectionRepository
class ConnectionService {
  final ConnectionState state;
  final ConnectionRepository _repository;

  ConnectionService(this.state, this._repository);

  // ========== 初始化 ==========

  Future<void> init() async {
    final connections = await _repository.getConnectionManagers();
    state.setConnections(connections);
  }

  // ========== 业务方法 ==========

  Future<void> updateConnections() async {
    final connections = await _repository.getConnectionManagers();
    state.setConnections(connections);
  }

  Future<void> addConnection(ConnectionManager manager) async {
    await _repository.addConnectionManager(manager);
    await updateConnections();
  }

  Future<void> updateConnection(int index, ConnectionManager manager) async {
    await _repository.updateConnectionManager(index, manager);
    await updateConnections();
  }

  Future<void> removeConnection(int index) async {
    await _repository.removeConnectionManager(index);
    await updateConnections();
  }

  Future<void> updateConnectionEnabled(int index, bool enabled) async {
    await _repository.updateConnectionManagerEnabled(index, enabled);
    await updateConnections();
  }

  // ========== 状态管理 ==========

  void setConnecting() {
    state.setConnecting();
  }

  void setConnected() {
    state.setConnected();
  }

  void setIdle() {
    state.setIdle();
  }

  void setNetStatus(KVNetworkStatus? status) {
    state.setNetStatus(status);
  }
}
