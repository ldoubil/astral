// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConnectionInfoAdapter extends TypeAdapter<ConnectionInfo> {
  @override
  final int typeId = 12;

  @override
  ConnectionInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConnectionInfo()
      ..bindAddr = fields[0] as String
      ..dstAddr = fields[1] as String
      ..proto = fields[2] as String;
  }

  @override
  void write(BinaryWriter writer, ConnectionInfo obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.bindAddr)
      ..writeByte(1)
      ..write(obj.dstAddr)
      ..writeByte(2)
      ..write(obj.proto);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConnectionManagerAdapter extends TypeAdapter<ConnectionManager> {
  @override
  final int typeId = 13;

  @override
  ConnectionManager read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConnectionManager()
      ..name = fields[0] as String
      ..connections = (fields[1] as List).cast<ConnectionInfo>()
      ..enabled = fields[2] as bool;
  }

  @override
  void write(BinaryWriter writer, ConnectionManager obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.connections)
      ..writeByte(2)
      ..write(obj.enabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionManagerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ServerProtocolSwitchAdapter extends TypeAdapter<ServerProtocolSwitch> {
  @override
  final int typeId = 14;

  @override
  ServerProtocolSwitch read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ServerProtocolSwitch.tcp;
      case 1:
        return ServerProtocolSwitch.udp;
      case 2:
        return ServerProtocolSwitch.ws;
      case 3:
        return ServerProtocolSwitch.wss;
      case 4:
        return ServerProtocolSwitch.quic;
      case 5:
        return ServerProtocolSwitch.wg;
      case 6:
        return ServerProtocolSwitch.txt;
      case 7:
        return ServerProtocolSwitch.srv;
      case 8:
        return ServerProtocolSwitch.http;
      case 9:
        return ServerProtocolSwitch.https;
      default:
        return ServerProtocolSwitch.tcp;
    }
  }

  @override
  void write(BinaryWriter writer, ServerProtocolSwitch obj) {
    switch (obj) {
      case ServerProtocolSwitch.tcp:
        writer.writeByte(0);
        break;
      case ServerProtocolSwitch.udp:
        writer.writeByte(1);
        break;
      case ServerProtocolSwitch.ws:
        writer.writeByte(2);
        break;
      case ServerProtocolSwitch.wss:
        writer.writeByte(3);
        break;
      case ServerProtocolSwitch.quic:
        writer.writeByte(4);
        break;
      case ServerProtocolSwitch.wg:
        writer.writeByte(5);
        break;
      case ServerProtocolSwitch.txt:
        writer.writeByte(6);
        break;
      case ServerProtocolSwitch.srv:
        writer.writeByte(7);
        break;
      case ServerProtocolSwitch.http:
        writer.writeByte(8);
        break;
      case ServerProtocolSwitch.https:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServerProtocolSwitchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
