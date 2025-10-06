import 'package:astral/data/models/server_model.dart';
import 'package:astral/data/repositories/server_repository.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:flutter/foundation.dart';

/// 服务器列表状态管理类 - 新版本
/// 使用ServerRepository管理服务器节点的增删改查操作
class ServerListState {
  static final ServerListState _instance = ServerListState._();
  factory ServerListState() => _instance;

  final ServerRepository _repository = ServerRepository();

  /// 服务器节点列表
  final serverList = signal<List<ServerModel>>([]);

  /// 当前选中的服务器ID
  final selectedServerId = signal<int?>(null);

  /// 是否正在加载
  final isLoading = signal<bool>(false);

  /// 错误信息
  final errorMessage = signal<String?>(null);

  ServerListState._();

  /// 初始化 - 加载服务器列表
  Future<void> initialize() async {
    try {
      setLoading(true);
      clearError();
      
      final servers = await _repository.getAllServers();
      serverList.value = servers;
      
      // 如果有默认服务器，设置为选中状态
      final defaultServer = await _repository.getDefaultServer();
      if (defaultServer != null) {
        selectedServerId.value = defaultServer.id;
      }
      
      if (kDebugMode) {
        print('[ServerListState] 初始化完成，加载了${servers.length}个服务器');
      }
    } catch (e) {
      setError('初始化服务器列表失败: $e');
      if (kDebugMode) {
        print('[ServerListState] 初始化失败: $e');
      }
    } finally {
      setLoading(false);
    }
  }

  /// 同步加载服务器列表（从缓存）
  void loadServersSync() {
    try {
      final servers = _repository.getAllServersSync();
      serverList.value = servers;
      
      // 如果有默认服务器，设置为选中状态
      final defaultServer = _repository.getDefaultServerSync();
      if (defaultServer != null) {
        selectedServerId.value = defaultServer.id;
      }
      
      if (kDebugMode) {
        print('[ServerListState] 同步加载了${servers.length}个服务器');
      }
    } catch (e) {
      setError('同步加载服务器列表失败: $e');
      if (kDebugMode) {
        print('[ServerListState] 同步加载失败: $e');
      }
    }
  }

