import 'dart:async';
import 'package:astral/core/models/server_mod.dart';
import 'package:astral/shared/utils/network/ping_util.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:isar_community/isar.dart';

/// 服务器在线状态枚举
enum ServerStatus {
  online, // 在线 - 绿色
  offline, // 离线 - 红色
  inUse, // 使用中 - 蓝色
  unknown, // 未知 - 灰色（初始状态）
}

class ServerStatusState {
  // 服务器状态映射 <serverId, ServerStatus>
  final serverStatuses = signal<Map<Id, ServerStatus>>({});

  // 当前使用的服务器ID列表
  final activeServerIds = signal<Set<Id>>({});

  // 定时器
  Timer? _checkTimer;

  // 初始化定期检查
  void startPeriodicCheck(List<ServerMod> servers, Duration interval) {
    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(interval, (_) {
      checkServersStatus(servers);
    });
    // 立即执行一次检查
    checkServersStatus(servers);
  }

  // 停止定期检查
  void stopPeriodicCheck() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  // 检查所有服务器状态
  Future<void> checkServersStatus(List<ServerMod> servers) async {
    final Map<Id, ServerStatus> newStatuses = {};
    final activeIds = activeServerIds.value;

    for (final server in servers) {
      // 如果服务器正在使用中，直接设置为蓝色
      if (activeIds.contains(server.id)) {
        newStatuses[server.id] = ServerStatus.inUse;
        continue;
      }

      // 否则检测在线状态
      final isOnline = await _checkServerOnline(server);
      newStatuses[server.id] =
          isOnline ? ServerStatus.online : ServerStatus.offline;
    }

    serverStatuses.value = newStatuses;
  }

  // 检测单个服务器是否在线
  Future<bool> _checkServerOnline(ServerMod server) async {
    try {
      final latency = await PingUtil.ping(server.url);
      return latency != null;
    } catch (e) {
      return false;
    }
  }

  // 设置活跃的服务器ID（正在使用的服务器）
  void setActiveServers(Set<Id> serverIds) {
    activeServerIds.value = serverIds;
  }

  // 获取服务器状态
  ServerStatus getServerStatus(Id serverId) {
    return serverStatuses.value[serverId] ?? ServerStatus.unknown;
  }

  // 清理资源
  void dispose() {
    stopPeriodicCheck();
  }
}
