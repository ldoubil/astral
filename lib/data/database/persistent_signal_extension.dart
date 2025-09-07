import 'package:hive/hive.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 使用 Hive 使信号持久化的扩展
extension PersistentSignalExtension<T> on Signal<T> {
  /// 使用 Hive 存储使此信号持久化
  /// 常用的box（theme、app_settings）已在应用启动时预打开，避免UI闪烁
  /// 会先从数据库加载值，如果数据库中没有值则保存当前Signal的值作为默认值
  Future<void> persistWith(String boxName, String key) async {
    // 尝试同步加载已存在的值（常用box已预打开）
    _loadFromStorageSync(boxName, key);
    
    // 确保 box 已打开（对于非常用box）
    await _ensureBoxOpen(boxName);
    
    // 从存储中加载初始值，如果没有则保存当前值
    _loadFromStorageOrSaveDefault(boxName, key);

    // 监听变化并保存到存储
     effect(() {
       _saveToStorage(boxName, key, value);
     });
  }

  /// 确保指定的 box 已打开
  Future<void> _ensureBoxOpen(String boxName) async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox(boxName);
        print('自动打开 Hive box: $boxName');
      }
    } catch (e) {
      print('打开 Hive box "$boxName" 失败: $e');
      // 如果是适配器相关错误，尝试删除损坏的box并重新创建
      if (e.toString().contains('unknown typeId') || e.toString().contains('adapter')) {
        print('检测到适配器错误，尝试清理并重新创建 box: $boxName');
        try {
          await Hive.deleteBoxFromDisk(boxName);
          await Hive.openBox(boxName);
          print('成功重新创建 Hive box: $boxName');
        } catch (cleanupError) {
          print('清理 box 失败: $cleanupError');
        }
      }
    }
  }

  /// 尝试同步加载存储中的值（如果box已打开）
  void _loadFromStorageSync(String boxName, String key) {
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        if (box.containsKey(key)) {
          final storedValue = box.get(key);
          if (storedValue != null) {
            value = storedValue as T;
          }
        }
      }
    } catch (e) {
      // 忽略同步加载错误，稍后异步加载会处理
    }
  }

  /// 从 Hive 存储中加载值，如果没有则保存当前值作为默认值
  void _loadFromStorageOrSaveDefault(String boxName, String key) {
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        final storedValue = box.get(key);
        if (storedValue != null) {
          value = storedValue as T;
        } else {
          // 如果存储中没有值，保存当前Signal的值作为默认值
          box.put(key, value);
        }
      } else {
        print('警告: box "$boxName" 未打开，无法加载数据');
      }
    } catch (e) {
      print('从存储加载信号值失败：$e');
      // 如果是类型转换错误，使用默认值并重新保存
      if (e.toString().contains('type') || e.toString().contains('cast')) {
        print('检测到类型错误，使用默认值并重新保存');
        try {
          if (Hive.isBoxOpen(boxName)) {
            final box = Hive.box(boxName);
            box.put(key, value); // 保存当前默认值
          }
        } catch (saveError) {
          print('保存默认值失败: $saveError');
        }
      }
    }
  }

  /// 保存值到 Hive 存储
  void _saveToStorage(String boxName, String key, T value) {
    try {
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        box.put(key, value);
      } else {
        print('警告: box "$boxName" 未打开，无法保存数据');
      }
    } catch (e) {
      print('保存信号值到存储失败：$e');
    }
  }
}
