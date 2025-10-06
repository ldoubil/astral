import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../data/storage/typed_storage.dart';

/// 类型化的自动持久化 Signal 封装类
/// 使用 TypedStorage 提供更好的类型支持和直接存储能力
class TypedPersistentSignal<T> {
  late final Signal<T> _signal;
  final String key;
  final String boxName;
  
  /// 获取内部的 Signal 实例
  Signal<T> get signal => _signal;
  
  /// 获取当前值
  T get value => _signal.value;
  
  /// 设置新值
  set value(T newValue) => _signal.value = newValue;

  TypedPersistentSignal(
    this.key, 
    T initialValue, {
    this.boxName = 'settings',
  }) {
    // 尝试从类型化存储同步加载值
    final dbValue = typedStorage.getValueSync<T>(boxName, key, initialValue);
    
    // 使用加载的值或初始值创建信号
    _signal = Signal<T>(dbValue ?? initialValue);
    
    if (kDebugMode) {
      if (dbValue != null && dbValue != initialValue) {
        print('[TypedPersistentSignal] 从类型化存储加载值: $key = $dbValue');
      } else {
        print('[TypedPersistentSignal] 使用初始值: $key = $initialValue');
      }
    }
    
    // 设置持久化监听
    _setupPersistence();
  }

  /// 设置持久化监听
  void _setupPersistence() {
    bool isFirstCall = true;
    effect(() {
      final currentValue = _signal.value;
      
      // 跳过初始化时的保存
      if (isFirstCall) {
        isFirstCall = false;
        return;
      }
      
      _saveToStorage(currentValue);
    });
  }

  /// 保存值到类型化存储
  void _saveToStorage(T value) {
    Future.microtask(() async {
      try {
        await typedStorage.setValue(boxName, key, value);
        if (kDebugMode) {
          print('[TypedPersistentSignal] 保存到类型化存储: $key = $value');
        }
      } catch (e) {
        if (kDebugMode) {
          print('[TypedPersistentSignal] 保存到类型化存储失败: $e');
        }
      }
    });
  }

  /// 监听值变化
  /// 返回一个 dispose 函数用于取消监听
  VoidCallback listen(void Function(T value) callback) {
    return _signal.subscribe(callback);
  }

  /// 在 Widget 中监听值变化
  /// 返回当前值，用于在 Widget 中使用
  T watch(BuildContext context) {
    return _signal.watch(context);
  }

  @override
  String toString() => 'TypedPersistentSignal<$T>(${_signal.value})';
}

/// 类型化持久化列表信号
class TypedPersistentListSignal<T> {
  late final Signal<List<T>> _signal;
  final String key;
  final String boxName;
  final T Function(Map<String, dynamic>)? fromJson;
  
  /// 获取内部的 Signal 实例
  Signal<List<T>> get signal => _signal;
  
  /// 获取当前值
  List<T> get value => _signal.value;
  
  /// 设置新值
  set value(List<T> newValue) => _signal.value = newValue;

  TypedPersistentListSignal(
    this.key, 
    List<T> initialValue, {
    this.boxName = 'settings',
    this.fromJson,
  }) {
    // 尝试从类型化存储同步加载列表
    final dbValue = typedStorage.getListSync<T>(
      boxName, 
      key, 
      defaultValue: initialValue,
      fromJson: fromJson,
    );
    
    // 使用加载的值或初始值创建信号
    _signal = Signal<List<T>>(dbValue);
    
    if (kDebugMode) {
      if (dbValue.isNotEmpty && dbValue != initialValue) {
        print('[TypedPersistentListSignal] 从类型化存储加载列表: $key = ${dbValue.length} 项');
      } else {
        print('[TypedPersistentListSignal] 使用初始列表: $key = ${initialValue.length} 项');
      }
    }
    
    // 设置持久化监听
    _setupPersistence();
  }

  /// 设置持久化监听
  void _setupPersistence() {
    bool isFirstCall = true;
    effect(() {
      final currentValue = _signal.value;
      
      // 跳过初始化时的保存
      if (isFirstCall) {
        isFirstCall = false;
        return;
      }
      
      _saveToStorage(currentValue);
    });
  }

  /// 保存列表到类型化存储
  void _saveToStorage(List<T> value) {
    Future.microtask(() async {
      try {
        await typedStorage.setList(boxName, key, value);
        if (kDebugMode) {
          print('[TypedPersistentListSignal] 保存列表到类型化存储: $key = ${value.length} 项');
        }
      } catch (e) {
        if (kDebugMode) {
          print('[TypedPersistentListSignal] 保存列表到类型化存储失败: $e');
        }
      }
    });
  }

  /// 添加项目
  void add(T item) {
    final newList = List<T>.from(_signal.value)..add(item);
    _signal.value = newList;
  }

  /// 移除项目
  void remove(T item) {
    final newList = List<T>.from(_signal.value)..remove(item);
    _signal.value = newList;
  }

  /// 清空列表
  void clear() {
    _signal.value = <T>[];
  }

  /// 监听值变化
  VoidCallback listen(void Function(List<T> value) callback) {
    return _signal.subscribe(callback);
  }

