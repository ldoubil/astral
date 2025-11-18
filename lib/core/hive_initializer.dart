import 'dart:io';
import 'package:astral/models/net_node.dart';
import 'package:astral/models/server_node.dart';
import 'package:astral/models/room_config.dart';
import 'package:astral/models/room_info.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../models/app_settings.dart';
import '../models/base.dart'; // 导入需要注册的模型

class HiveInitializer {
  static Box<dynamic>? _basicDataBox;

  /// 获取基础数据盒子实例
  static Box<dynamic> get basicDataBox {
    if (_basicDataBox == null || !_basicDataBox!.isOpen) {
      throw Exception('BasicData 盒子未初始化或已关闭，请先调用 HiveInitializer.init()');
    }
    return _basicDataBox!;
  }

  // 初始化Hive（需在main函数中调用）
  static Future<void> init({bool isRetry = false}) async {
    try {
      // 初始化Hive Flutter绑定（如果尚未初始化）
      try {
        await Hive.initFlutter();
      } catch (e) {
        // 如果已经初始化，忽略错误
        if (!e.toString().contains('already initialized')) {
          rethrow;
        }
      }

      // 注册所有Hive适配器（新增模型时，在此添加适配器）
      // 使用 try-catch 处理适配器已注册的情况
      _registerAdapterSafely(() => Hive.registerAdapter(AppSettingsAdapter()));
      _registerAdapterSafely(
        () => Hive.registerAdapter(ConnectionManagerAdapter()),
      );
      _registerAdapterSafely(
        () => Hive.registerAdapter(ConnectionInfoAdapter()),
      );
      _registerAdapterSafely(() => Hive.registerAdapter(ServerNodeAdapter()));
      _registerAdapterSafely(
        () => Hive.registerAdapter(ServerProtocolSwitchAdapter()),
      );
      _registerAdapterSafely(
        () => Hive.registerAdapter(RoomConfigAdapter()),
      ); // 注册RoomConfig适配器
      _registerAdapterSafely(
        () => Hive.registerAdapter(RoomInfoAdapter()),
      ); // 注册RoomInfo适配器

      // 打开所需的Hive盒子（按类型/功能拆分盒子，避免混用）
      await Hive.openBox<AppSettings>('AppSettings'); // 存储AppSettings
      await Hive.openBox<ServerNode>('V2ServerNodes'); // 存储服务器节点数据
      await Hive.openBox<RoomConfig>('RoomConfigs'); // 存储房间配置
      await Hive.openBox<RoomInfo>('V2Rooms'); // 存储V2房间数据
      _basicDataBox = await Hive.openBox<dynamic>(
        'BasicData',
      ); // 存储用户基础数据（String/int/List等）

      print('Hive初始化成功');
    } catch (e) {
      print('Hive初始化失败: $e');

      // 检查是否为类型转换错误，且不是重试过程中
      final errorString = e.toString();
      if (!isRetry &&
          (errorString.contains('is not a subtype of type') ||
              errorString.contains('type cast'))) {
        print('检测到类型转换错误，正在删除数据库并重新初始化...');
        try {
          // 删除所有数据库
          await _deleteAllHiveBoxes();
          // 重新初始化（标记为重试）
          await init(isRetry: true);
          print('数据库已删除并重新初始化成功');
          return;
        } catch (retryError) {
          print('删除数据库并重新初始化失败: $retryError');
          rethrow;
        }
      }

      rethrow; // 其他错误直接抛出
    }
  }

  /// 安全注册适配器，如果已注册则跳过
  static void _registerAdapterSafely(void Function() registerFn) {
    try {
      registerFn();
    } catch (e) {
      // 如果适配器已注册，忽略错误
      if (e.toString().contains('already a TypeAdapter')) {
        print('适配器已注册，跳过: $e');
      } else {
        // 其他错误重新抛出
        rethrow;
      }
    }
  }

