import 'package:astral/core/database/app_data.dart';
import 'package:astral/core/models/server_mod.dart';

/// 服务器管理的数据持久化
class ServerRepository {
  final AppDatabase _db;

  ServerRepository(this._db);

  Future<List<ServerMod>> getAllServers() async {
    return await _db.ServerSetting.getAllServers();
  }

  Future<void> addServer(ServerMod server) async {
    await _db.ServerSetting.addServer(server);
  }

  Future<void> updateServer(ServerMod server) async {
    await _db.ServerSetting.updateServer(server);
  }

  Future<void> deleteServer(ServerMod server) async {
    await _db.ServerSetting.deleteServer(server);
  }

  Future<void> updateServersOrder(List<ServerMod> servers) async {
    await _db.ServerSetting.updateServersOrder(servers);
  }
}
