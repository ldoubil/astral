import 'package:json_annotation/json_annotation.dart';

part 'server_json_node.g.dart';

/// 服务器节点数据模型
@JsonSerializable()
class ServerJsonNode {
  /// 节点唯一标识
  final int id;
  /// 节点名称
  final String name;
  /// 主机地址
  final String host;
  /// 端口号
  final int port;
  /// 协议类型
  final String protocol;
  /// 版本号
  final String version;
  /// 节点描述
  final String description;
  /// 最大连接数
  @JsonKey(name: 'max_connections')
  final int maxConnections;
  /// 当前连接数
  @JsonKey(name: 'current_connections')
  final int currentConnections;
  /// 是否激活
  @JsonKey(name: 'is_active')
  final bool isActive;
  /// 是否已批准
  @JsonKey(name: 'is_approved')
  final bool isApproved;
  /// 是否允许中继
  @JsonKey(name: 'allow_relay')
  final bool allowRelay;
  /// 网络名称（可选）
  @JsonKey(name: 'network_name')
  final String? networkName;
  /// 网络密钥（可选）
  @JsonKey(name: 'network_secret')
  final String? networkSecret;
  /// 创建时间
  @JsonKey(name: 'created_at')
  final String createdAt;
  /// 更新时间
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  /// 地址
  final String address;
  /// 使用率百分比（可选）
  @JsonKey(name: 'usage_percentage')
  final double? usagePercentage;
  /// 当前健康状态（可选）
  @JsonKey(name: 'current_health_status')
  final String? currentHealthStatus;
  /// 最后检查时间（可选）
  @JsonKey(name: 'last_check_time')
  final String? lastCheckTime;
  /// 最后响应时间（可选，毫秒）
  @JsonKey(name: 'last_response_time')
  final int? lastResponseTime;
  /// 24小时健康百分比（可选）
  @JsonKey(name: 'health_percentage_24h')
  final double? healthPercentage24h;
  /// 健康记录总计数环（可选）
  @JsonKey(name: 'health_record_total_counter_ring')
  final List<int>? healthRecordTotalCounterRing;
  /// 健康记录健康计数环（可选）
  @JsonKey(name: 'health_record_healthy_counter_ring')
  final List<int>? healthRecordHealthyCounterRing;
  /// 环粒度（可选）
  @JsonKey(name: 'ring_granularity')
  final int? ringGranularity;
  /// QQ号码（可选）
  @JsonKey(name: 'qq_number')
  final String? qqNumber;
  /// 微信号（可选）
  final String? wechat;
  /// 邮箱（可选）
  final String? mail;

  ServerJsonNode({
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

  /// 从JSON创建ServerJsonNode实例
  factory ServerJsonNode.fromJson(Map<String, dynamic> json) =>
      _$ServerJsonNodeFromJson(json);
  /// 将ServerJsonNode实例转为JSON
  Map<String, dynamic> toJson() => _$ServerJsonNodeToJson(this);

  // 便利方法
  /// 是否健康（健康状态为'healthy'）
  bool get isHealthy => currentHealthStatus == 'healthy';
  /// 是否在线（激活且已批准）
  bool get isOnline => isActive && isApproved;
  /// 状态文本：在线/离线
  String get statusText => isHealthy ? '在线' : '离线';
  /// 负载百分比文本，如"75%"
  String get loadPercentageText => '${(usagePercentage ?? 0).toInt()}%';
  /// 安全的24小时健康百分比（默认为0.0）
  double get safeHealthPercentage24h => healthPercentage24h ?? 0.0;
  /// 安全的最后响应时间（默认为0）
  int get safeLastResponseTime => lastResponseTime ?? 0;
  /// 安全的健康记录总计数环（默认为空列表）
  List<int> get safeHealthRecordTotalCounterRing =>
      healthRecordTotalCounterRing ?? [];
  /// 安全的健康记录健康计数环（默认为空列表）
  List<int> get safeHealthRecordHealthyCounterRing =>
      healthRecordHealthyCounterRing ?? [];
}