  /// 在 Widget 中监听值变化
  List<T> watch(BuildContext context) {
    return _signal.watch(context);
  }

  @override
  String toString() => 'TypedPersistentListSignal<$T>(${_signal.value.length} items)';
}

/// 类型化持久化 Map 信号
class TypedPersistentMapSignal<K, V> {
  late final Signal<Map<K, V>> _signal;
  final String key;
  final String boxName;
  final V Function(Map<String, dynamic>)? fromJson;
  
  /// 获取内部的 Signal 实例
  Signal<Map<K, V>> get signal => _signal;
  
  /// 获取当前值
  Map<K, V> get value => _signal.value;
  
  /// 设置新值
  set value(Map<K, V> newValue) => _signal.value = newValue;

  TypedPersistentMapSignal(
    this.key, 
    Map<K, V> initialValue, {
    this.boxName = 'settings',
    this.fromJson,
  }) {
    // 尝试从类型化存储同步加载 Map
    final dbValue = typedStorage.getMapSync<K, V>(
      boxName, 
      key, 
      defaultValue: initialValue,
      fromJson: fromJson,
    );
    
    // 使用加载的值或初始值创建信号
    _signal = Signal<Map<K, V>>(dbValue);
    
    if (kDebugMode) {
      if (dbValue.isNotEmpty && dbValue != initialValue) {
        print('[TypedPersistentMapSignal] 从类型化存储加载 Map: $key = ${dbValue.keys.length} 项');
      } else {
        print('[TypedPersistentMapSignal] 使用初始 Map: $key = ${initialValue.keys.length} 项');
      }
    }
    
    // 设置持久化监听
    _setupPersistence();
  }

  /// 设置持久化监听
  void _setupPersistence() {
    bool isFirstCall = true;
    effect(() {
      final currentValue = _signal.value;
      
      // 跳过初始化时的保存
      if (isFirstCall) {
        isFirstCall = false;
        return;
      }
      
      _saveToStorage(currentValue);
    });
  }

  /// 保存 Map 到类型化存储
  void _saveToStorage(Map<K, V> value) {
    Future.microtask(() async {
      try {
        await typedStorage.setMap(boxName, key, value);
        if (kDebugMode) {
          print('[TypedPersistentMapSignal] 保存 Map 到类型化存储: $key = ${value.keys.length} 项');
        }
      } catch (e) {
        if (kDebugMode) {
          print('[TypedPersistentMapSignal] 保存 Map 到类型化存储失败: $e');
        }
      }
    });
  }

  /// 设置键值对
  void put(K key, V value) {
    final newMap = Map<K, V>.from(_signal.value);
    newMap[key] = value;
    _signal.value = newMap;
  }

  /// 移除键值对
  void removeKey(K key) {
    final newMap = Map<K, V>.from(_signal.value);
    newMap.remove(key);
    _signal.value = newMap;
  }

  /// 清空 Map
  void clear() {
    _signal.value = <K, V>{};
  }

  /// 监听值变化
  VoidCallback listen(void Function(Map<K, V> value) callback) {
    return _signal.subscribe(callback);
  }

  /// 在 Widget 中监听值变化
  Map<K, V> watch(BuildContext context) {
    return _signal.watch(context);
  }

  @override
  String toString() => 'TypedPersistentMapSignal<$K, $V>(${_signal.value.keys.length} items)';
}

/// 便捷的工厂函数

/// 创建类型化持久化字符串信号
TypedPersistentSignal<String> typedPersistentString({
  required String key,
  String initialValue = '',
  String boxName = 'settings',
}) => TypedPersistentSignal(key, initialValue, boxName: boxName);

/// 创建类型化持久化整数信号
TypedPersistentSignal<int> typedPersistentInt({
  required String key,
  int initialValue = 0,
  String boxName = 'settings',
}) => TypedPersistentSignal(key, initialValue, boxName: boxName);

/// 创建类型化持久化布尔信号
TypedPersistentSignal<bool> typedPersistentBool({
  required String key,
  bool initialValue = false,
  String boxName = 'settings',
}) => TypedPersistentSignal(key, initialValue, boxName: boxName);

/// 创建类型化持久化双精度浮点数信号
TypedPersistentSignal<double> typedPersistentDouble({
  required String key,
  double initialValue = 0.0,
  String boxName = 'settings',
}) => TypedPersistentSignal(key, initialValue, boxName: boxName);

/// 创建类型化持久化列表信号
TypedPersistentListSignal<T> typedPersistentList<T>({
  required String key,
  List<T>? initialValue,
  String boxName = 'settings',
  T Function(Map<String, dynamic>)? fromJson,
}) => TypedPersistentListSignal(
  key, 
  initialValue ?? <T>[], 
  boxName: boxName,
  fromJson: fromJson,
);

/// 创建类型化持久化 Map 信号
TypedPersistentMapSignal<K, V> typedPersistentMap<K, V>({
  required String key,
  Map<K, V>? initialValue,
  String boxName = 'settings',
  V Function(Map<String, dynamic>)? fromJson,
}) => TypedPersistentMapSignal(
  key, 
  initialValue ?? <K, V>{}, 
  boxName: boxName,
  fromJson: fromJson,
);