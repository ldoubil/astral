import 'package:isar_community/isar.dart';
part 'all_settings.g.dart';

@collection
class AllSettings {
  /// 主键ID，固定为1因为只需要一个实例
  Id id = 1;

  /// 当前启用的房间
  int? room;

  /// 玩家名称
  String? playerName;

  /// 监听列表
  List<String>? listenList = ["tcp://0.0.0.0:0", "udp://0.0.0.0:0"];

  /// 自定义vpn网段
  List<String> customVpn = [];

  ///用户列表简约模式
  bool userListSimple = true;

  /// 关闭最小化到托盘
  bool closeMinimize = true;

  /// 开机自启
  bool startup = false;

  /// 启动后最小化
  bool startupMinimize = false;

  /// 启动后自动连接
  bool startupAutoConnect = false;

  /// 自动设置网卡跃点
  bool autoSetMTU = true;

  /// 参与测试版
  bool beta = false;

  /// 自动检查更新
  bool autoCheckUpdate = true;

  /// 下载加速
  String downloadAccelerate = 'https://gh.xmly.dev/';

  /// 服务器排序字段
  String serverSortField = 'id';

  /// 排序选项 (0: 默认, 1: 延迟, 2: 用户名)
  int sortOption = 0;

  /// 排序方式 (0: 升序, 1: 降序)
  int sortOrder = 0;

  /// 显示模式 (0: 默认, 1: 用户, 2: 服务器)
  int displayMode = 0;

  /// 用户ID
  String? userId;

  /// 最新版本号
  String? latestVersion;

  /// 启用轮播图
  bool enableBannerCarousel = true;

  /// 是否已显示轮播图首次提示
  bool hasShownBannerTip = false;
}
