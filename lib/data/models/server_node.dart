import 'package:json_annotation/json_annotation.dart';

part 'server_node.g.dart';

@JsonSerializable()
class ServerNode {
  final int id;
  final String name;
  final String host;
  final int port;
  final String protocol;
  final String version;
  final String description;
  @JsonKey(name: 'max_connections')
  final int maxConnections;
  @JsonKey(name: 'current_connections')
  final int currentConnections;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_approved')
  final bool isApproved;
  @JsonKey(name: 'allow_relay')
  final bool allowRelay;
  @JsonKey(name: 'network_name')
  final String? networkName;
  @JsonKey(name: 'network_secret')
  final String? networkSecret;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  final String address;
  @JsonKey(name: 'usage_percentage')
  final double? usagePercentage;
  @JsonKey(name: 'current_health_status')
  final String? currentHealthStatus;
  @JsonKey(name: 'last_check_time')
  final String? lastCheckTime;
  @JsonKey(name: 'last_response_time')
  final int? lastResponseTime;
  @JsonKey(name: 'health_percentage_24h')
  final double? healthPercentage24h;
  @JsonKey(name: 'health_record_total_counter_ring')
  final List<int>? healthRecordTotalCounterRing;
  @JsonKey(name: 'health_record_healthy_counter_ring')
  final List<int>? healthRecordHealthyCounterRing;
  @JsonKey(name: 'ring_granularity')
  final int? ringGranularity;
  @JsonKey(name: 'qq_number')
  final String? qqNumber;
  final String? wechat;
  final String? mail;

  ServerNode({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.protocol,
    required this.version,
    required this.description,
    required this.maxConnections,
    required this.currentConnections,
    required this.isActive,
    required this.isApproved,
    required this.allowRelay,
    this.networkName,
    this.networkSecret,
    required this.createdAt,
    required this.updatedAt,
    required this.address,
    this.usagePercentage,
    this.currentHealthStatus,
    this.lastCheckTime,
    this.lastResponseTime,
    this.healthPercentage24h,
    this.healthRecordTotalCounterRing,
    this.healthRecordHealthyCounterRing,
    this.ringGranularity,
    this.qqNumber,
    this.wechat,
    this.mail,
  });

  factory ServerNode.fromJson(Map<String, dynamic> json) =>
      _$ServerNodeFromJson(json);
  Map<String, dynamic> toJson() => _$ServerNodeToJson(this);

  // 便利方法
  bool get isHealthy => currentHealthStatus == 'healthy';
  bool get isOnline => isActive && isApproved;
  String get statusText => isHealthy ? '在线' : '离线';
  String get loadPercentageText => '${(usagePercentage ?? 0).toInt()}%';
  double get safeHealthPercentage24h => healthPercentage24h ?? 0.0;
  int get safeLastResponseTime => lastResponseTime ?? 0;
  List<int> get safeHealthRecordTotalCounterRing =>
      healthRecordTotalCounterRing ?? [];
  List<int> get safeHealthRecordHealthyCounterRing =>
      healthRecordHealthyCounterRing ?? [];
}
