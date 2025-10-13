// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 10;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      themeColor: fields[0] as Color,
      themeMode: fields[1] as ThemeMode,
      currentLanguage: fields[2] as String,
    )
      ..room = fields[3] as int?
      ..playerName = fields[4] as String?
      ..listenList = (fields[5] as List?)?.cast<String>()
      ..customVpn = (fields[6] as List).cast<String>()
      ..userListSimple = fields[7] as bool
      ..closeMinimize = fields[8] as bool
      ..startup = fields[9] as bool
      ..startupMinimize = fields[10] as bool
      ..startupAutoConnect = fields[11] as bool
      ..autoSetMTU = fields[12] as bool
      ..beta = fields[13] as bool
      ..autoCheckUpdate = fields[14] as bool
      ..downloadAccelerate = fields[15] as String
      ..serverSortField = fields[16] as String
      ..sortOption = fields[17] as int
      ..sortOrder = fields[18] as int
      ..displayMode = fields[19] as int
      ..userId = fields[20] as String?
      ..latestVersion = fields[21] as String?;
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.themeColor)
      ..writeByte(1)
      ..write(obj.themeMode)
      ..writeByte(2)
      ..write(obj.currentLanguage)
      ..writeByte(3)
      ..write(obj.room)
      ..writeByte(4)
      ..write(obj.playerName)
      ..writeByte(5)
      ..write(obj.listenList)
      ..writeByte(6)
      ..write(obj.customVpn)
      ..writeByte(7)
      ..write(obj.userListSimple)
      ..writeByte(8)
      ..write(obj.closeMinimize)
      ..writeByte(9)
      ..write(obj.startup)
      ..writeByte(10)
      ..write(obj.startupMinimize)
      ..writeByte(11)
      ..write(obj.startupAutoConnect)
      ..writeByte(12)
      ..write(obj.autoSetMTU)
      ..writeByte(13)
      ..write(obj.beta)
      ..writeByte(14)
      ..write(obj.autoCheckUpdate)
      ..writeByte(15)
      ..write(obj.downloadAccelerate)
      ..writeByte(16)
      ..write(obj.serverSortField)
      ..writeByte(17)
      ..write(obj.sortOption)
      ..writeByte(18)
      ..write(obj.sortOrder)
      ..writeByte(19)
      ..write(obj.displayMode)
      ..writeByte(20)
      ..write(obj.userId)
      ..writeByte(21)
      ..write(obj.latestVersion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
