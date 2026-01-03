import 'dart:math' as math;

/// 版本工具类
class VersionUtil {
  /// 获取版本显示文本
  /// 如果当前版本与最新版本不同且最新版本更高，显示 "当前版本 -> 最新版本"
  /// 否则只显示当前版本
  static String getVersionDisplayText(
    String currentVersion,
    String? latestVersion,
  ) {
    if (hasNewVersion(currentVersion, latestVersion)) {
      final current = currentVersion.replaceAll(RegExp(r'^v'), '');
      final latest = latestVersion!.replaceAll(RegExp(r'^v'), '');
      return '$current -> $latest';
    }

    return currentVersion.replaceAll(RegExp(r'^v'), '');
  }

  /// 判断是否有新版本
  /// 返回 true 表示 latestVersion 比 currentVersion 更新
  static bool hasNewVersion(String currentVersion, String? latestVersion) {
    if (latestVersion == null || latestVersion.isEmpty) return false;

    return _compareVersions(currentVersion, latestVersion) < 0;
  }

  /// 比较版本号，返回 -1（当前版本较低）、0（相同）、1（当前版本较高）
  static int _compareVersions(String version1, String version2) {
    // 移除可能的 'v' 前缀
    version1 = version1.replaceFirst(RegExp(r'^v'), '');
    version2 = version2.replaceFirst(RegExp(r'^v'), '');

    // 分割版本号
    List<String> v1Parts = version1.split('.');
    List<String> v2Parts = version2.split('.');

    // 确保两个版本号长度相同，不足的部分用 0 补齐
    int maxLength = math.max(v1Parts.length, v2Parts.length);
    while (v1Parts.length < maxLength) v1Parts.add('0');
    while (v2Parts.length < maxLength) v2Parts.add('0');

    // 逐个比较版本号的每个部分
    for (int i = 0; i < maxLength; i++) {
      int num1 = int.tryParse(v1Parts[i]) ?? 0;
      int num2 = int.tryParse(v2Parts[i]) ?? 0;

      if (num1 < num2) return -1;
      if (num1 > num2) return 1;
    }

    return 0; // 版本号相同
  }
}
