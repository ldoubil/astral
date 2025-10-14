// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_node.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServerNodeAdapter extends TypeAdapter<ServerNode> {
  @override
  final int typeId = 15;

  @override
  ServerNode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServerNode()
      ..id = fields[0] as String
      ..name = fields[1] as String
      ..host = fields[2] as String
      ..port = fields[3] as int
      ..protocolSwitch = fields[4] as ServerProtocolSwitch
      ..description = fields[5] as String
      ..version = fields[6] as String
      ..allowRelay = fields[7] as bool
      ..usagePercentage = fields[8] as double
      ..isPublic = fields[9] as bool;
  }

  @override
  void write(BinaryWriter writer, ServerNode obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.host)
      ..writeByte(3)
      ..write(obj.port)
      ..writeByte(4)
      ..write(obj.protocolSwitch)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.version)
      ..writeByte(7)
      ..write(obj.allowRelay)
      ..writeByte(8)
      ..write(obj.usagePercentage)
      ..writeByte(9)
      ..write(obj.isPublic);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerNodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
