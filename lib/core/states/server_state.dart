import 'package:astral/core/models/server_mod.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 服务器状态（纯Signal）
class ServerState {
  // 服务器列表
  final servers = signal<List<ServerMod>>([]);

  // 状态更新方法
  void setServers(List<ServerMod> serverList) {
    servers.value = serverList;
  }
}
