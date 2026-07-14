import 'package:astral/core/app_links/definitions/app_link_definitions.dart';
import 'package:astral/core/app_links/handlers/link_handlers.dart';

typedef SimpleHandler = Future<void> Function(Uri uri);

class AppLinkRegistry {
  static final AppLinkRegistry _instance = AppLinkRegistry._internal();
  factory AppLinkRegistry() => _instance;
  AppLinkRegistry._internal();

  final AppLinkDefinitions _linkDefinitions = AppLinkDefinitions();
  final Map<String, SimpleHandler> _handlers = {};

  bool _isInitialized = false;

  void _registerHandler(String host, SimpleHandler handler) {
    _handlers[host] = handler;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    _linkDefinitions.initialize();
    _registerDefaultHandlers();
    await _handleInitialLink();
    _registerLinkStream();

    _isInitialized = true;
  }

  void _registerDefaultHandlers() {
    _registerHandler('debug', LinkHandlers.handleDebug);
    _registerHandler('room', LinkHandlers.handleRoom);
  }

  Future<void> _handleInitialLink() async {
    final initialLink = await _linkDefinitions.getInitialLink();
    if (initialLink != null) {
      await _processLink(initialLink);
    }
  }

  void _registerLinkStream() {
    _linkDefinitions.linkStream.listen(
      (uri) async => await _processLink(uri),
    );
  }

  Future<void> _processLink(Uri uri) async {
    if (!_linkDefinitions.isValidAstralLink(uri)) return;

    final handler = _handlers[uri.host];
    if (handler == null) return;

    await handler(uri);
  }
}
