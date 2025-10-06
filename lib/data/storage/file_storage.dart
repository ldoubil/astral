import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// 基于JSON文件的存储管理器
/// 提供高性能的数据持久化解决方案，支持复杂对象结构
/// 所有配置都保存在单一的 config.json 文件中
class FileStorage {
  static final FileStorage _instance = FileStorage._internal();
  factory FileStorage() => _instance;
  FileStorage._internal();

  late Directory _dataDirectory;
  late File _configFile;
  bool _isInitialized = false;
  Map<String, dynamic> _config = {};

  /// 检查是否已初始化
  bool get isInitialized => _isInitialized;

  /// 初始化文件存储
  Future<void> init() async {
    if (_isInitialized) {
      return; // 已经初始化
    }

    // 获取应用文档目录
    _dataDirectory = await getApplicationDocumentsDirectory();
    
    // 创建存储子目录
    final storageDir = Directory(path.join(_dataDirectory.path, 'astral_storage'));
    if (!await storageDir.exists()) {
      await storageDir.create(recursive: true);
    }
    _dataDirectory = storageDir;

    // 设置配置文件路径
    _configFile = File(path.join(_dataDirectory.path, 'config.json'));

    if (kDebugMode) {
      print('[FileStorage] 数据目录: ${_dataDirectory.path}');
      print('[FileStorage] 配置文件: ${_configFile.path}');
    }

    // 加载配置文件
    await _loadConfig();

    _isInitialized = true;
  }

  /// 加载配置文件
  Future<void> _loadConfig() async {
    try {
      if (await _configFile.exists()) {
        final content = await _configFile.readAsString();
        if (content.isNotEmpty) {
          _config = jsonDecode(content) as Map<String, dynamic>;
          if (kDebugMode) {
            print('[FileStorage] 加载配置文件成功，包含 ${_config.keys.length} 个配置项');
          }
        }
      } else {
        _config = {};
        if (kDebugMode) {
          print('[FileStorage] 配置文件不存在，创建新的配置');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[FileStorage] 加载配置文件失败: $e');
      }
      // 如果文件损坏，创建备份并重新开始
      await _createBackup();
      _config = {};
    }
  }

  /// 保存配置到文件
  Future<void> _saveConfig() async {
    try {
      final jsonString = jsonEncode(_config);
      await _configFile.writeAsString(jsonString);
      
      if (kDebugMode) {
        print('[FileStorage] 保存配置文件成功');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[FileStorage] 保存配置文件失败: $e');
      }
      rethrow;
    }
  }

  /// 创建损坏文件的备份
  Future<void> _createBackup() async {
    try {
      if (await _configFile.exists()) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final backupPath = path.join(_dataDirectory.path, 'config_backup_$timestamp.json');
        await _configFile.copy(backupPath);
        
        if (kDebugMode) {
          print('[FileStorage] 创建备份文件: $backupPath');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[FileStorage] 创建备份失败: $e');
      }
    }
  }

  /// 获取配置键的完整路径
  String _getConfigKey(String boxName, String key) {
    return '$boxName.$key';
  }

  /// 获取持久化值
  Future<T?> getPersistentValue<T>(
    String boxName,
    String key, [
    T? defaultValue,
  ]) async {
    if (!_isInitialized) {
      throw StateError('FileStorage未初始化，请先调用 init() 方法');
    }

    try {
      final configKey = _getConfigKey(boxName, key);
      final value = _config[configKey];
      
      if (value == null) {
        return defaultValue;
      }

      // 处理类型转换
      return _convertValue<T>(value, defaultValue);
    } catch (e) {
      if (kDebugMode) {
        print('[FileStorage] 获取持久化值失败: $e');
      }
      return defaultValue;
    }
  }

  /// 同步获取持久化值（从缓存）
  T? getPersistentValueSync<T>(String boxName, String key, [T? defaultValue]) {
    if (!_isInitialized) {
      return defaultValue;
    }

    try {
      final configKey = _getConfigKey(boxName, key);
      final value = _config[configKey];
      
      if (value == null) {
        return defaultValue;
      }

      // 尝试转换为目标类型
      if (value is T) {
        return value;
      }

      // 处理类型转换
      return _convertValue<T>(value, defaultValue);
    } catch (e) {
      if (kDebugMode) {
        print('[FileStorage] 同步获取持久化值失败: $e');
      }
      return defaultValue;
    }
  }

  /// 设置持久化值
  Future<void> setPersistentValue<T>(
    String boxName,
    String key,
    T value,
  ) async {
    if (!_isInitialized) {
      throw StateError('FileStorage未初始化，请先调用 init() 方法');
    }

    try {
      final configKey = _getConfigKey(boxName, key);
      _config[configKey] = value;
      await _saveConfig();
      
      if (kDebugMode) {
        print('[FileStorage] 设置持久化值成功: $configKey = $value');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[FileStorage] 设置持久化值失败: $e');
      }
      rethrow;
    }
  }

  /// 删除持久化值
  Future<void> removePersistentValue(String boxName, String key) async {
    if (!_isInitialized) {
      throw StateError('FileStorage未初始化，请先调用 init() 方法');
    }

    try {
      final configKey = _getConfigKey(boxName, key);
      _config.remove(configKey);
      await _saveConfig();
      
      if (kDebugMode) {
        print('[FileStorage] 删除持久化值成功: $configKey');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[FileStorage] 删除持久化值失败: $e');
      }
      rethrow;
    }
  }

  /// 清空指定box
  Future<void> clearBox(String boxName) async {
    if (!_isInitialized) {
      throw StateError('FileStorage未初始化，请先调用 init() 方法');
    }

    try {
      // 删除所有以 boxName. 开头的键
      final keysToRemove = _config.keys
          .where((key) => key.startsWith('$boxName.'))
          .toList();
      
      for (final key in keysToRemove) {
        _config.remove(key);
      }
      
      await _saveConfig();
      
      if (kDebugMode) {
        print('[FileStorage] 清空box成功: $boxName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[FileStorage] 清空box失败: $e');
      }
      rethrow;
    }
  }

  /// 获取box中所有键
  Future<List<String>> getKeys(String boxName) async {
    if (!_isInitialized) {
      throw StateError('FileStorage未初始化，请先调用 init() 方法');
    }

    try {
      final prefix = '$boxName.';
      return _config.keys
          .where((key) => key.startsWith(prefix))
          .map((key) => key.substring(prefix.length))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('[FileStorage] 获取键列表失败: $e');
      }
      return [];
    }
  }

