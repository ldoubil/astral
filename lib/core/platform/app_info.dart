import 'package:package_info_plus/package_info_plus.dart';

/// 应用包信息工具
class AppInfoUtil {
  static PackageInfo? _packageInfo;

  /// 初始化应用信息
  static Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  /// 获取应用版本号 (例如: 1.0.0)
  static String getVersion() {
    return _packageInfo?.version ?? '';
  }
}
