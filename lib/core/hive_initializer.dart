import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_settings.dart'; // 导入需要注册的模型

class HiveInitializer {
  // 初始化Hive（需在main函数中调用）
  static Future<void> init() async {
    try {
      // 初始化Hive Flutter绑定
      await Hive.initFlutter();

      // 注册所有Hive适配器（新增模型时，在此添加适配器）
      Hive.registerAdapter(ThemeModeAdapter());
      Hive.registerAdapter(AppSettingsAdapter());

      // 打开所需的Hive盒子（按类型/功能拆分盒子，避免混用）
      await Hive.openBox<AppSettings>('app_settings_box'); // 存储AppSettings
      await Hive.openBox<dynamic>('user_data_box');        // 存储用户基础数据（String/int/List等）

      print('Hive初始化成功');
    } catch (e) {
      print('Hive初始化失败: $e');
      rethrow; // 抛出错误，让上层处理（如弹窗提示）
    }
  }

  // 可选：关闭Hive（如退出登录时）
  static Future<void> close() async {
    await Hive.close();
    print('Hive已关闭');
  }
}