import 'package:astral/k/models/server_mod.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 服务器状态（纯Signal）
class ServerState {
  // 服务器列表
  final servers = signal<List<ServerMod>>([]);

  // 状态更新方法
  void setServers(List<ServerMod> serverList) {
    servers.value = serverList;
  }

  void addServer(ServerMod server) {
    final list = List<ServerMod>.from(servers.value);
    list.add(server);
    servers.value = list;
  }

  void removeServer(int id) {
    final list = servers.value.where((s) => s.id != id).toList();
    servers.value = list;
  }

  void updateServer(ServerMod updatedServer) {
    final list =
        servers.value.map((s) {
          return s.id == updatedServer.id ? updatedServer : s;
        }).toList();
    servers.value = list;
  }

  void reorderServers(List<ServerMod> reordered) {
    servers.value = reordered;
  }

  void toggleServerEnabled(int id, bool enabled) {
    final list =
        servers.value.map((s) {
          if (s.id == id) {
            s.enable = enabled;
          }
          return s;
        }).toList();
    servers.value = list;
  }

  // 查询方法
  ServerMod? getServerById(int id) {
    try {
      return servers.value.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  List<ServerMod> getEnabledServers() {
    return servers.value.where((s) => s.enable).toList();
  }
}
