import 'package:signals_flutter/signals_flutter.dart';
import 'hive_initializer.dart';

/// 持久化 Signal 类
/// 继承自 Signal，提供自动加载和保存功能
/// 支持基础类型数据的持久化存储
class PersistentSignal<T> extends Signal<T> {
  final String _key;
  final T _defaultValue;
  final bool _autoSave;

  /// 构造函数
  /// [key] 数据在 Hive 中的唯一标识符
  /// [defaultValue] 默认值
  /// [autoSave] 是否自动保存（默认为 true）
  PersistentSignal(this._key, this._defaultValue, {bool autoSave = true})
      : _autoSave = autoSave,
        super(_loadInitialValue(_key, _defaultValue)) {
    _setupAutoSave();
  }

  /// 从 Hive 加载初始值
  static T _loadInitialValue<T>(String key, T defaultValue) {
    try {
      return HiveInitializer.registerBasicData<T>(key, defaultValue);
    } catch (e) {
      print('加载持久化信号初始值失败 [$key]: $e');
      return defaultValue;
    }
  }

  /// 设置自动保存监听
  void _setupAutoSave() {
    if (_autoSave) {
      // 监听值的变化，自动保存到 Hive
      effect(() {
        _saveValue(value);
      });
    }
  }

  /// 保存值到 Hive
  void _saveValue(T newValue) {
    try {
      HiveInitializer.saveBasicData<T>(_key, newValue);
    } catch (e) {
      print('保存持久化信号值失败 [$_key]: $e');
    }
  }

  /// 手动保存当前值
  /// 当 autoSave 为 false 时，可以调用此方法手动保存
  Future<void> save() async {
    try {
      await HiveInitializer.saveBasicData<T>(_key, value);
    } catch (e) {
      print('手动保存持久化信号值失败 [$_key]: $e');
      rethrow;
    }
  }

  /// 重新加载值从 Hive
  /// 从存储中重新加载值，覆盖当前内存中的值
  void reload() {
    try {
      final loadedValue = HiveInitializer.getBasicData<T>(_key, _defaultValue);
      value = loadedValue;
    } catch (e) {
      print('重新加载持久化信号值失败 [$_key]: $e');
    }
  }

  /// 重置为默认值
  /// 将值重置为初始默认值，并保存到存储
  void reset() {
    value = _defaultValue;
    if (_autoSave) {
      _saveValue(_defaultValue);
    }
  }

  /// 删除存储的数据
  /// 从 Hive 中删除对应的数据，但不影响当前内存中的值
  Future<void> delete() async {
    try {
      await HiveInitializer.deleteBasicData(_key);
    } catch (e) {
      print('删除持久化信号数据失败 [$_key]: $e');
      rethrow;
    }
  }

  /// 获取存储键
  String get key => _key;

  /// 获取默认值
  T get defaultValue => _defaultValue;

  /// 是否启用自动保存
  bool get autoSave => _autoSave;
}

/// 创建持久化 Signal 的便捷函数
/// [key] 数据在 Hive 中的唯一标识符
/// [defaultValue] 默认值
/// [autoSave] 是否自动保存（默认为 true）
PersistentSignal<T> persistentSignal<T>(String key, T defaultValue, {bool autoSave = true}) {
  return PersistentSignal<T>(key, defaultValue, autoSave: autoSave);
}