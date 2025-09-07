import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'adapter_type_ids.dart';

/// Color类型的Hive适配器
/// TypeId: AdapterTypeIds.color
class ColorAdapter extends TypeAdapter<Color> {
  @override
  final int typeId = AdapterTypeIds.color;

  @override
  Color read(BinaryReader reader) {
    // 读取ARGB值并重建Color对象
    final int value = reader.readInt();
    return Color(value);
  }

  @override
  void write(BinaryWriter writer, Color obj) {
    // 将Color的ARGB值写入
    writer.writeInt(obj.value);
  }
}