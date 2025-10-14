// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_json_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServerJsonNode _$ServerJsonNodeFromJson(Map<String, dynamic> json) =>
    ServerJsonNode(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      host: json['host'] as String,
      port: (json['port'] as num).toInt(),
      protocol: json['protocol'] as String,
      version: json['version'] as String,
      description: json['description'] as String,
      maxConnections: (json['max_connections'] as num).toInt(),
      currentConnections: (json['current_connections'] as num).toInt(),
      isActive: json['is_active'] as bool,
      isApproved: json['is_approved'] as bool,
      allowRelay: json['allow_relay'] as bool,
      networkName: json['network_name'] as String?,
      networkSecret: json['network_secret'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      address: json['address'] as String,
      usagePercentage: (json['usage_percentage'] as num?)?.toDouble(),
      currentHealthStatus: json['current_health_status'] as String?,
      lastCheckTime: json['last_check_time'] as String?,
      lastResponseTime: (json['last_response_time'] as num?)?.toInt(),
      healthPercentage24h: (json['health_percentage_24h'] as num?)?.toDouble(),
      healthRecordTotalCounterRing:
          (json['health_record_total_counter_ring'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList(),
      healthRecordHealthyCounterRing:
          (json['health_record_healthy_counter_ring'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList(),
      ringGranularity: (json['ring_granularity'] as num?)?.toInt(),
      qqNumber: json['qq_number'] as String?,
      wechat: json['wechat'] as String?,
      mail: json['mail'] as String?,
    );

Map<String, dynamic> _$ServerJsonNodeToJson(ServerJsonNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'host': instance.host,
      'port': instance.port,
      'protocol': instance.protocol,
      'version': instance.version,
      'description': instance.description,
      'max_connections': instance.maxConnections,
      'current_connections': instance.currentConnections,
      'is_active': instance.isActive,
      'is_approved': instance.isApproved,
      'allow_relay': instance.allowRelay,
      'network_name': instance.networkName,
      'network_secret': instance.networkSecret,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'address': instance.address,
      'usage_percentage': instance.usagePercentage,
      'current_health_status': instance.currentHealthStatus,
      'last_check_time': instance.lastCheckTime,
      'last_response_time': instance.lastResponseTime,
      'health_percentage_24h': instance.healthPercentage24h,
      'health_record_total_counter_ring': instance.healthRecordTotalCounterRing,
      'health_record_healthy_counter_ring':
          instance.healthRecordHealthyCounterRing,
      'ring_granularity': instance.ringGranularity,
      'qq_number': instance.qqNumber,
      'wechat': instance.wechat,
      'mail': instance.mail,
    };
