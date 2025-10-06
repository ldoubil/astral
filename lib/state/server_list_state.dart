import 'dart:convert';
import 'package:astral/data/models/server_model.dart';
import 'package:astral/state/typed_persistent_signal.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:flutter/foundation.dart';

/// 服务器列表状态管理类 - 类型化版本
/// 使用类型化存储系统直接管理服务器列表和相关配置
class ServerListState {
  static final ServerListState _instance = ServerListState._();
  factory ServerListState() => _instance;

  /// 服务器节点列表 - 使用类型化持久化列表
  final TypedPersistentListSignal<ServerModel> serverList = typedPersistentList<ServerModel>(
    key: 'servers',
    boxName: 'server_config',
    fromJson: ServerModel.fromJson,
  );

  /// 当前选中的服务器ID - 使用类型化持久化
  final TypedPersistentSignal<String?> selectedServerId = TypedPersistentSignal(
    'selectedServerId',
    null,
    boxName: 'server_config',
  );

  /// 默认服务器ID - 使用类型化持久化
  final TypedPersistentSignal<String?> defaultServerId = TypedPersistentSignal(
    'defaultServerId',
    null,
    boxName: 'server_config',
  );

  /// 服务器标签映射 - 使用类型化持久化 Map
  final TypedPersistentMapSignal<String, List<String>> serverTags = typedPersistentMap<String, List<String>>(
    key: 'serverTags',
    boxName: 'server_config',
  );

  /// 最近使用的服务器列表 - 使用类型化持久化列表
  final TypedPersistentListSignal<String> recentServerIds = typedPersistentList<String>(
    key: 'recentServerIds',
    boxName: 'server_config',
  );

  /// 是否正在加载
  final isLoading = signal<bool>(false);

  /// 错误信息
  final errorMessage = signal<String?>(null);

  ServerListState._();

