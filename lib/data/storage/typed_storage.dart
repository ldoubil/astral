import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'file_storage.dart';

/// 类型化存储接口
/// 提供类型安全的数据存储和检索功能
abstract class Serializable {
  /// 将对象序列化为 Map
  Map<String, dynamic> toJson();
  
  /// 从 Map 反序列化对象
  static T fromJson<T extends Serializable>(Map<String, dynamic> json) {
    throw UnimplementedError('子类必须实现 fromJson 方法');
  }
}

/// 类型化存储管理器
/// 提供直接的类型支持，无需手动序列化
class TypedStorage {
  static final TypedStorage _instance = TypedStorage._internal();
  factory TypedStorage() => _instance;
  TypedStorage._internal();

  final FileStorage _fileStorage = FileStorage();

  /// 确保存储已初始化
  Future<void> ensureInitialized() async {
    if (!_fileStorage.isInitialized) {
      await _fileStorage.init();
    }
  }

  /// 存储基本类型值
  Future<void> setValue<T>(String boxName, String key, T value) async {
    await ensureInitialized();
    await _fileStorage.setPersistentValue(boxName, key, value);
  }

  /// 获取基本类型值
  Future<T?> getValue<T>(String boxName, String key, [T? defaultValue]) async {
    await ensureInitialized();
    return await _fileStorage.getPersistentValue<T>(boxName, key, defaultValue);
  }

  /// 同步获取基本类型值
  T? getValueSync<T>(String boxName, String key, [T? defaultValue]) {
    return _fileStorage.getPersistentValueSync<T>(boxName, key, defaultValue);
  }

  /// 存储列表
  Future<void> setList<T>(String boxName, String key, List<T> list) async {
    await ensureInitialized();
    
    if (list.isEmpty) {
      await _fileStorage.setPersistentValue(boxName, key, <dynamic>[]);
      return;
    }

    // 检查列表元素类型
    final firstElement = list.first;
    
    if (_isBasicType(firstElement)) {
      // 基本类型列表直接存储
      await _fileStorage.setPersistentValue(boxName, key, list);
    } else if (firstElement is Serializable) {
      // 可序列化对象列表
      final jsonList = list.map((item) => (item as Serializable).toJson()).toList();
      await _fileStorage.setPersistentValue(boxName, key, jsonList);
    } else {
      throw ArgumentError('不支持的列表元素类型: ${firstElement.runtimeType}');
    }
  }

  /// 获取列表
  Future<List<T>> getList<T>(String boxName, String key, {
    List<T>? defaultValue,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    await ensureInitialized();
    
    final rawList = await _fileStorage.getPersistentValue<List<dynamic>>(
      boxName, 
      key, 
      defaultValue?.cast<dynamic>() ?? <dynamic>[],
    );

    if (rawList == null || rawList.isEmpty) {
      return defaultValue ?? <T>[];
    }

    // 如果是基本类型列表
    if (_isBasicType<T>()) {
      return rawList.cast<T>();
    }

    // 如果提供了反序列化函数
    if (fromJson != null) {
      return rawList
          .where((item) => item is Map<String, dynamic>)
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw ArgumentError('复杂类型列表需要提供 fromJson 函数');
  }

  /// 同步获取列表
  List<T> getListSync<T>(String boxName, String key, {
    List<T>? defaultValue,
    T Function(Map<String, dynamic>)? fromJson,
  }) {
    final rawList = _fileStorage.getPersistentValueSync<List<dynamic>>(
      boxName, 
      key, 
      defaultValue?.cast<dynamic>() ?? <dynamic>[],
    );

    if (rawList == null || rawList.isEmpty) {
      return defaultValue ?? <T>[];
    }

    // 如果是基本类型列表
    if (_isBasicType<T>()) {
      return rawList.cast<T>();
    }

    // 如果提供了反序列化函数
    if (fromJson != null) {
      return rawList
          .where((item) => item is Map<String, dynamic>)
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw ArgumentError('复杂类型列表需要提供 fromJson 函数');
  }

  /// 存储 Map
  Future<void> setMap<K, V>(String boxName, String key, Map<K, V> map) async {
    await ensureInitialized();
    
    if (map.isEmpty) {
      await _fileStorage.setPersistentValue(boxName, key, <String, dynamic>{});
      return;
    }

    // 检查键类型（必须是字符串）
    if (K != String) {
      throw ArgumentError('Map 的键必须是 String 类型');
    }

    // 检查值类型
    final firstValue = map.values.first;
    
    if (_isBasicType(firstValue)) {
      // 基本类型值直接存储
      await _fileStorage.setPersistentValue(boxName, key, map);
    } else if (firstValue is Serializable) {
      // 可序列化对象值
      final jsonMap = <String, dynamic>{};
      map.forEach((k, v) {
        jsonMap[k.toString()] = (v as Serializable).toJson();
      });
      await _fileStorage.setPersistentValue(boxName, key, jsonMap);
    } else {
      throw ArgumentError('不支持的 Map 值类型: ${firstValue.runtimeType}');
    }
  }

  /// 获取 Map
  Future<Map<K, V>> getMap<K, V>(String boxName, String key, {
    Map<K, V>? defaultValue,
    V Function(Map<String, dynamic>)? fromJson,
  }) async {
    await ensureInitialized();
    
    final rawMap = await _fileStorage.getPersistentValue<Map<String, dynamic>>(
      boxName, 
      key, 
      defaultValue?.cast<String, dynamic>() ?? <String, dynamic>{},
    );

    if (rawMap == null || rawMap.isEmpty) {
      return defaultValue ?? <K, V>{};
    }

    // 如果是基本类型 Map
    if (_isBasicType<V>()) {
      return rawMap.cast<K, V>();
    }

    // 如果提供了反序列化函数
    if (fromJson != null) {
      final result = <K, V>{};
      rawMap.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          result[k as K] = fromJson(v);
        }
      });
      return result;
    }

    throw ArgumentError('复杂类型 Map 需要提供 fromJson 函数');
  }

