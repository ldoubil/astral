// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoomConfigAdapter extends TypeAdapter<RoomConfig> {
  @override
  final int typeId = 16;

  @override
  RoomConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoomConfig()
      ..room_uuid = fields[0] as String
      ..room_name = fields[1] as String
      ..room_protect = fields[2] as bool
      ..create_time = fields[3] as DateTime
      ..version = fields[4] as int
      ..room_public = fields[5] as NetNode
      ..server = (fields[6] as List).cast<ServerNode>()
      ..priority = fields[7] as int
      ..room_desc = fields[8] as String;
  }

  @override
  void write(BinaryWriter writer, RoomConfig obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.room_uuid)
      ..writeByte(1)
      ..write(obj.room_name)
      ..writeByte(2)
      ..write(obj.room_protect)
      ..writeByte(3)
      ..write(obj.create_time)
      ..writeByte(4)
      ..write(obj.version)
      ..writeByte(5)
      ..write(obj.room_public)
      ..writeByte(6)
      ..write(obj.server)
      ..writeByte(7)
      ..write(obj.priority)
      ..writeByte(8)
      ..write(obj.room_desc);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
