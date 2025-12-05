import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import '../models/theme_settings.dart';

/// 主题设置仓库类
/// 负责管理和持久化主题相关的设置
class ThemeSettingsRepository {
  /// Isar数据库实例
  final Isar _isar;

  /// 构造函数
  /// @param _isar Isar数据库实例
  /// 创建实例时自动初始化数据
  ThemeSettingsRepository(this._isar) {
    init();
  }

  /// 初始化主题设置
  /// 如果数据库中没有主题设置记录，则创建一个默认的设置记录
  Future<void> init() async {
    if (await _isar.themeSettings.count() == 0) {
      await _isar.writeTxn(() async {
        await _isar.themeSettings.put(ThemeSettings()..id = 1);
      });
    }
  }

  /// 更新主题颜色
  /// @param colorValue 新的颜色值
  /// 将新的颜色值保存到数据库中
  Future<void> updateThemeColor(int colorValue) async {
    ThemeSettings? settings = await _isar.themeSettings.get(1);
    if (settings != null) {
      settings.colorValue = colorValue;
      await _isar.writeTxn(() async {
        await _isar.themeSettings.put(settings);
      });
    }
  }

  /// 获取当前主题颜色
  /// @return 返回当前的主题颜色值，如果未设置则返回0
  Future<int> getThemeColor() async {
    ThemeSettings? settings = await _isar.themeSettings.get(1);
    return settings?.colorValue ?? 0xFFFF5722;
  }

  /// 更新主题模式
  /// @param themeMode 新的主题模式(light/dark/system)
  /// 将新的主题模式保存到数据库中
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    ThemeSettings? settings = await _isar.themeSettings.get(1);
    if (settings != null) {
      settings.themeModeValue = themeMode;
      await _isar.writeTxn(() async {
        await _isar.themeSettings.put(settings);
      });
    }
  }

  /// 获取当前主题模式
  /// @return 返回当前的主题模式，如果未设置则返回系统默认模式
  Future<ThemeMode> getThemeMode() async {
    ThemeSettings? settings = await _isar.themeSettings.get(1);
    return settings?.themeModeValue ?? ThemeMode.system;
  }
}
