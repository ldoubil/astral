import 'package:astral/core/models/server_mod.dart';
import 'package:isar_community/isar.dart';

class ServerCz {
  final Isar _isar;
  bool _initialized = false;

  ServerCz(this._isar);

  Future<void> init() async {
    if (_initialized) return;

    // 如果没有初始服务器数据，添加默认服务器
    if (await _isar.serverMods.count() == 0) {
      final defaultServers = [
        ServerMod(
          name: "[小探赞助][北京]",
          url: "turn.bj.629957.xyz:11010",
          enable: true,
          tcp: true,
          udp: false,
          ws: false,
          wss: false,
          quic: false,
          wg: false,
        ),
        ServerMod(
          name: "[小探赞助][江苏]",
          url: "turn.js.629957.xyz:11012",
          enable: true,
          tcp: true,
          udp: false,
          ws: false,
          wss: false,
          quic: false,
          wg: false,
        ),
        ServerMod(
          name: "[小探赞助][内蒙古]",
          url: "turn.nmg.629957.xyz:11010",
          enable: true,
          tcp: true,
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

  // 设置是否启用
  Future<int> setServerEnable(ServerMod server, bool enable) async {
    server.enable = enable;
    return await _isar.writeTxn(() async {
      return await _isar.serverMods.put(server);
    });
  }

  // 根据ID获取服务器
  Future<ServerMod?> getServerById(int id) async {
    return await _isar.serverMods.get(id);
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
      // 批量更新所有服务器的排序字段
      for (int i = 0; i < orderedServers.length; i++) {
        final server = orderedServers[i];
        server.sortOrder = i;
        await _isar.serverMods.put(server);
      }
    });
  }

  // 删除服务器 by id
  Future<bool> deleteServerid(int id) async {
    return await _isar.writeTxn(() async {
      return await _isar.serverMods.delete(id);
    });
  }

  // 删除服务器 by object
  Future<bool> deleteServer(ServerMod server) async {
    return await _isar.writeTxn(() async {
      return await _isar.serverMods.delete(server.id);
    });
  }
}