  /// 同步获取 Map
  Map<K, V> getMapSync<K, V>(String boxName, String key, {
    Map<K, V>? defaultValue,
    V Function(Map<String, dynamic>)? fromJson,
  }) {
    final rawMap = _fileStorage.getPersistentValueSync<Map<String, dynamic>>(
      boxName, 
      key, 
      defaultValue?.cast<String, dynamic>() ?? <String, dynamic>{},
    );

    if (rawMap == null || rawMap.isEmpty) {
      return defaultValue ?? <K, V>{};
    }

    // 如果是基本类型 Map
    if (_isBasicType<V>()) {
      return rawMap.cast<K, V>();
    }

    // 如果提供了反序列化函数
    if (fromJson != null) {
      final result = <K, V>{};
      rawMap.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          result[k as K] = fromJson(v);
        }
      });
      return result;
    }

    throw ArgumentError('复杂类型 Map 需要提供 fromJson 函数');
  }

  /// 存储可序列化对象
  Future<void> setObject<T extends Serializable>(String boxName, String key, T object) async {
    await ensureInitialized();
    await _fileStorage.setPersistentValue(boxName, key, object.toJson());
  }

  /// 获取可序列化对象
  Future<T?> getObject<T extends Serializable>(
    String boxName, 
    String key, 
    T Function(Map<String, dynamic>) fromJson, {
    T? defaultValue,
  }) async {
    await ensureInitialized();
    
    final rawData = await _fileStorage.getPersistentValue<Map<String, dynamic>>(
      boxName, 
      key,
    );

    if (rawData == null) {
      return defaultValue;
    }

    try {
      return fromJson(rawData);
    } catch (e) {
      if (kDebugMode) {
        print('[TypedStorage] 反序列化对象失败: $e');
      }
      return defaultValue;
    }
  }

  /// 同步获取可序列化对象
  T? getObjectSync<T extends Serializable>(
    String boxName, 
    String key, 
    T Function(Map<String, dynamic>) fromJson, {
    T? defaultValue,
  }) {
    final rawData = _fileStorage.getPersistentValueSync<Map<String, dynamic>>(
      boxName, 
      key,
    );

    if (rawData == null) {
      return defaultValue;
    }

    try {
      return fromJson(rawData);
    } catch (e) {
      if (kDebugMode) {
        print('[TypedStorage] 同步反序列化对象失败: $e');
      }
      return defaultValue;
    }
  }

  /// 删除键值对
  Future<void> remove(String boxName, String key) async {
    await ensureInitialized();
    await _fileStorage.removePersistentValue(boxName, key);
  }

  /// 清空指定 box
  Future<void> clearBox(String boxName) async {
    await ensureInitialized();
    await _fileStorage.clearBox(boxName);
  }

  /// 检查是否为基本类型
  bool _isBasicType<T>([dynamic value]) {
    if (value != null) {
      return value is String || 
             value is int || 
             value is double || 
             value is bool || 
             value is num;
    }
    
    return T == String || 
           T == int || 
           T == double || 
           T == bool || 
           T == num;
  }

  /// 获取存储统计信息
  Future<Map<String, dynamic>> getStats() async {
    await ensureInitialized();
    return await _fileStorage.getStorageStats();
  }
}

/// 便捷的全局实例
final typedStorage = TypedStorage();