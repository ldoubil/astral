// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plugin.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PluginAdapter extends TypeAdapter<Plugin> {
  @override
  final int typeId = 3;

  @override
  Plugin read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Plugin(
      id: fields[0] as String,
      name: fields[1] as String,
      version: fields[2] as String,
      description: fields[3] as String,
      author: fields[4] as String,
      homepage: fields[5] as String?,
      status: fields[6] as PluginStatus,
      entryPoint: fields[7] as String,
      installPath: fields[8] as String,
      config: (fields[9] as Map?)?.cast<String, dynamic>(),
      dependencies: (fields[10] as List?)?.cast<String>(),
      permissions: (fields[11] as List?)?.cast<String>(),
      installTime: fields[12] as DateTime,
      lastUpdate: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Plugin obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.version)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.author)
      ..writeByte(5)
      ..write(obj.homepage)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.entryPoint)
      ..writeByte(8)
      ..write(obj.installPath)
      ..writeByte(9)
      ..write(obj.config)
      ..writeByte(10)
      ..write(obj.dependencies)
      ..writeByte(11)
      ..write(obj.permissions)
      ..writeByte(12)
      ..write(obj.installTime)
      ..writeByte(13)
      ..write(obj.lastUpdate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PluginStatusAdapter extends TypeAdapter<PluginStatus> {
  @override
  final int typeId = 17;

  @override
  PluginStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PluginStatus.enabled;
      case 1:
        return PluginStatus.disabled;
      case 2:
        return PluginStatus.error;
      default:
        return PluginStatus.enabled;
    }
  }

  @override
  void write(BinaryWriter writer, PluginStatus obj) {
    switch (obj) {
      case PluginStatus.enabled:
        writer.writeByte(0);
        break;
      case PluginStatus.disabled:
        writer.writeByte(1);
        break;
      case PluginStatus.error:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PluginStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Plugin _$PluginFromJson(Map<String, dynamic> json) => Plugin(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      author: json['author'] as String,
      homepage: json['homepage'] as String?,
      status: $enumDecodeNullable(_$PluginStatusEnumMap, json['status']) ??
          PluginStatus.disabled,
      entryPoint: json['entry_point'] as String,
      installPath: json['install_path'] as String,
      config: json['config'] as Map<String, dynamic>?,
      dependencies: (json['dependencies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      permissions: (json['permissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      installTime: DateTime.parse(json['install_time'] as String),
      lastUpdate: DateTime.parse(json['last_update'] as String),
    );

Map<String, dynamic> _$PluginToJson(Plugin instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'version': instance.version,
      'description': instance.description,
      'author': instance.author,
      'homepage': instance.homepage,
      'status': _$PluginStatusEnumMap[instance.status]!,
      'entry_point': instance.entryPoint,
      'install_path': instance.installPath,
      'config': instance.config,
      'dependencies': instance.dependencies,
      'permissions': instance.permissions,
      'install_time': instance.installTime.toIso8601String(),
      'last_update': instance.lastUpdate.toIso8601String(),
    };

const _$PluginStatusEnumMap = {
  PluginStatus.enabled: 'enabled',
  PluginStatus.disabled: 'disabled',
  PluginStatus.error: 'error',
};

PluginManifest _$PluginManifestFromJson(Map<String, dynamic> json) =>
    PluginManifest(
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      author: json['author'] as String,
      homepage: json['homepage'] as String?,
      entryPoint: json['entry_point'] as String,
      minAppVersion: json['min_app_version'] as String?,
      dependencies: (json['dependencies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      permissions: (json['permissions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      apiVersion: json['api_version'] as String?,
    );

Map<String, dynamic> _$PluginManifestToJson(PluginManifest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'version': instance.version,
      'description': instance.description,
      'author': instance.author,
      'homepage': instance.homepage,
      'entry_point': instance.entryPoint,
      'min_app_version': instance.minAppVersion,
      'dependencies': instance.dependencies,
      'permissions': instance.permissions,
      'api_version': instance.apiVersion,
    };
