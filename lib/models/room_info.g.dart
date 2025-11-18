// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RoomInfoAdapter extends TypeAdapter<RoomInfo> {
  @override
  final int typeId = 37;

  @override
  RoomInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RoomInfo()
      ..name = fields[0] as String
      ..uuid = fields[1] as String
      ..servers = (fields[2] as List).cast<ServerNode>();
  }

  @override
  void write(BinaryWriter writer, RoomInfo obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.uuid)
      ..writeByte(2)
      ..write(obj.servers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
