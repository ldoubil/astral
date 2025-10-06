import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../storage/file_storage.dart';
import '../models/server_model.dart';

/// 服务器数据仓库
/// 负责管理服务器配置的持久化存储和检索
class ServerRepository {
  static const String _boxName = 'servers';
  static const String _serversKey = 'server_list';
  static const String _defaultServerKey = 'default_server';
  
  final FileStorage _storage = FileStorage();

  /// 获取所有服务器列表
  Future<List<ServerModel>> getAllServers() async {
    try {
      final serversJson = await _storage.getPersistentValue<String>(
        _boxName,
        _serversKey,
        '[]',
      );

      if (serversJson == null || serversJson.isEmpty || serversJson == '[]') {
        return [];
      }

      final List<dynamic> serversList = jsonDecode(serversJson);
      return serversList
          .map((json) => ServerModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('[ServerRepository] 获取服务器列表失败: $e');
      }
      return [];
    }
  }

  /// 同步获取所有服务器列表（从缓存）
  List<ServerModel> getAllServersSync() {
    try {
      final serversJson = _storage.getPersistentValueSync<String>(
        _boxName,
        _serversKey,
        '[]',
      );

      if (serversJson == null || serversJson.isEmpty || serversJson == '[]') {
        return [];
      }

      final List<dynamic> serversList = jsonDecode(serversJson);
      return serversList
          .map((json) => ServerModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('[ServerRepository] 同步获取服务器列表失败: $e');
      }
      return [];
    }
  }

  /// 保存服务器列表
  Future<void> saveServers(List<ServerModel> servers) async {
    try {
      final serversJson = jsonEncode(servers.map((s) => s.toJson()).toList());
      await _storage.setPersistentValue(_boxName, _serversKey, serversJson);
      
      if (kDebugMode) {
        print('[ServerRepository] 保存服务器列表成功，共${servers.length}个服务器');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ServerRepository] 保存服务器列表失败: $e');
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
        print('[ServerRepository] 添加服务器成功: ${server.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ServerRepository] 添加服务器失败: $e');
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
          print('[ServerRepository] 更新服务器成功: ${server.name}');
        }
      } else {
        throw Exception('服务器不存在: ${server.uniqueId}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ServerRepository] 更新服务器失败: $e');
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
        print('[ServerRepository] 删除服务器成功: $uniqueId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ServerRepository] 删除服务器失败: $e');
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
        print('[ServerRepository] 获取服务器失败: $e');
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
        print('[ServerRepository] 根据ID获取服务器失败: $e');
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
        print('[ServerRepository] 同步获取服务器失败: $e');
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
        print('[ServerRepository] 同步根据ID获取服务器失败: $e');
      }
      return null;
    }
  }

  /// 设置默认服务器
  Future<void> setDefaultServer(String uniqueId) async {
    try {
      await _storage.setPersistentValue(_boxName, _defaultServerKey, uniqueId);
      
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
        print('[ServerRepository] 设置默认服务器成功: $uniqueId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ServerRepository] 设置默认服务器失败: $e');
      }
      rethrow;
    }
  }

  /// 获取默认服务器
  Future<ServerModel?> getDefaultServer() async {
    try {
      final defaultId = await _storage.getPersistentValue<String>(
        _boxName,
        _defaultServerKey,
      );
      
      if (defaultId != null) {
        return await getServerById(defaultId);
      }
      
      // 如果没有设置默认服务器，返回第一个服务器
      final servers = await getAllServers();
      return servers.isNotEmpty ? servers.first : null;
    } catch (e) {
      if (kDebugMode) {
        print('[ServerRepository] 获取默认服务器失败: $e');
      }
      return null;
    }
  }

  /// 同步获取默认服务器
  ServerModel? getDefaultServerSync() {
    try {
      final defaultId = _storage.getPersistentValueSync<String>(
        _boxName,
        _defaultServerKey,
      );
      
      if (defaultId != null) {
        return getServerByIdSync(defaultId);
      }
      
      // 如果没有设置默认服务器，返回第一个服务器
      final servers = getAllServersSync();
      return servers.isNotEmpty ? servers.first : null;
    } catch (e) {
      if (kDebugMode) {
        print('[ServerRepository] 同步获取默认服务器失败: $e');
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
        print('[ServerRepository] 检查服务器存在失败: $e');
      }
      return false;
    }
  }

  /// 清空所有服务器
  Future<void> clearAllServers() async {
    try {
      await _storage.clearBox(_boxName);
      
      if (kDebugMode) {
        print('[ServerRepository] 清空所有服务器成功');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ServerRepository] 清空所有服务器失败: $e');
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
        print('[ServerRepository] 导出服务器配置失败: $e');
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
        print('[ServerRepository] 导入服务器配置成功，共${importedServers.length}个服务器');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ServerRepository] 导入服务器配置失败: $e');
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
        print('[ServerRepository] 获取服务器统计信息失败: $e');
      }
      return {'error': e.toString()};
    }
  }

  Map<String, int> _getProtocolDistribution(List<ServerModel> servers) {
    final distribution = <String, int>{};
    for (final server in servers) {
      final protocol = server.protocol.toString().split('.').last;
      distribution[protocol] = (distribution[protocol] ?? 0) + 1;
    }
    return distribution;
  }
}