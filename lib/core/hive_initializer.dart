import 'package:astral/models/net_node.dart';
import 'package:astral/models/server_node.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
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
  static Future<void> init() async {
    try {
      // 初始化Hive Flutter绑定
      await Hive.initFlutter();

      // 注册所有Hive适配器（新增模型时，在此添加适配器）
      Hive.registerAdapter(AppSettingsAdapter());
      Hive.registerAdapter(NetNodeAdapter());
      Hive.registerAdapter(ConnectionManagerAdapter());
      Hive.registerAdapter(ConnectionInfoAdapter());
      Hive.registerAdapter(ServerNodeAdapter());
      Hive.registerAdapter(ServerProtocolSwitchAdapter());

      // 打开所需的Hive盒子（按类型/功能拆分盒子，避免混用）
      await Hive.openBox<AppSettings>('AppSettings'); // 存储AppSettings
      await Hive.openBox<ServerNode>('ServerNodes'); // 存储服务器节点数据
      await Hive.openBox<NetNode>('BaseNetNodeConfig'); // 存储基础网络节点配置
      _basicDataBox = await Hive.openBox<dynamic>('BasicData'); // 存储用户基础数据（String/int/List等）

      print('Hive初始化成功');
    } catch (e) {
      print('Hive初始化失败: $e');
      rethrow; // 抛出错误，让上层处理（如弹窗提示）
    }
  }

  /// 快捷注册基础类型数据的方法
  /// 支持 String、int、double、bool、Color、ThemeMode、List&lt;String&gt;、List&lt;int&gt; 等基础类型
  /// [key] 数据的唯一标识符
  /// [defaultValue] 默认值，当数据不存在时返回此值
  /// [autoSave] 是否自动保存（默认为 true）
  static T registerBasicData<T>(String key, T defaultValue, {bool autoSave = true}) {
    try {
      // 验证类型是否为支持的基础类型
      if (!_isSupportedType<T>()) {
        throw ArgumentError('不支持的数据类型: ${T.toString()}。仅支持 String、int、double、bool、Color、ThemeMode、List&lt;String&gt;、List&lt;int&gt; 等基础类型');
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

