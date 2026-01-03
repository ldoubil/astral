import 'package:astral/k/database/app_data.dart';
import 'package:flutter/material.dart';

/// 主题相关的数据持久化
class ThemeRepository {
  final AppDatabase _db;

  ThemeRepository(this._db);

  // ========== 读取操作 ==========

  Future<ThemeMode> getThemeMode() async {
    return await _db.themeSettings.getThemeMode();
  }

  Future<Color> getThemeColor() async {
    final colorValue = await _db.themeSettings.getThemeColor();
    return Color(colorValue);
  }

  // ========== 写入操作 ==========

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _db.themeSettings.updateThemeMode(mode);
  }

  Future<void> saveThemeColor(Color color) async {
    await _db.themeSettings.updateThemeColor(color.value);
  }

  // ========== 批量操作 ==========

  Future<ThemeConfig> loadAll() async {
    final mode = await getThemeMode();
    final color = await getThemeColor();

    return ThemeConfig(mode: mode, color: color);
  }

  Future<void> saveAll(ThemeConfig config) async {
    await _db.themeSettings.updateThemeMode(config.mode);
    await _db.themeSettings.updateThemeColor(config.color.value);
  }
}

/// 主题配置数据类
class ThemeConfig {
  final ThemeMode mode;
  final Color color;

  ThemeConfig({required this.mode, required this.color});

  ThemeConfig copyWith({ThemeMode? mode, Color? color}) {
    return ThemeConfig(mode: mode ?? this.mode, color: color ?? this.color);
  }
}
