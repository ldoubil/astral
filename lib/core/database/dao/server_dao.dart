import 'package:astral/core/models/server_mod.dart';
import 'package:isar_community/isar.dart';

class ServerDao {
  final Isar _isar;
  bool _initialized = false;

  ServerDao(this._isar);

  Future<void> init() async {
    if (_initialized) return;

    // 如果没有初始服务器数据，添加默认服务器
    if (await _isar.serverMods.count() == 0) {
      final defaultServers = [
        ServerMod(
          name: "[小探][可中转A]",
          url: "js.629957.xyz:11012",
          enable: false,
          tcp: true,
          udp: false,
          ws: false,
          wss: false,
          quic: false,
          wg: false,
        ),
        ServerMod(
          name: "[小探][可中转B]",
          url: "nmg.629957.xyz:11010",
          enable: false,
          tcp: true,
          udp: false,
          ws: false,
          wss: false,
          quic: false,
          wg: false,
        ),
        ServerMod(
          name: "[小探][不可中转][faketcp]",
          url: "nmg.629957.xyz:11010",
          enable: false,
          tcp: false,
          faketcp: true,
          udp: false,
          ws: false,
          wss: false,
          quic: false,
          wg: false,
        ),
      ];

      await _isar.writeTxn(() async {
        for (final server in defaultServers) {
          await _isar.serverMods.put(server);
        }
      });
    }

    _initialized = true;
  }

  // 添加服务器
  Future<int> addServer(ServerMod server) async {
    return await _isar.writeTxn(() async {
      return await _isar.serverMods.put(server);
    });
  }

  // 获取所有服务器
  Future<List<ServerMod>> getAllServers() async {
    final servers = await _isar.serverMods.where().findAll();
    servers.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return servers;
  }

  // 更新服务器
  Future<int> updateServer(ServerMod server) async {
    return await _isar.writeTxn(() async {
      return await _isar.serverMods.put(server);
    });
  }

  // 更新服务器顺序
  Future<void> updateServersOrder(List<ServerMod> orderedServers) async {
    return await _isar.writeTxn(() async {
      for (int i = 0; i < orderedServers.length; i++) {
        final server = orderedServers[i];
        server.sortOrder = i;
        await _isar.serverMods.put(server);
      }
    });
  }

  // 删除服务器 by object
  Future<bool> deleteServer(ServerMod server) async {
    return await _isar.writeTxn(() async {
      return await _isar.serverMods.delete(server.id);
    });
  }
}
