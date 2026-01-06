/// 服务器配置常量
class ServerConfig {
  final String name; // 服务器名称
  final String url; // 服务器地址
  final bool tcp; // TCP协议
  final bool udp; // UDP协议
  final bool ws; // WebSocket
  final bool wss; // WebSocket Secure
  final bool quic; // QUIC协议
  final bool wg; // WireGuard
  final bool txt; // TXT记录
  final bool srv; // SRV记录
  final bool http; // HTTP
  final bool https; // HTTPS

  const ServerConfig({
    required this.name,
    required this.url,
    this.tcp = true,
    this.udp = false,
    this.ws = false,
    this.wss = false,
    this.quic = false,
    this.wg = false,
    this.txt = false,
    this.srv = false,
    this.http = false,
    this.https = false,
  });
}

/// 服务器常量列表
class ServersConstants {
  static const List<ServerConfig> servers = [
    ServerConfig(name: "pd2", url: "pd2.629957.xyz:39647", tcp: true),
  ];

  /// 根据索引获取服务器配置
  static ServerConfig getServerByIndex(int index) {
    if (index < 0 || index >= servers.length) {
      return servers[0]; // 默认返回第一个
    }
    return servers[index];
  }

  /// 获取所有已启用的服务器索引列表
  static List<int> getEnabledServerIndices(List<int> enabledIndices) {
    return enabledIndices.where((i) => i >= 0 && i < servers.length).toList();
  }
}
