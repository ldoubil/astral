import 'package:app_links/app_links.dart';

class AppLinkDefinitions {
  static final AppLinkDefinitions _instance = AppLinkDefinitions._internal();
  factory AppLinkDefinitions() => _instance;
  AppLinkDefinitions._internal();

  late AppLinks _appLinks;
  bool _isInitialized = false;

  /// 初始化 App Links
  void initialize() {
    if (_isInitialized) return;

    _appLinks = AppLinks();
    _isInitialized = true;
  }

  /// 获取初始链接
  Future<Uri?> getInitialLink() async {
    if (!_isInitialized) {
      throw StateError('AppLinkDefinitions 未初始化，请先调用 initialize()');
    }

    try {
      return await _appLinks.getInitialLink();
    } catch (_) {
      return null;
    }
  }

  /// 获取链接流
  Stream<Uri> get linkStream {
    if (!_isInitialized) {
      throw StateError('AppLinkDefinitions 未初始化，请先调用 initialize()');
    }

    return _appLinks.uriLinkStream;
  }

  /// 验证是否是有效的 Astral 链接
  bool isValidAstralLink(Uri uri) {
    return uri.scheme == 'astral' && uri.host.isNotEmpty;
  }
}
