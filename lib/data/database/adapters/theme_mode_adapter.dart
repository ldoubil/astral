import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'adapter_type_ids.dart';

/// ThemeMode类型的Hive适配器
/// TypeId: AdapterTypeIds.themeMode
class ThemeModeAdapter extends TypeAdapter<ThemeMode> {
  @override
  final int typeId = AdapterTypeIds.themeMode;

  @override
  ThemeMode read(BinaryReader reader) {
    // 读取索引值并转换为ThemeMode枚举
    final int index = reader.readInt();
    switch (index) {
      case 0:
        return ThemeMode.system;
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system; // 默认值
    }
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    // 将ThemeMode枚举的索引值写入
    writer.writeInt(obj.index);
  }
}