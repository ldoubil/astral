
class ServerMod {
  int id = 1;
  /// 主键自增
  String name = ""; // 服务器名
  String url = ""; // 服务器地址
  // 是否启用
  bool enable = true;
  // tcp 开启
  bool tcp = true;
  // udp 开启
  bool udp = false;
  // ws 开启
  bool ws = false;
  // wss 开启
  bool wss = false;
  // quic 开启
  bool quic = false;
  // wg 开启
  bool wg = false;
  // txt 开启
  bool txt = false;
  // srv 开启
  bool srv = false;
  // http 开启
  bool http = false;
  // https 开启
  bool https = false;
  /// 排序顺序
  int sortOrder = 0;

  //构造
  ServerMod({
    this.enable = false,
    required this.name,
    required this.url,
    this.tcp = false,
    this.udp = false,
    this.ws = false,
    this.wss = false,
    this.quic = false,
    this.wg = false,
    this.txt = false,
    this.srv = false,
    this.http = false,
    this.https = false,
    this.sortOrder = 0,  // 添加排序字段初始化
  });
}
