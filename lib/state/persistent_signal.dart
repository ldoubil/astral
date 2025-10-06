import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../data/storage/file_storage.dart';

/// 自动持久化的 Signal 封装类
/// 创建时自动设置持久化，无需手动调用 persistWith
class PersistentSignal<T> {
  late final Signal<T> _signal;
  final String key;
  
  /// 获取内部的 Signal 实例
  Signal<T> get signal => _signal;
  
  /// 获取当前值
  T get value => _signal.value;
  
  /// 设置新值
  set value(T newValue) => _signal.value = newValue;

  PersistentSignal(this.key, T initialValue) {
    // 尝试从文件存储同步加载值，如果没有则使用初始值
    final dbValue = FileStorage().getPersistentValueSync<dynamic>('settings', key, null);
    
    // 解码数据库值
    final decodedValue = _decodeValue(dbValue, initialValue);
    
    // 使用解码后的值或初始值创建信号
    _signal = Signal<T>(decodedValue ?? initialValue);
    
    if (kDebugMode) {
      if (dbValue != null) {
        if (decodedValue != null && decodedValue != initialValue) {
          print('[PersistentSignal] 从文件存储加载值: $key = $decodedValue');
        } else if (decodedValue == null) {
          print('[PersistentSignal] 文件存储有值但无法解码，使用初始值: $key = $initialValue (存储值: $dbValue)');
        } else {
          print('[PersistentSignal] 使用初始值: $key = $initialValue');
        }
      } else {
        print('[PersistentSignal] 文件存储无值，使用初始值: $key = $initialValue');
      }
    }
    
    // 设置持久化监听，但跳过初始化时的保存
    _setupPersistence(skipInitialSave: dbValue == null);
  }

  /// 设置持久化监听
  void _setupPersistence({bool skipInitialSave = false}) {
    bool isFirstCall = true;
    effect(() {
      final currentValue = _signal.value;
      
      // 如果是第一次调用且需要跳过初始保存，则跳过
      if (isFirstCall && skipInitialSave) {
        isFirstCall = false;
        return;
      }
      
      isFirstCall = false;
      _saveToDatabase(currentValue);
    });
  }

  /// 保存值到文件存储
  void _saveToDatabase(T value) {
    Future.microtask(() async {
      try {
        // 对复杂类型进行编码处理
        final encodedValue = _encodeValue(value);
        await FileStorage().setPersistentValue('settings', key, encodedValue);
        if (kDebugMode) {
          print('[PersistentSignal] 保存到文件存储: $key = $value');
        }
      } catch (e) {
        if (kDebugMode) {
          print('[PersistentSignal] 保存到文件存储失败: $e');
        }
      }
    });
  }