  /// 初始化 - 服务器列表已自动从存储加载
  Future<void> initialize() async {
    try {
      setLoading(true);
      clearError();
      
      // 类型化存储会自动加载数据，无需手动加载
      if (kDebugMode) {
        print('[ServerListState] 初始化完成，当前有${serverList.value.length}个服务器');
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

  /// 添加服务器
  void addServer(ServerModel server) {
    try {
      clearError();
      
      serverList.add(server);
      
      // 如果是第一个服务器，设为默认
      if (serverList.value.length == 1) {
        setDefaultServer(server.id.toString());
      }
      
      if (kDebugMode) {
        print('[ServerListState] 添加服务器成功: ${server.name}');
      }
    } catch (e) {
      setError('添加服务器失败: $e');
      if (kDebugMode) {
        print('[ServerListState] 添加服务器失败: $e');
      }
      rethrow;
    }
  }

  /// 更新服务器
  void updateServer(ServerModel updatedServer) {
    try {
      clearError();
      
      final currentServers = List<ServerModel>.from(serverList.value);
      final index = currentServers.indexWhere((s) => s.id == updatedServer.id);
      
      if (index != -1) {
        currentServers[index] = updatedServer;
        serverList.value = currentServers;
        
        if (kDebugMode) {
          print('[ServerListState] 更新服务器成功: ${updatedServer.name}');
        }
      } else {
        throw Exception('服务器不存在: ${updatedServer.id}');
      }
    } catch (e) {
      setError('更新服务器失败: $e');
      if (kDebugMode) {
        print('[ServerListState] 更新服务器失败: $e');
      }
      rethrow;
    }
  }

  /// 删除服务器
  void removeServer(String serverId) {
    try {
      clearError();
      
      final currentServers = List<ServerModel>.from(serverList.value);
      final removedServer = currentServers.firstWhere((s) => s.id.toString() == serverId);
      
      currentServers.removeWhere((s) => s.id.toString() == serverId);
      serverList.value = currentServers;
      
      // 如果删除的是当前选中的服务器，清除选中状态
      if (selectedServerId.value == serverId) {
        selectedServerId.value = null;
      }
      
      // 如果删除的是默认服务器，清除默认设置
      if (defaultServerId.value == serverId) {
        defaultServerId.value = null;
        
        // 如果还有其他服务器，设置第一个为默认
        if (currentServers.isNotEmpty) {
          setDefaultServer(currentServers.first.id.toString());
        }
      }
      
      // 从最近使用列表中移除
      removeFromRecentServers(serverId);
      
      // 清理相关标签
      serverTags.removeKey(serverId);
      
      if (kDebugMode) {
        print('[ServerListState] 删除服务器成功: ${removedServer.name}');
      }
    } catch (e) {
      setError('删除服务器失败: $e');
      if (kDebugMode) {
        print('[ServerListState] 删除服务器失败: $e');
      }
      rethrow;
    }
  }

  /// 设置默认服务器
  void setDefaultServer(String serverId) {
    if (serverList.value.any((s) => s.id.toString() == serverId)) {
      defaultServerId.value = serverId;
      selectedServerId.value = serverId;
      
      if (kDebugMode) {
        final server = serverList.value.firstWhere((s) => s.id.toString() == serverId);
        print('[ServerListState] 设置默认服务器: ${server.name} (${server.id})');
      }
    }
  }

  /// 获取默认服务器
  ServerModel? getDefaultServer() {
    if (defaultServerId.value != null) {
      try {
        return serverList.value.firstWhere((s) => s.id.toString() == defaultServerId.value);
      } catch (e) {
        // 如果找不到默认服务器，清除设置
        defaultServerId.value = null;
      }
    }
    return null;
  }

  /// 添加到最近使用列表
  void addToRecentServers(String serverId) {
    final currentRecent = List<String>.from(recentServerIds.value);
    
    // 移除已存在的项目
    currentRecent.remove(serverId);
    
    // 添加到开头
    currentRecent.insert(0, serverId);
    
    // 限制最近使用列表长度
    if (currentRecent.length > 10) {
      currentRecent.removeRange(10, currentRecent.length);
    }
    
    recentServerIds.value = currentRecent;
  }

  /// 从最近使用列表中移除
  void removeFromRecentServers(String serverId) {
    final currentRecent = List<String>.from(recentServerIds.value);
    currentRecent.remove(serverId);
    recentServerIds.value = currentRecent;
  }

  /// 为服务器添加标签
  void addTagToServer(String serverId, String tag) {
    final currentTags = Map<String, List<String>>.from(serverTags.value);
    final serverTagList = List<String>.from(currentTags[serverId] ?? []);
    
    if (!serverTagList.contains(tag)) {
      serverTagList.add(tag);
      currentTags[serverId] = serverTagList;
      serverTags.value = currentTags;
    }
  }

  /// 从服务器移除标签
  void removeTagFromServer(String serverId, String tag) {
    final currentTags = Map<String, List<String>>.from(serverTags.value);
    final serverTagList = List<String>.from(currentTags[serverId] ?? []);
    
    serverTagList.remove(tag);
    if (serverTagList.isEmpty) {
      currentTags.remove(serverId);
    } else {
      currentTags[serverId] = serverTagList;
    }
    serverTags.value = currentTags;
  }

  /// 获取服务器标签
  List<String> getServerTags(String serverId) {
    return serverTags.value[serverId] ?? [];
  }

  /// 清空所有服务器
  void clearAllServers() {
    try {
      clearError();
      
      serverList.clear();
      selectedServerId.value = null;
      defaultServerId.value = null;
      serverTags.clear();
      recentServerIds.clear();
      
      if (kDebugMode) {
        print('[ServerListState] 清空所有服务器成功');
      }
    } catch (e) {
      setError('清空服务器失败: $e');
      if (kDebugMode) {
        print('[ServerListState] 清空服务器失败: $e');
      }
      rethrow;
    }
  }

  /// 设置选中的服务器
  void setSelectedServer(String? serverId) {
    try {
      if (serverId != null) {
        // 验证服务器是否存在
        serverList.value.firstWhere(
          (s) => s.id.toString() == serverId,
          orElse: () => throw StateError('服务器不存在: $serverId'),
        );
        
        // 添加到最近使用列表
        addToRecentServers(serverId);
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
      try {
        return serverList.value.firstWhere((server) => server.id.toString() == id);
      } catch (e) {
        // 如果找不到选中的服务器，清除选中状态
        selectedServerId.value = null;
        return null;
      }
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
      
      final currentServers = List<ServerModel>.from(serverList.value);
      
      for (final server in servers) {
        // 确保ID唯一
        final newId = currentServers.isEmpty ? 1 : currentServers.map((s) => s.id).reduce((a, b) => a > b ? a : b) + 1;
        final newServer = server.copyWith(
          id: newId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        currentServers.add(newServer);
      }
      
      serverList.value = currentServers;
      
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
      final data = {
        'servers': serverList.value.map((server) => server.toJson()).toList(),
        'defaultServerId': defaultServerId.value,
        'serverTags': serverTags.value,
        'exportTime': DateTime.now().toIso8601String(),
      };
      return jsonEncode(data);
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
      
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      final importedServers = (data['servers'] as List)
          .map((json) => ServerModel.fromJson(json))
          .toList();
      
      if (merge) {
        // 合并模式：添加到现有服务器列表
        await addServers(importedServers);
      } else {
        // 替换模式：清空现有列表并添加导入的服务器
        serverList.value = importedServers;
        
        // 导入其他配置
        if (data.containsKey('defaultServerId')) {
          defaultServerId.value = data['defaultServerId'];
        }
        if (data.containsKey('serverTags')) {
          serverTags.value = Map<String, List<String>>.from(data['serverTags']);
        }
      }
      
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
      final servers = serverList.value;
      final enabledCount = servers.where((s) => s.enable).length;
      final protocolStats = <String, int>{};
      
      for (final server in servers) {
        final protocol = server.protocol.name;
        protocolStats[protocol] = (protocolStats[protocol] ?? 0) + 1;
      }
      
      return {
        'total': servers.length,
        'enabled': enabledCount,
        'disabled': servers.length - enabledCount,
        'protocols': protocolStats,
        'hasDefault': defaultServerId.value != null,
        'recentCount': recentServerIds.value.length,
        'tagCount': serverTags.value.length,
      };
    } catch (e) {
      setError('获取服务器统计信息失败: $e');
      if (kDebugMode) {
        print('[ServerListState] 获取服务器统计信息失败: $e');
      }
      return {'error': e.toString()};
    }
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
      final updatedServers = <ServerModel>[];
      for (int i = 0; i < reorderedServers.length; i++) {
        final server = reorderedServers[i].copyWith(
          sortOrder: i,
          updatedAt: DateTime.now(),
        );
        updatedServers.add(server);
      }
      
      serverList.value = updatedServers;
      
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
