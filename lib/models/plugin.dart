import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'plugin.g.dart';

/// 插件状态枚举
@HiveType(typeId: 17)
enum PluginStatus {
  @HiveField(0)
  @JsonValue('enabled')
  enabled,
  @HiveField(1)
  @JsonValue('disabled')
  disabled,
  @HiveField(2)
  @JsonValue('error')
  error,
}

/// 插件数据模型
@JsonSerializable()
@HiveType(typeId: 3)
class Plugin extends HiveObject {
  /// 插件唯一标识符
  @HiveField(0)
  @JsonKey(name: 'id')
  String id;

  /// 插件名称
  @HiveField(1)
  @JsonKey(name: 'name')
  String name;

  /// 插件版本
  @HiveField(2)
  @JsonKey(name: 'version')
  String version;

  /// 插件描述
  @HiveField(3)
  @JsonKey(name: 'description')
  String description;

  /// 插件作者
  @HiveField(4)
  @JsonKey(name: 'author')
  String author;

  /// 插件主页URL
  @HiveField(5)
  @JsonKey(name: 'homepage')
  String? homepage;

  /// 插件状态
  @HiveField(6)
  @JsonKey(name: 'status')
  PluginStatus status;

  /// 插件入口文件路径
  @HiveField(7)
  @JsonKey(name: 'entry_point')
  String entryPoint;

  /// 插件安装路径
  @HiveField(8)
  @JsonKey(name: 'install_path')
  String installPath;

  /// 插件配置
  @HiveField(9)
  @JsonKey(name: 'config')
  Map<String, dynamic>? config;

  /// 插件依赖
  @HiveField(10)
  @JsonKey(name: 'dependencies')
  List<String>? dependencies;

  /// 插件权限
  @HiveField(11)
  @JsonKey(name: 'permissions')
  List<String>? permissions;

  /// 安装时间
  @HiveField(12)
  @JsonKey(name: 'install_time')
  DateTime installTime;

  /// 最后更新时间
  @HiveField(13)
  @JsonKey(name: 'last_update')
  DateTime lastUpdate;

  /// 构造函数
  Plugin({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.author,
    this.homepage,
    this.status = PluginStatus.disabled,
    required this.entryPoint,
    required this.installPath,
    this.config,
    this.dependencies,
    this.permissions,
    required this.installTime,
    required this.lastUpdate,
  });

  /// 从JSON创建插件实例
  factory Plugin.fromJson(Map<String, dynamic> json) => _$PluginFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$PluginToJson(this);

  /// 检查插件是否已启用
  bool get isEnabled => status == PluginStatus.enabled;

  /// 检查插件是否有错误
  bool get hasError => status == PluginStatus.error;

  /// 启用插件
  void enable() {
    status = PluginStatus.enabled;
    lastUpdate = DateTime.now();
  }

  /// 禁用插件
  void disable() {
    status = PluginStatus.disabled;
    lastUpdate = DateTime.now();
  }

  /// 设置错误状态
  void setError() {
    status = PluginStatus.error;
    lastUpdate = DateTime.now();
  }

  /// 更新插件配置
  void updateConfig(Map<String, dynamic> newConfig) {
    config = newConfig;
    lastUpdate = DateTime.now();
  }

  @override
  String toString() {
    return 'Plugin{id: $id, name: $name, version: $version, status: $status}';
  }
}

/// 插件清单文件模型
@JsonSerializable()
class PluginManifest {
  /// 插件基本信息
  @JsonKey(name: 'id')
  String id;

  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'version')
  String version;

  @JsonKey(name: 'description')
  String description;

  @JsonKey(name: 'author')
  String author;

  @JsonKey(name: 'homepage')
  String? homepage;

  /// 插件入口文件
  @JsonKey(name: 'entry_point')
  String entryPoint;

  /// 最小应用版本要求
  @JsonKey(name: 'min_app_version')
  String? minAppVersion;

  /// 插件依赖
  @JsonKey(name: 'dependencies')
  List<String>? dependencies;

  /// 插件权限
  @JsonKey(name: 'permissions')
  List<String>? permissions;

  /// 插件API版本
  @JsonKey(name: 'api_version')
  String? apiVersion;

  /// 构造函数
  PluginManifest({
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.author,
    this.homepage,
    required this.entryPoint,
    this.minAppVersion,
    this.dependencies,
    this.permissions,
    this.apiVersion,
  });

  /// 从JSON创建清单实例
  factory PluginManifest.fromJson(Map<String, dynamic> json) => _$PluginManifestFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$PluginManifestToJson(this);

  /// 转换为插件实例
  Plugin toPlugin(String installPath) {
    return Plugin(
      id: id,
      name: name,
      version: version,
      description: description,
      author: author,
      homepage: homepage,
      entryPoint: entryPoint,
      installPath: installPath,
      dependencies: dependencies,
      permissions: permissions,
      installTime: DateTime.now(),
      lastUpdate: DateTime.now(),
    );
  }
}