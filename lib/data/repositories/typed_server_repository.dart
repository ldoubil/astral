import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../storage/typed_storage.dart';
import '../models/server_model.dart';

/// 类型化服务器数据仓库
/// 使用 TypedStorage 提供类型安全的服务器配置管理
/// 支持直接存储和检索复杂类型，无需手动序列化
class TypedServerRepository {
  static const String _boxName = 'servers';
  static const String _serversKey = 'server_list';
  static const String _defaultServerKey = 'default_server';
  
  final TypedStorage _storage = TypedStorage();

  /// 获取所有服务器列表
  Future<List<ServerModel>> getAllServers() async {
    try {
      return await _storage.getList<ServerModel>(
        _boxName,
        _serversKey,
        defaultValue: <ServerModel>[],
        fromJson: ServerModel.fromJson,
      );
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 获取服务器列表失败: $e');
      }
      return <ServerModel>[];
    }
  }

  /// 同步获取所有服务器列表
  List<ServerModel> getAllServersSync() {
    try {
      return _storage.getListSync<ServerModel>(
        _boxName,
        _serversKey,
        defaultValue: <ServerModel>[],
        fromJson: ServerModel.fromJson,
      );
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 同步获取服务器列表失败: $e');
      }
      return <ServerModel>[];
    }
  }

  /// 保存服务器列表
  Future<void> saveServers(List<ServerModel> servers) async {
    try {
      await _storage.setList(_boxName, _serversKey, servers);
      
      if (kDebugMode) {
        print('[TypedServerRepository] 保存服务器列表成功，共${servers.length}个服务器');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 保存服务器列表失败: $e');
      }
      rethrow;
    }
  }

  /// 添加服务器
  Future<void> addServer(ServerModel server) async {
    try {
      final servers = await getAllServers();
      
      // 检查是否已存在相同的服务器
      final existingIndex = servers.indexWhere(
        (s) => s.uniqueId == server.uniqueId,
      );
      
      if (existingIndex != -1) {
        // 更新现有服务器
        servers[existingIndex] = server.copyWith(updatedAt: DateTime.now());
      } else {
        // 添加新服务器
        servers.add(server);
      }
      
      await saveServers(servers);
      
      if (kDebugMode) {
        print('[TypedServerRepository] 添加服务器成功: ${server.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 添加服务器失败: $e');
      }
      rethrow;
    }
  }

  /// 更新服务器
  Future<void> updateServer(ServerModel server) async {
    try {
      final servers = await getAllServers();
      final index = servers.indexWhere((s) => s.uniqueId == server.uniqueId);
      
      if (index != -1) {
        servers[index] = server.copyWith(updatedAt: DateTime.now());
        await saveServers(servers);
        
        if (kDebugMode) {
          print('[TypedServerRepository] 更新服务器成功: ${server.name}');
        }
      } else {
        throw Exception('服务器不存在: ${server.uniqueId}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 更新服务器失败: $e');
      }
      rethrow;
    }
  }

  /// 删除服务器
  Future<void> deleteServer(String uniqueId) async {
    try {
      final servers = await getAllServers();
      servers.removeWhere((s) => s.uniqueId == uniqueId);
      await saveServers(servers);
      
      if (kDebugMode) {
        print('[TypedServerRepository] 删除服务器成功: $uniqueId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 删除服务器失败: $e');
      }
      rethrow;
    }
  }

  /// 根据唯一ID获取服务器
  Future<ServerModel?> getServerById(String uniqueId) async {
    try {
      final servers = await getAllServers();
      return servers.firstWhere(
        (s) => s.uniqueId == uniqueId,
        orElse: () => throw StateError('服务器不存在'),
      );
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 获取服务器失败: $e');
      }
      return null;
    }
  }

  /// 根据ID获取服务器
  Future<ServerModel?> getServerByIntId(int id) async {
    try {
      final servers = await getAllServers();
      return servers.firstWhere(
        (s) => s.id == id,
        orElse: () => throw StateError('服务器不存在'),
      );
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 根据ID获取服务器失败: $e');
      }
      return null;
    }
  }

  /// 同步根据唯一ID获取服务器
  ServerModel? getServerByIdSync(String uniqueId) {
    try {
      final servers = getAllServersSync();
      return servers.firstWhere(
        (s) => s.uniqueId == uniqueId,
        orElse: () => throw StateError('服务器不存在'),
      );
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 同步获取服务器失败: $e');
      }
      return null;
    }
  }

  /// 同步根据ID获取服务器
  ServerModel? getServerByIntIdSync(int id) {
    try {
      final servers = getAllServersSync();
      return servers.firstWhere(
        (s) => s.id == id,
        orElse: () => throw StateError('服务器不存在'),
      );
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 同步根据ID获取服务器失败: $e');
      }
      return null;
    }
  }

  /// 设置默认服务器
  Future<void> setDefaultServer(String uniqueId) async {
    try {
      await _storage.setValue(_boxName, _defaultServerKey, uniqueId);
      
      // 更新服务器列表中的默认标记
      final servers = await getAllServers();
      for (int i = 0; i < servers.length; i++) {
        servers[i] = servers[i].copyWith(
          isDefault: servers[i].uniqueId == uniqueId,
          updatedAt: DateTime.now(),
        );
      }
      await saveServers(servers);
      
      if (kDebugMode) {
        print('[TypedServerRepository] 设置默认服务器成功: $uniqueId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 设置默认服务器失败: $e');
      }
      rethrow;
    }
  }

  /// 获取默认服务器
  Future<ServerModel?> getDefaultServer() async {
    try {
      final defaultId = await _storage.getValue<String>(_boxName, _defaultServerKey);
      
      if (defaultId != null) {
        return await getServerById(defaultId);
      }
      
      // 如果没有设置默认服务器，返回第一个服务器
      final servers = await getAllServers();
      return servers.isNotEmpty ? servers.first : null;
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 获取默认服务器失败: $e');
      }
      return null;
    }
  }

  /// 同步获取默认服务器
  ServerModel? getDefaultServerSync() {
    try {
      final defaultId = _storage.getValueSync<String>(_boxName, _defaultServerKey);
      
      if (defaultId != null) {
        return getServerByIdSync(defaultId);
      }
      
      // 如果没有设置默认服务器，返回第一个服务器
      final servers = getAllServersSync();
      return servers.isNotEmpty ? servers.first : null;
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 同步获取默认服务器失败: $e');
      }
      return null;
    }
  }

  /// 检查服务器是否存在
  Future<bool> serverExists(String uniqueId) async {
    try {
      final servers = await getAllServers();
      return servers.any((s) => s.uniqueId == uniqueId);
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 检查服务器存在失败: $e');
      }
      return false;
    }
  }

  /// 清空所有服务器
  Future<void> clearAllServers() async {
    try {
      await _storage.clearBox(_boxName);
      
      if (kDebugMode) {
        print('[TypedServerRepository] 清空所有服务器成功');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 清空所有服务器失败: $e');
      }
      rethrow;
    }
  }

  /// 导出服务器配置
  Future<String> exportServers() async {
    try {
      final servers = await getAllServers();
      final exportData = {
        'version': '1.0',
        'exportTime': DateTime.now().toIso8601String(),
        'servers': servers.map((s) => s.toJson()).toList(),
      };
      
      return jsonEncode(exportData);
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 导出服务器配置失败: $e');
      }
      rethrow;
    }
  }

  /// 导入服务器配置
  Future<void> importServers(String jsonData, {bool merge = true}) async {
    try {
      final importData = jsonDecode(jsonData) as Map<String, dynamic>;
      final serversList = importData['servers'] as List<dynamic>;
      
      final importedServers = serversList
          .map((json) => ServerModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      if (merge) {
        // 合并模式：添加到现有服务器列表
        for (final server in importedServers) {
          await addServer(server);
        }
      } else {
        // 替换模式：清空现有列表并导入新的
        await saveServers(importedServers);
      }
      
      if (kDebugMode) {
        print('[TypedServerRepository] 导入服务器配置成功，共${importedServers.length}个服务器');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 导入服务器配置失败: $e');
      }
      rethrow;
    }
  }

  /// 获取服务器统计信息
  Future<Map<String, dynamic>> getServerStats() async {
    try {
      final servers = await getAllServers();
      final defaultServer = await getDefaultServer();
      
      return {
        'totalServers': servers.length,
        'enabledServers': servers.where((s) => s.enable).length,
        'protocolDistribution': _getProtocolDistribution(servers),
        'defaultServer': defaultServer?.name,
        'lastUpdated': servers.isNotEmpty 
            ? servers.map((s) => s.updatedAt).reduce((a, b) => a.isAfter(b) ? a : b)
            : null,
      };
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 获取服务器统计信息失败: $e');
      }
      return {'error': e.toString()};
    }
  }

  /// 获取协议分布统计
  Map<String, int> _getProtocolDistribution(List<ServerModel> servers) {
    final distribution = <String, int>{};
    for (final server in servers) {
      final protocol = server.protocol.toString().split('.').last;
      distribution[protocol] = (distribution[protocol] ?? 0) + 1;
    }
    return distribution;
  }

  /// 按标签筛选服务器
  Future<List<ServerModel>> getServersByTags(List<String> tags) async {
    try {
      final servers = await getAllServers();
      return servers.where((server) {
        return tags.any((tag) => server.tags.contains(tag));
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 按标签筛选服务器失败: $e');
      }
      return <ServerModel>[];
    }
  }

  /// 按协议筛选服务器
  Future<List<ServerModel>> getServersByProtocol(ProtocolType protocol) async {
    try {
      final servers = await getAllServers();
      return servers.where((server) => server.protocol == protocol).toList();
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 按协议筛选服务器失败: $e');
      }
      return <ServerModel>[];
    }
  }

  /// 搜索服务器（按名称或描述）
  Future<List<ServerModel>> searchServers(String query) async {
    try {
      final servers = await getAllServers();
      final lowerQuery = query.toLowerCase();
      
      return servers.where((server) {
        return server.name.toLowerCase().contains(lowerQuery) ||
               (server.description?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('[TypedServerRepository] 搜索服务器失败: $e');
      }
      return <ServerModel>[];
    }
  }
}

/// 便捷的全局实例
final typedServerRepository = TypedServerRepository();