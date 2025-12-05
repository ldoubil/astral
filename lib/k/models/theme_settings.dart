import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
part 'theme_settings.g.dart';

/// 主题设置类
@collection
class ThemeSettings {
  /// 主键ID，固定为1因为只需要一个实例
  Id id = 1;

  /// 主题颜色值，默认为蓝色
  int colorValue = Colors.blue.toARGB32();

  /// 主题模式枚举值，默认跟随系统
  @enumerated
  ThemeMode themeModeValue = ThemeMode.system;

  /// 构造函数，用于初始化主题设置
  ThemeSettings({
    this.colorValue = 0xFFFF5722,
    this.themeModeValue = ThemeMode.system,
  });
}