  /// 添加服务器
  Future<void> addServer(ServerModel server) async {
    try {
      setLoading(true);
      clearError();
      
      await _repository.addServer(server);
      await _refreshServerList();
      
      if (kDebugMode) {
        print('[ServerListState] 添加服务器成功: ${server.name}');
      }
    } catch (e) {
      setError('添加服务器失败: $e');
      if (kDebugMode) {
        print('[ServerListState] 添加服务器失败: $e');
      }
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// 更新服务器
  Future<void> updateServer(ServerModel server) async {
    try {
      setLoading(true);
      clearError();
      
      await _repository.updateServer(server);
      await _refreshServerList();
      
      if (kDebugMode) {
        print('[ServerListState] 更新服务器成功: ${server.name}');
      }
    } catch (e) {
      setError('更新服务器失败: $e');
      if (kDebugMode) {
        print('[ServerListState] 更新服务器失败: $e');
      }
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// 删除服务器
  Future<void> removeServer(int id) async {
    try {
      setLoading(true);
      clearError();
      
      await _repository.deleteServer(id.toString());
      
      // 如果删除的是当前选中的服务器，清除选中状态
      if (selectedServerId.value == id) {
        selectedServerId.value = null;
      }
      
      await _refreshServerList();
      
      if (kDebugMode) {
        print('[ServerListState] 删除服务器成功: $id');
      }
    } catch (e) {
      setError('删除服务器失败: $e');
      if (kDebugMode) {
        print('[ServerListState] 删除服务器失败: $e');
      }
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// 清空所有服务器
  Future<void> clearAllServers() async {
    try {
      setLoading(true);
      clearError();
      
      await _repository.clearAllServers();
      serverList.value = [];
      selectedServerId.value = null;
      
      if (kDebugMode) {
        print('[ServerListState] 清空所有服务器成功');
      }
    } catch (e) {
      setError('清空服务器失败: $e');
      if (kDebugMode) {
        print('[ServerListState] 清空服务器失败: $e');
      }
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// 设置选中的服务器
  Future<void> setSelectedServer(int? serverId) async {
    try {
      if (serverId != null) {
        // 验证服务器是否存在
        final server = await _repository.getServerByIntId(serverId);
        if (server == null) {
          setError('服务器不存在: $serverId');
          return;
        }
        
        // 设置为默认服务器
        await _repository.setDefaultServer(serverId.toString());
      }
      
      selectedServerId.value = serverId;
      
      if (kDebugMode) {
        print('[ServerListState] 设置选中服务器: $serverId');
      }
    } catch (e) {
      setError('设置选中服务器失败: $e');
      if (kDebugMode) {
        print('[ServerListState] 设置选中服务器失败: $e');
      }
    }
  }

  /// 获取选中的服务器
  ServerModel? get selectedServer {
    final id = selectedServerId.value;
    if (id != null) {
      return serverList.value.firstWhere(
        (server) => server.id == id,
        orElse: () => throw StateError('服务器不存在'),
      );
    }
    return null;
  }

  /// 根据协议类型筛选服务器
  List<ServerModel> getServersByProtocol(ProtocolType protocol) {
    return serverList.value.where((server) => server.protocol == protocol).toList();
  }

  /// 搜索服务器（根据名称或URL）
  List<ServerModel> searchServers(String query) {
    if (query.isEmpty) return serverList.value;
    
    final lowerQuery = query.toLowerCase();
    return serverList.value.where((server) {
      return server.name.toLowerCase().contains(lowerQuery) ||
             server.url.toLowerCase().contains(lowerQuery) ||
             (server.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// 根据启用状态筛选服务器
  List<ServerModel> getEnabledServers() {
    return serverList.value.where((server) => server.enable).toList();
  }

  /// 根据ID获取服务器
  ServerModel? getServerById(int id) {
    try {
      return serverList.value.firstWhere((server) => server.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 批量添加服务器
  Future<void> addServers(List<ServerModel> servers) async {
    try {
      setLoading(true);
      clearError();
      
      for (final server in servers) {
        await _repository.addServer(server);
      }
      
      await _refreshServerList();
      
      if (kDebugMode) {
        print('[ServerListState] 批量添加${servers.length}个服务器成功');
      }
    } catch (e) {
      setError('批量添加服务器失败: $e');
      if (kDebugMode) {
        print('[ServerListState] 批量添加服务器失败: $e');
      }
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// 导出服务器配置
  Future<String> exportServers() async {
    try {
      return await _repository.exportServers();
    } catch (e) {
      setError('导出服务器配置失败: $e');
      if (kDebugMode) {
        print('[ServerListState] 导出服务器配置失败: $e');
      }
      rethrow;
    }
  }

  /// 导入服务器配置
  Future<void> importServers(String jsonData, {bool merge = true}) async {
    try {
      setLoading(true);
      clearError();
      
      await _repository.importServers(jsonData, merge: merge);
      await _refreshServerList();
      
      if (kDebugMode) {
        print('[ServerListState] 导入服务器配置成功');
      }
    } catch (e) {
      setError('导入服务器配置失败: $e');
      if (kDebugMode) {
        print('[ServerListState] 导入服务器配置失败: $e');
      }
      rethrow;
    } finally {
      setLoading(false);
    }
  }

  /// 获取服务器统计信息
  Future<Map<String, dynamic>> getServerStats() async {
    try {
      return await _repository.getServerStats();
    } catch (e) {
      setError('获取服务器统计信息失败: $e');
      if (kDebugMode) {
        print('[ServerListState] 获取服务器统计信息失败: $e');
      }
      return {'error': e.toString()};
    }
  }

  /// 刷新服务器列表
  Future<void> _refreshServerList() async {
    final servers = await _repository.getAllServers();
    serverList.value = servers;
  }

  /// 设置加载状态
  void setLoading(bool loading) {
    isLoading.value = loading;
  }

  /// 设置错误信息
  void setError(String? error) {
    errorMessage.value = error;
  }

  /// 清除错误信息
  void clearError() {
    errorMessage.value = null;
  }

  /// 获取服务器总数
  int get serverCount => serverList.value.length;

  /// 检查是否有服务器
  bool get hasServers => serverList.value.isNotEmpty;

  /// 检查是否有启用的服务器
  bool get hasEnabledServers => serverList.value.any((server) => server.enable);

  /// 获取启用的服务器数量
  int get enabledServerCount => serverList.value.where((server) => server.enable).length;

  /// 获取按排序顺序排列的服务器列表
  List<ServerModel> get sortedServers {
    final servers = List<ServerModel>.from(serverList.value);
    servers.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return servers;
  }

  /// 重新排序服务器
  Future<void> reorderServers(List<ServerModel> reorderedServers) async {
    try {
      setLoading(true);
      clearError();
      
      // 更新排序顺序
      for (int i = 0; i < reorderedServers.length; i++) {
        final server = reorderedServers[i].copyWith(
          sortOrder: i,
          updatedAt: DateTime.now(),
        );
        await _repository.updateServer(server);
      }
      
      await _refreshServerList();
      
      if (kDebugMode) {
        print('[ServerListState] 重新排序服务器成功');
      }
    } catch (e) {
      setError('重新排序服务器失败: $e');
      if (kDebugMode) {
        print('[ServerListState] 重新排序服务器失败: $e');
      }
      rethrow;
    } finally {
      setLoading(false);
    }
  }
}
