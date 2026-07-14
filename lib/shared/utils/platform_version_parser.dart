import 'package:flutter/material.dart';

/// 平台版本解析工具类
class PlatformVersionParser {
  /// 根据内核版本字符串解析平台信息
  /// 返回: (平台名称, 图标)
  static (String, IconData) parsePlatformInfo(String versionString) {
    // 版本格式: "版本号|平台名" 或 "版本号"
    final parts = versionString.split('|');

    if (parts.length < 2) {
      // 没有平台信息，返回默认
      return ('', Icons.memory);
    }

    final platform = parts[1].trim().toLowerCase();

    // 根据平台返回对应的图标
    if (platform.contains('windows')) {
      return ('Windows', Icons.window);
    } else if (platform.contains('linux')) {
      return ('Linux', Icons.terminal);
    } else if (platform.contains('android')) {
      return ('Android', Icons.android);
    } else if (platform.contains('macos') || platform.contains('mac')) {
      return ('macOS', Icons.apple);
    } else if (platform.contains('ios')) {
      return ('iOS', Icons.phone_iphone);
    } else {
      return (parts[1].trim(), Icons.devices);
    }
  }

  /// 获取版本号（不含平台信息）
  static String getVersionNumber(String versionString) {
    return versionString.split('|')[0].trim();
  }

  /// 获取平台图标
  static IconData getPlatformIcon(String versionString) {
    return parsePlatformInfo(versionString).$2;
  }

  /// 获取平台名称
  static String getPlatformName(String versionString) {
    return parsePlatformInfo(versionString).$1;
  }
}
