import 'package:astral/core/constants/servers.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 服务器状态（基于固定配置和索引管理）
class ServerState {
  // 已启用的服务器索引列表
  final enabledServerIndices = signal<List<int>>([0, 1, 2]);

  // ========== 计算属性 ==========

  /// 获取所有服务器配置（固定常量）
  List<ServerConfig> get allServers => ServersConstants.servers;

  /// 获取已启用的服务器配置
  List<ServerConfig> get enabledServers {
    return enabledServerIndices.value
        .where((i) => i >= 0 && i < ServersConstants.servers.length)
        .map((i) => ServersConstants.servers[i])
        .toList();
  }

  // ========== 状态更新方法 ==========

  /// 设置已启用的服务器索引列表
  void setEnabledServerIndices(List<int> indices) {
    enabledServerIndices.value = indices;
  }

  /// 切换某个服务器的启用状态
  void toggleServerEnabled(int index, bool enabled) {
    final list = List<int>.from(enabledServerIndices.value);
    if (enabled && !list.contains(index)) {
      list.add(index);
    } else if (!enabled && list.contains(index)) {
      list.remove(index);
    }
    enabledServerIndices.value = list;
  }

  /// 是否启用某个服务器
  bool isServerEnabled(int index) {
    return enabledServerIndices.value.contains(index);
  }
}
