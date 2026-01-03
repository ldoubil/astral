import 'package:astral/k/database/app_data.dart';
import 'package:astral/k/models/server_mod.dart';

/// 服务器管理的数据持久化
class ServerRepository {
  final AppDatabase _db;

  ServerRepository(this._db);

  // ========== 查询操作 ==========

  Future<List<ServerMod>> getAllServers() async {
    return await _db.ServerSetting.getAllServers();
  }

  Future<ServerMod?> getServerById(int id) async {
    return await _db.ServerSetting.getServerById(id);
  }

  Future<List<ServerMod>> getEnabledServers() async {
    final all = await getAllServers();
    return all.where((s) => s.enable).toList();
  }

  // ========== 写入操作 ==========

  Future<void> addServer(ServerMod server) async {
    await _db.ServerSetting.addServer(server);
  }

  Future<void> updateServer(ServerMod server) async {
    await _db.ServerSetting.updateServer(server);
  }

  Future<void> deleteServer(ServerMod server) async {
    await _db.ServerSetting.deleteServer(server);
  }

  Future<void> deleteServerById(int id) async {
    await _db.ServerSetting.deleteServerid(id);
  }

  Future<void> updateServersOrder(List<ServerMod> servers) async {
    await _db.ServerSetting.updateServersOrder(servers);
  }

  // ========== 批量操作 ==========

  Future<void> batchUpdateEnabled(List<int> ids, bool enabled) async {
    for (final id in ids) {
      final server = await getServerById(id);
      if (server != null) {
        server.enable = enabled;
        await updateServer(server);
      }
    }
  }

  Future<void> batchDelete(List<int> ids) async {
    for (final id in ids) {
      await deleteServerById(id);
    }
  }
}