  /// 删除所有Hive数据库盒子
  static Future<void> _deleteAllHiveBoxes() async {
    try {
      // 先关闭所有已打开的盒子
      _basicDataBox = null;

      // 定义所有盒子名称
      final boxNames = [
        'AppSettings',
        'ServerNodes',
        'V2ServerNodes',
        'BaseNetNodeConfig',
        'RoomConfigs',
        'V2Rooms',
        'BasicData',
      ];

      // 尝试关闭所有已打开的盒子（如果Hive已初始化）
      try {
        // 关闭所有已知的盒子
        for (final boxName in boxNames) {
          try {
            final box = Hive.box(boxName);
            if (box.isOpen) {
              await box.close();
            }
          } catch (e) {
            // 如果盒子不存在或未打开，忽略错误
            print('关闭盒子 $boxName 时出错（可能不存在）: $e');
          }
        }
        // 关闭 Hive（这会清除适配器注册）
        await Hive.close();
      } catch (e) {
        // 如果Hive未初始化或已关闭，忽略错误
        print('关闭Hive时出错（可能未初始化）: $e');
      }

      // 删除每个盒子
      for (final boxName in boxNames) {
        try {
          await Hive.deleteBoxFromDisk(boxName);
          print('已删除盒子: $boxName');
        } catch (e) {
          // 如果盒子不存在，忽略错误
          print('删除盒子 $boxName 时出错（可能不存在）: $e');
        }
      }

      // 尝试删除整个Hive目录（如果存在）
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        final hiveDir = Directory('${appDocDir.path}/hive');
        if (await hiveDir.exists()) {
          await hiveDir.delete(recursive: true);
          print('已删除Hive目录');
        }
      } catch (e) {
        print('删除Hive目录时出错: $e');
        // 忽略错误，继续执行
      }
    } catch (e) {
      print('删除Hive数据库时出错: $e');
      rethrow;
    }
  }

  /// 快捷注册基础类型数据的方法
  /// 支持 String、int、double、bool、Color、ThemeMode、List&lt;String&gt;、List&lt;int&gt; 等基础类型
  /// [key] 数据的唯一标识符
  /// [defaultValue] 默认值，当数据不存在时返回此值
  /// [autoSave] 是否自动保存（默认为 true）
  static T registerBasicData<T>(
    String key,
    T defaultValue, {
    bool autoSave = true,
  }) {
    try {
      // 验证类型是否为支持的基础类型
      if (!_isSupportedType<T>()) {
        throw ArgumentError(
          '不支持的数据类型: ${T.toString()}。仅支持 String、int、double、bool、Color、ThemeMode、List&lt;String&gt;、List&lt;int&gt; 等基础类型',
        );
      }

      // 从 Hive 中获取数据，如果不存在则使用默认值
      dynamic storedValue = basicDataBox.get(key);
      T value;

      if (storedValue == null) {
        value = defaultValue;
        // 如果是默认值且启用自动保存，则保存默认值
        if (autoSave) {
          _saveValueToHive(key, defaultValue);
          print('已保存默认基础数据: $key = $defaultValue');
        }
      } else {
        value = _parseValueFromHive<T>(storedValue, defaultValue);
        print('已加载基础数据: $key = $value');
      }

      return value;
    } catch (e) {
      print('注册基础数据失败 [$key]: $e');
      return defaultValue;
    }
  }

  /// 保存基础类型数据
  /// [key] 数据的唯一标识符
  /// [value] 要保存的值
  static Future<void> saveBasicData<T>(String key, T value) async {
    try {
      if (!_isSupportedType<T>()) {
        throw ArgumentError('不支持的数据类型: ${T.toString()}');
      }

      await _saveValueToHive(key, value);
      print('已保存基础数据: $key = $value');
    } catch (e) {
      print('保存基础数据失败 [$key]: $e');
      rethrow;
    }
  }

  /// 获取基础类型数据
  /// [key] 数据的唯一标识符
  /// [defaultValue] 默认值
  static T getBasicData<T>(String key, T defaultValue) {
    try {
      dynamic storedValue = basicDataBox.get(key);
      if (storedValue == null) {
        return defaultValue;
      }
      return _parseValueFromHive<T>(storedValue, defaultValue);
    } catch (e) {
      print('获取基础数据失败 [$key]: $e');
      return defaultValue;
    }
  }

  /// 删除基础类型数据
  /// [key] 数据的唯一标识符
  static Future<void> deleteBasicData(String key) async {
    try {
      await basicDataBox.delete(key);
      print('已删除基础数据: $key');
    } catch (e) {
      print('删除基础数据失败 [$key]: $e');
      rethrow;
    }
  }

  /// 检查类型是否为支持的基础类型
  static bool _isSupportedType<T>() {
    final typeString = T.toString();
    return T == String ||
        T == int ||
        T == double ||
        T == bool ||
        T == Color ||
        T == ThemeMode ||
        typeString == 'List<String>' ||
        typeString == 'List<int>' ||
        typeString == 'List<double>' ||
        typeString == 'List<bool>';
  }

  /// 将值保存到 Hive，处理特殊类型的序列化
  static Future<void> _saveValueToHive<T>(String key, T value) async {
    dynamic valueToStore;

    if (value is Color) {
      // Color 转换为 int 值存储 (使用 toARGB32() 方法)
      valueToStore = value.value;
    } else if (value is ThemeMode) {
      // ThemeMode 转换为 int 索引存储
      valueToStore = value.index;
    } else {
      // 其他基础类型直接存储
      valueToStore = value;
    }

    await basicDataBox.put(key, valueToStore);
  }

  /// 从 Hive 解析值，处理特殊类型的反序列化
  static T _parseValueFromHive<T>(dynamic storedValue, T defaultValue) {
    try {
      if (T == Color) {
        // 从 int 值恢复 Color
        if (storedValue is int) {
          return Color(storedValue) as T;
        }
      } else if (T == ThemeMode) {
        // 从 int 索引恢复 ThemeMode
        if (storedValue is int) {
          final themeModes = ThemeMode.values;
          if (storedValue >= 0 && storedValue < themeModes.length) {
            return themeModes[storedValue] as T;
          }
        }
      } else {
        // 其他基础类型直接转换
        return storedValue as T;
      }
    } catch (e) {
      print('解析存储值失败: $e，使用默认值');
    }

    return defaultValue;
  }

  // 可选：关闭Hive（如退出登录时）
  static Future<void> close() async {
    await Hive.close();
    _basicDataBox = null;
    print('Hive已关闭');
  }
}
