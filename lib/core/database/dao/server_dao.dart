import 'package:astral/core/models/server_mod.dart';
import 'package:isar_community/isar.dart';

class ServerDao {
  final Isar _isar;
  bool _initialized = false;

  /// 已废弃的服务器域名，启动时自动删除包含这些域名的服务器
  static const List<String> _obsoleteServerPatterns = [
    'turn.bj.629957.xyz',
    'turn.js.629957.xyz',
    'turn.hn.629957.xyz',
    'turn.hb.629957.xyz',
    'turn.nmg.629957.xyz',
    'bj.629957.xyz',
    'nmg.629957.xyz',
    'hn.629957.xyz',
    'hb.629957.xyz',
  ];

  ServerDao(this._isar);

  Future<void> init() async {
    if (_initialized) return;

    // 清理已废弃的服务器
    await _cleanupObsoleteServers();

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
      ];

      await _isar.writeTxn(() async {
        for (final server in defaultServers) {
          await _isar.serverMods.put(server);
        }
      });
    }

    _initialized = true;
  }

  /// 删除所有 URL 中包含废弃域名的服务器
  Future<void> _cleanupObsoleteServers() async {
    final allServers = await _isar.serverMods.where().findAll();
    final toDelete =
        allServers.where((server) {
          final url = server.url;
          return _obsoleteServerPatterns.any(
            (pattern) => url.contains(pattern),
          );
        }).toList();

    if (toDelete.isNotEmpty) {
      await _isar.writeTxn(() async {
        for (final server in toDelete) {
          await _isar.serverMods.delete(server.id);
        }
      });
    }
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