  /// 解码文件存储值为目标类型
  T? _decodeValue(dynamic dbValue, T initialValue) {
    if (dbValue == null) return null;
    
    // 如果存储值已经是目标类型，直接返回
    if (dbValue is T) return dbValue;
    
    // 处理特殊编码格式（来自FileStorage的序列化）
    if (dbValue is Map<String, dynamic>) {
      final type = dbValue['_type'];
      final value = dbValue['_value'];
      
      if (type == 'enum' && value is String) {
        // 处理枚举类型
        if (T == ThemeMode) {
          switch (value) {
            case 'system':
              return ThemeMode.system as T;
            case 'light':
              return ThemeMode.light as T;
            case 'dark':
              return ThemeMode.dark as T;
            default:
              return null;
          }
        }
        return null;
      }
      
      if (type == 'string' && value is String) {
        return value as T;
      }
    }
    
    // 处理 ThemeMode 类型
    if (T == ThemeMode && dbValue is String) {
      switch (dbValue) {
        case 'system':
          return ThemeMode.system as T;
        case 'light':
          return ThemeMode.light as T;
        case 'dark':
          return ThemeMode.dark as T;
        default:
          return null;
      }
    }
    
    // 处理 Color 类型
    if (initialValue is Color && dbValue is int) {
      return Color(dbValue) as T;
    }
    
    // 处理 MaterialColor 和 MaterialAccentColor 类型
    if (initialValue.runtimeType.toString().contains('MaterialColor') || 
        initialValue.runtimeType.toString().contains('MaterialAccentColor')) {
      if (dbValue is int) {
        // 对于 MaterialColor 类型，我们无法完美重建，但可以创建一个基本的 Color
        // 然后让应用使用初始值，但记录文件存储中确实有值
        if (kDebugMode) {
          print('[PersistentSignal] MaterialColor 从文件存储加载颜色值: $dbValue，但使用初始值以保持完整性');
        }
        return null; // 继续使用初始值以保持 MaterialColor 的完整性
      }
    }
    
    // 处理枚举类型
    if (initialValue is Enum && dbValue is String) {
      // 这里需要根据具体的枚举类型来处理
      // 由于泛型限制，暂时返回 null
      return null;
    }
    
    // 处理 List 类型
    if (initialValue is List && dbValue is List) {
      try {
        return dbValue.cast<dynamic>() as T;
      } catch (e) {
        return null;
      }
    }
    
    // 处理 Map 类型
    if (initialValue is Map && dbValue is Map) {
      try {
        return Map<String, dynamic>.from(dbValue) as T;
      } catch (e) {
        return null;
      }
    }
    
    // 处理基本类型转换
    if (T == String) {
      return dbValue.toString() as T;
    }
    
    if (T == int && dbValue is num) {
      return dbValue.toInt() as T;
    }
    
    if (T == double && dbValue is num) {
      return dbValue.toDouble() as T;
    }
    
    if (T == bool) {
      if (dbValue is bool) return dbValue as T;
      if (dbValue is String) {
        return (dbValue.toLowerCase() == 'true') as T;
      }
    }
    
    // 无法解码，返回 null
    return null;
  }

  /// 编码值为可存储的格式
  dynamic _encodeValue(T value) {
    if (value == null) return null;
    
    // 处理基本类型 - 直接存储
    if (value is String || value is num || value is bool) {
      return value;
    }
    
    // 处理枚举类型 - 存储名称
    if (value is Enum) {
      return value.name;
    }
    
    // 处理 Color 类型 - 存储颜色值
    if (value is Color) {
      return value.value;
    }
    
    // 处理 ThemeMode 类型 - 存储名称
    if (value is ThemeMode) {
      return value.name;
    }
    
    // 处理 MaterialColor 和 MaterialAccentColor - 存储主要颜色值
    if (value.runtimeType.toString().contains('MaterialColor') || 
        value.runtimeType.toString().contains('MaterialAccentColor')) {
      // 获取主要颜色值
      try {
        final colorValue = (value as dynamic).value;
        return colorValue;
      } catch (e) {
        // 如果无法获取颜色值，返回字符串表示
        return value.toString();
      }
    }
    
    // 处理 List 类型
    if (value is List) {
      return value.map((item) => _encodeValue(item)).toList();
    }
    
    // 处理 Map 类型
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    
    // 其他复杂类型转为字符串
    return value.toString();
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
  String toString() => 'PersistentSignal<$T>(${_signal.value})';
}

/// 便捷的工厂函数，用于创建持久化信号

/// 创建持久化的字符串信号
PersistentSignal<String> persistentString({
  required String key,
  String initialValue = '',
}) => PersistentSignal(key, initialValue);

/// 创建持久化的整数信号
PersistentSignal<int> persistentInt({
  required String key,
  int initialValue = 0,
}) => PersistentSignal(key, initialValue);

/// 创建持久化的布尔信号
PersistentSignal<bool> persistentBool({
  required String key,
  bool initialValue = false,
}) => PersistentSignal(key, initialValue);

/// 创建持久化的双精度浮点数信号
PersistentSignal<double> persistentDouble({
  required String key,
  double initialValue = 0.0,
}) => PersistentSignal(key, initialValue);

/// 创建持久化的列表信号
PersistentSignal<List<T>> persistentList<T>({
  required String key,
  List<T>? initialValue,
}) => PersistentSignal(key, initialValue ?? <T>[]);

/// 创建持久化的可空整数信号
PersistentSignal<int?> persistentNullableInt({
  required String key,
  int? initialValue,
}) => PersistentSignal(key, initialValue);