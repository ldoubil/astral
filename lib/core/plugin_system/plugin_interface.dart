import 'dart:async';

/// 插件基础接口
/// 所有插件都必须实现此接口
abstract class PluginInterface {
  /// 插件唯一标识符
  String get id;
  
  /// 插件名称
  String get name;
  
  /// 插件版本
  String get version;
  
  /// 插件作者
  String get author;
  
  /// 插件描述
  String get description;
  
  /// 插件是否已启用
  bool get isEnabled;
  
  /// 插件初始化
  /// 返回true表示初始化成功，false表示失败
  Future<bool> initialize();
  
  /// 插件启动
  /// 在插件被启用时调用
  Future<void> start();
  
  /// 插件停止
  /// 在插件被禁用时调用
  Future<void> stop();
  
  /// 插件销毁
  /// 在插件被卸载时调用，用于清理资源
  Future<void> dispose();
  
  /// 获取插件配置
  Map<String, dynamic> getConfig();
  
  /// 设置插件配置
  void setConfig(Map<String, dynamic> config);
  
  /// 插件状态变更通知
  Stream<PluginStatus> get statusStream;
}

/// 插件状态枚举
enum PluginStatus {
  /// 未初始化
  uninitialized,
  /// 初始化中
  initializing,
  /// 已初始化但未启动
  initialized,
  /// 启动中
  starting,
  /// 运行中
  running,
  /// 停止中
  stopping,
  /// 已停止
  stopped,
  /// 错误状态
  error,
  /// 已销毁
  disposed,
}

/// 插件元数据
class PluginMetadata {
  final String id;
  final String name;
  final String version;
  final String author;
  final String description;
  final String entryPoint;
  final List<String> permissions;
  final List<String> dependencies;
  final String? homepage;
  final Map<String, dynamic>? config;

  const PluginMetadata({
    required this.id,
    required this.name,
    required this.version,
    required this.author,
    required this.description,
    required this.entryPoint,
    this.permissions = const [],
    this.dependencies = const [],
    this.homepage,
    this.config,
  });

  /// 从JSON创建插件元数据
  factory PluginMetadata.fromJson(Map<String, dynamic> json) {
    // 处理entry_point字段的多种可能名称
    String? entryPoint = json['entry_point'] as String?;
    entryPoint ??= json['entryPoint'] as String?;
    entryPoint ??= json['main'] as String?;
    entryPoint ??= 'main.js'; // 默认值
    
    return PluginMetadata(
      id: json['id'] as String? ?? json['name'] as String? ?? 'unknown',
      name: json['name'] as String? ?? 'Unknown Plugin',
      version: json['version'] as String? ?? '1.0.0',
      author: json['author'] as String? ?? 'Unknown Author',
      description: json['description'] as String? ?? 'No description',
      entryPoint: entryPoint,
      permissions: List<String>.from(json['permissions'] ?? []),
      dependencies: List<String>.from(json['dependencies'] ?? []),
      homepage: json['homepage'] as String?,
      config: json['config'] as Map<String, dynamic>?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'author': author,
      'description': description,
      'entry_point': entryPoint,
      'permissions': permissions,
      'dependencies': dependencies,
      if (homepage != null) 'homepage': homepage,
      if (config != null) 'config': config,
    };
  }
}