  /// 检查键是否存在
  Future<bool> containsKey(String boxName, String key) async {
    if (!_isInitialized) {
      return false;
    }

    try {
      final configKey = _getConfigKey(boxName, key);
      return _config.containsKey(configKey);
    } catch (e) {
      if (kDebugMode) {
        print('[FileStorage] 检查键存在失败: $e');
      }
      return false;
    }
  }

  /// 类型转换辅助方法
  T? _convertValue<T>(dynamic value, T? defaultValue) {
    try {
      if (value is T) {
        return value;
      }

      // 基本类型转换
      if (T == String) {
        return value.toString() as T;
      }
      
      if (T == int) {
        if (value is num) return value.toInt() as T;
        if (value is String) return int.tryParse(value) as T?;
      }
      
      if (T == double) {
        if (value is num) return value.toDouble() as T;
        if (value is String) return double.tryParse(value) as T?;
      }
      
      if (T == bool) {
        if (value is bool) return value as T;
        if (value is String) return (value.toLowerCase() == 'true') as T;
        if (value is num) return (value != 0) as T;
      }

      // 列表和映射类型
      if (value is List && T.toString().startsWith('List')) {
        return value as T;
      }
      
      if (value is Map && T.toString().startsWith('Map')) {
        return value as T;
      }

      return defaultValue;
    } catch (e) {
      if (kDebugMode) {
        print('[FileStorage] 类型转换失败: $e');
      }
      return defaultValue;
    }
  }

  /// 获取存储统计信息
  Future<Map<String, dynamic>> getStorageStats() async {
    if (!_isInitialized) {
      return {'error': 'FileStorage未初始化'};
    }

    try {
      int totalSize = 0;
      if (await _configFile.exists()) {
        totalSize = await _configFile.length();
      }

      return {
        'configKeys': _config.length,
        'totalSize': totalSize,
        'totalSizeFormatted': '${(totalSize / 1024).toStringAsFixed(2)} KB',
        'dataDirectory': _dataDirectory.path,
        'configFile': _configFile.path,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}