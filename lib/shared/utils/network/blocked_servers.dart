class BlockedServers {
  static const List<String> blockedUrls = [
    'js.629957.xyz:11012',
    'nmg.629957.xyz:11010',
    'nmg.629957.xyz:11010',
  ];

  static bool isBlocked(String url) {
    return blockedUrls.contains(url);
  }
}
