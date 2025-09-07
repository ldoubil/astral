import 'package:hive/hive.dart';
import 'adapter_type_ids.dart';
import 'color_adapter.dart';
import 'theme_mode_adapter.dart';

/// Hive适配器管理器
/// 统一管理所有自定义类型的适配器注册
class AdapterManager {
  /// 注册所有适配器
  /// 在应用启动时调用，确保所有自定义类型都有对应的适配器
  static void registerAllAdapters() {
    // 注册Color适配器
    if (!Hive.isAdapterRegistered(AdapterTypeIds.color)) {
      Hive.registerAdapter(ColorAdapter());
    }
    
    // 注册ThemeMode适配器
    if (!Hive.isAdapterRegistered(AdapterTypeIds.themeMode)) {
      Hive.registerAdapter(ThemeModeAdapter());
    }
    
    // 在此处添加其他适配器的注册
    // 例如:
    // if (!Hive.isAdapterRegistered(34)) {
    //   Hive.registerAdapter(CustomTypeAdapter());
    // }
  }
  
  /// 获取已注册的适配器数量
  /// 注意：Hive没有直接提供获取所有适配器的方法，这里返回已知的适配器数量
  static int getRegisteredAdapterCount() {
    int count = 0;
    // 检查已知的适配器
    if (Hive.isAdapterRegistered(AdapterTypeIds.color)) count++; // Color适配器
    if (Hive.isAdapterRegistered(AdapterTypeIds.themeMode)) count++; // ThemeMode适配器
    // 在此处添加其他已知适配器的检查
    return count;
  }
  
  /// 检查指定typeId的适配器是否已注册
  static bool isAdapterRegistered(int typeId) {
    return Hive.isAdapterRegistered(typeId);
  }
}