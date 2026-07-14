import 'package:astral/core/database/app_data.dart';
import 'package:astral/core/states/server_state.dart';
import 'package:astral/core/models/server_mod.dart';
import 'package:flutter/foundation.dart';

/// 服务器服务：协调 State 与持久化
class ServerService {
  final ServerState state;
  final AppDatabase _db;

  ServerService(this.state, this._db);

  Future<void> init() async {
    state.setServers(await _db.servers.getAllServers());
  }

  Future<void> addServer(ServerMod server) async {
    try {
      await _db.servers.addServer(server);
      await _refreshServers();
    } catch (e, stackTrace) {
      debugPrint('添加服务器失败: $e\n$stackTrace');
      rethrow;
    }
  }

  Future<void> deleteServer(ServerMod server) async {
    await _db.servers.deleteServer(server);
    await _refreshServers();
  }

  Future<void> updateServer(ServerMod server) async {
    await _db.servers.updateServer(server);
    await _refreshServers();
  }

  Future<void> reorderServers(List<ServerMod> reorderedServers) async {
    await _db.servers.updateServersOrder(reorderedServers);
    await _refreshServers();
  }

  Future<void> setServerEnable(ServerMod server, bool enable) async {
    server.enable = enable;
    await _db.servers.updateServer(server);
    await _refreshServers();
  }

  Future<List<ServerMod>> getAllServers() async {
    final servers = await _db.servers.getAllServers();
    state.setServers(servers);
    return servers;
  }

  Future<void> _refreshServers() async {
    state.setServers(await _db.servers.getAllServers());
  }
}
