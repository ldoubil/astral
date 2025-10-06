import 'dart:convert';

/// 连接协议类型（单选）
enum ProtocolType {
  tcp,
  udp,
  ws,
  wss,
  quic,
  wg,
  txt,
  srv,
  http,
  https,
}

/// 服务器配置模型
/// 用于存储和管理服务器连接信息，兼容原有的ServerDb结构
class ServerModel {
  /// 服务器ID
  final int id;
  
  /// 服务器名称
  final String name;
  
  /// 服务器URL（完整地址）
  final String url;
  
  /// 是否启用
  final bool enable;
  
  /// 排序顺序
  final int sortOrder;
  
  /// 连接协议类型
  final ProtocolType protocol;
  
  /// 服务器描述（可选）
  final String? description;
  
  /// 是否为默认服务器
  final bool isDefault;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 最后修改时间
  final DateTime updatedAt;
  
  /// 服务器标签
  final List<String> tags;
  
  /// 额外配置信息
  final Map<String, dynamic> extra;

  const ServerModel({
    this.id = 0,
    required this.name,
    required this.url,
    this.enable = false,
    this.sortOrder = 0,
    this.protocol = ProtocolType.tcp,
    this.description,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.extra = const {},
  });

  /// 从JSON创建ServerModel实例
  factory ServerModel.fromJson(Map<String, dynamic> json) {
    return ServerModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String,
      url: json['url'] as String,
      enable: json['enable'] as bool? ?? false,
      sortOrder: json['sortOrder'] as int? ?? 0,
      protocol: ProtocolType.values.firstWhere(
        (e) => e.name == json['protocol'],
        orElse: () => ProtocolType.tcp,
      ),
      description: json['description'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      extra: (json['extra'] as Map<String, dynamic>?) ?? {},
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'enable': enable,
      'sortOrder': sortOrder,
      'protocol': protocol.name,
      'description': description,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'extra': extra,
    };
  }

  /// 从原有的ServerDb Map格式创建（兼容性方法）
  factory ServerModel.fromServerDbMap(Map<String, dynamic> map) {
    final now = DateTime.now();
    return ServerModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      url: map['url'] ?? '',
      enable: map['enable'] ?? false,
      sortOrder: map['sortOrder'] ?? 0,
      protocol: ProtocolType.values.firstWhere(
        (e) => e.name == map['protocol'],
        orElse: () => ProtocolType.tcp,
      ),
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 转换为原有的ServerDb Map格式（兼容性方法）
  Map<String, dynamic> toServerDbMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'enable': enable,
      'sortOrder': sortOrder,
      'protocol': protocol.name,
    };
  }

  /// 从JSON字符串创建ServerModel实例
  factory ServerModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return ServerModel.fromJson(json);
  }

  /// 转换为JSON字符串
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// 创建副本，允许修改部分字段
  ServerModel copyWith({
    int? id,
    String? name,
    String? url,
    bool? enable,
    int? sortOrder,
    ProtocolType? protocol,
    String? description,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    Map<String, dynamic>? extra,
  }) {
    return ServerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      enable: enable ?? this.enable,
      sortOrder: sortOrder ?? this.sortOrder,
      protocol: protocol ?? this.protocol,
      description: description ?? this.description,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      extra: extra ?? this.extra,
    );
  }

  /// 获取完整的服务器URL
  String get fullUrl => url;

  /// 获取显示名称（如果有描述则显示描述，否则显示名称）
  String get displayName {
    return description?.isNotEmpty == true ? description! : name;
  }

  /// 检查服务器配置是否有效
  bool get isValid {
    return name.isNotEmpty && url.isNotEmpty;
  }

  /// 获取服务器唯一标识符
  String get uniqueId {
    return id.toString();
  }

  /// 解析URL获取地址和端口信息
  Map<String, dynamic> get urlInfo {
    try {
      final uri = Uri.parse(url);
      return {
        'scheme': uri.scheme,
        'host': uri.host,
        'port': uri.port,
        'path': uri.path,
        'hasSSL': uri.scheme == 'https' || uri.scheme == 'wss',
      };
    } catch (e) {
      return {
        'scheme': '',
        'host': url,
        'port': 0,
        'path': '',
        'hasSSL': false,
      };
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ServerModel &&
        other.id == id &&
        other.name == name &&
        other.url == url &&
        other.enable == enable &&
        other.protocol == protocol;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, url, enable, protocol);
  }

  @override
  String toString() {
    return 'ServerModel(id: $id, name: $name, url: $url, enable: $enable, protocol: $protocol)';
  }

  /// 创建默认的服务器配置
  static ServerModel createDefault({
    int id = 0,
    String name = 'Default Server',
    String url = 'http://localhost:8080',
    bool enable = false,
    ProtocolType protocol = ProtocolType.tcp,
  }) {
    final now = DateTime.now();
    return ServerModel(
      id: id,
      name: name,
      url: url,
      enable: enable,
      protocol: protocol,
      isDefault: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 验证服务器URL格式
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// 验证端口号
  static bool isValidPort(int port) {
    return port > 0 && port <= 65535;
  }

  /// 从协议名称获取协议类型
  static ProtocolType protocolFromString(String protocolName) {
    return ProtocolType.values.firstWhere(
      (e) => e.name.toLowerCase() == protocolName.toLowerCase(),
      orElse: () => ProtocolType.tcp,
    );
  }

  /// 获取协议的默认端口
  static int getDefaultPort(ProtocolType protocol) {
    switch (protocol) {
      case ProtocolType.http:
        return 80;
      case ProtocolType.https:
        return 443;
      case ProtocolType.ws:
        return 80;
      case ProtocolType.wss:
        return 443;
      case ProtocolType.tcp:
      case ProtocolType.udp:
        return 8080;
      default:
        return 8080;
    }
  }
}