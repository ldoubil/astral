import 'package:astral/core/states/server_state.dart';
import 'package:astral/core/repositories/server_repository.dart';
import 'package:astral/core/constants/servers.dart';

/// 服务器服务：协调ServerState和ServerRepository（现在使用固定配置）
class ServerService {
  final ServerState state;
  final ServerRepository _repository;

  ServerService(this.state, this._repository);

  // ========== 初始化 ==========

  Future<void> init() async {
    // 从数据库读取已启用的服务器索引列表
    final enabledIndices = await _repository.getEnabledServerIndices();
    state.setEnabledServerIndices(enabledIndices);
  }

  // ========== 业务方法 ==========

  /// 获取所有服务器配置（固定常量列表）
  List<ServerConfig> getAllServers() {
    return state.allServers;
  }

  /// 获取已启用的服务器配置
  List<ServerConfig> getEnabledServers() {
    return state.enabledServers;
  }

  /// 切换服务器启用状态
  Future<void> toggleServerEnabled(int index, bool enabled) async {
    state.toggleServerEnabled(index, enabled);
    await _repository.toggleServerEnabled(index, enabled);
  }

  /// 设置已启用的服务器索引列表
  Future<void> setEnabledServerIndices(List<int> indices) async {
    state.setEnabledServerIndices(indices);
    await _repository.setEnabledServerIndices(indices);
  }

  /// 检查某个服务器是否已启用
  bool isServerEnabled(int index) {
    return state.isServerEnabled(index);
  }
}
