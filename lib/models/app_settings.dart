import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'app_settings.g.dart';

/// 应用基础设置的 Hive 模型
/// 注意：为了与 Hive 的序列化兼容，颜色和枚举需转换为可持久化的原始类型（int）
/// 应用基础设置的 Hive 模型（typeId 需唯一且建议在 0–223 范围）
@HiveType(typeId: 10)
class AppSettings {
  @HiveField(0)
  Color themeColor = Colors.deepOrangeAccent; // 主题颜色
  // themeMode 主题模式
  @HiveField(1)
  ThemeMode themeMode = ThemeMode.system;
  // currentLanguage
  @HiveField(2)
  String currentLanguage = 'zh';

  /// 当前启用的房间
  @HiveField(3)
  int? room;

  /// 玩家名称
  @HiveField(4)
  String? playerName;

  /// 监听列表
  @HiveField(5)
  List<String>? listenList = ["tcp://0.0.0.0:11010", "udp://0.0.0.0:11010"];

  /// 自定义vpn网段
  @HiveField(6)
  List<String> customVpn = [];

  /// 用户列表简约模式
  @HiveField(7)
  bool userListSimple = true;

  /// 关闭最小化到托盘
  @HiveField(8)
  bool closeMinimize = true;

  /// 开机自启
  @HiveField(9)
  bool startup = false;

  /// 启动后最小化
  @HiveField(10)
  bool startupMinimize = false;

  /// 启动后自动连接
  @HiveField(11)
  bool startupAutoConnect = false;

  /// 自动设置网卡跃点
  @HiveField(12)
  bool autoSetMTU = true;

  /// 参与测试版
  @HiveField(13)
  bool beta = false;

  /// 自动检查更新
  @HiveField(14)
  bool autoCheckUpdate = true;

  /// 下载加速
  @HiveField(15)
  String downloadAccelerate = 'https://gh.xmly.dev/';

  /// 服务器排序字段
  @HiveField(16)
  String serverSortField = 'id';

  /// 排序选项 (0: 默认, 1: 延迟, 2: 用户名)
  @HiveField(17)
  int sortOption = 0;

  /// 排序方式 (0: 升序, 1: 降序)
  @HiveField(18)
  int sortOrder = 0;

  /// 显示模式 (0: 默认, 1: 用户, 2: 服务器)
  @HiveField(19)
  int displayMode = 0;

  /// 用户ID
  @HiveField(20)
  String? userId;

  /// 最新版本号
  @HiveField(21)
  String? latestVersion;

  AppSettings({
    required this.themeColor,
    required this.themeMode,
    required this.currentLanguage,
  });

  /// 复制并更新设置：仅替换提供的参数，其余保持原值
  AppSettings copyWith({
    Color? themeColor,
    ThemeMode? themeMode,
    String? currentLanguage,
    int? room,
    String? playerName,
    List<String>? listenList,
    List<String>? customVpn,
    bool? userListSimple,
    bool? closeMinimize,
    bool? startup,
    bool? startupMinimize,
    bool? startupAutoConnect,
    bool? autoSetMTU,
    bool? beta,
    bool? autoCheckUpdate,
    String? downloadAccelerate,
    String? serverSortField,
    int? sortOption,
    int? sortOrder,
    int? displayMode,
    String? userId,
    String? latestVersion,
  }) {
    return AppSettings(
      themeColor: themeColor ?? this.themeColor,
      themeMode: themeMode ?? this.themeMode,
      currentLanguage: currentLanguage ?? this.currentLanguage,
    )
      ..room = room ?? this.room
      ..playerName = playerName ?? this.playerName
      ..listenList = listenList ?? this.listenList
      ..customVpn = customVpn ?? this.customVpn
      ..userListSimple = userListSimple ?? this.userListSimple
      ..closeMinimize = closeMinimize ?? this.closeMinimize
      ..startup = startup ?? this.startup
      ..startupMinimize = startupMinimize ?? this.startupMinimize
      ..startupAutoConnect = startupAutoConnect ?? this.startupAutoConnect
      ..autoSetMTU = autoSetMTU ?? this.autoSetMTU
      ..beta = beta ?? this.beta
      ..autoCheckUpdate = autoCheckUpdate ?? this.autoCheckUpdate
      ..downloadAccelerate = downloadAccelerate ?? this.downloadAccelerate
      ..serverSortField = serverSortField ?? this.serverSortField
      ..sortOption = sortOption ?? this.sortOption
      ..sortOrder = sortOrder ?? this.sortOrder
      ..displayMode = displayMode ?? this.displayMode
      ..userId = userId ?? this.userId
      ..latestVersion = latestVersion ?? this.latestVersion;
  }
}
