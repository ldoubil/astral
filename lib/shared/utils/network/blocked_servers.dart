/// 服务器屏蔽列表
/// 在此列表中的服务器URL将隐藏用户IP地址
class BlockedServers {
  static const List<String> blockedUrls = [
    'turn.js.629957.xyz:11012',
    'turn.bj.629957.xyz:11010',
    'turn.nmg.629957.xyz:11010',
  ];

  /// 检查服务器URL是否在屏蔽列表中
  static bool isBlocked(String url) {
    return blockedUrls.contains(url);
  }

  /// 检查服务器列表中是否有任何启用的服务器在屏蔽列表中
  static bool hasBlockedEnabledServer(List<dynamic> servers) {
    return servers.any(
      (server) => server.enable == true && isBlocked(server.url),
    );
  }
}
