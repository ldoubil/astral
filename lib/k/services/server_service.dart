import 'package:astral/k/states/server_state.dart';
import 'package:astral/k/repositories/server_repository.dart';
import 'package:astral/k/models/server_mod.dart';
import 'package:flutter/foundation.dart';

/// 服务器服务：协调ServerState和ServerRepository
class ServerService {
  final ServerState state;
  final ServerRepository _repository;

  ServerService(this.state, this._repository);

  // ========== 初始化 ==========

  Future<void> init() async {
    final servers = await _repository.getAllServers();
    state.setServers(servers);
  }

  // ========== 业务方法 ==========

  Future<void> addServer(ServerMod server) async {
    try {
      await _repository.addServer(server);
      await _refreshServers();
    } catch (e, stackTrace) {
      debugPrint('添加服务器失败: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> deleteServer(ServerMod server) async {
    await _repository.deleteServer(server);
    await _refreshServers();
  }

  Future<void> deleteServerById(int id) async {
    await _repository.deleteServerById(id);
    await _refreshServers();
  }

  Future<void> updateServer(ServerMod server) async {
    await _repository.updateServer(server);
    await _refreshServers();
  }

  Future<void> reorderServers(List<ServerMod> reorderedServers) async {
    await _repository.updateServersOrder(reorderedServers);
    await _refreshServers();
  }

  Future<void> setServerEnable(ServerMod server, bool enable) async {
    server.enable = enable;
    await _repository.updateServer(server);
    await _refreshServers();
  }

  Future<ServerMod?> getServerById(int id) async {
    return await _repository.getServerById(id);
  }

  Future<List<ServerMod>> getAllServers() async {
    final servers = await _repository.getAllServers();
    state.setServers(servers);
    return servers;
  }

  Future<List<ServerMod>> getEnabledServers() async {
    return await _repository.getEnabledServers();
  }

  // ========== 内部辅助方法 ==========

  Future<void> _refreshServers() async {
    final servers = await _repository.getAllServers();
    state.setServers(servers);
  }
}
