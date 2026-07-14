import 'dart:async';

import 'package:http/http.dart' as http;

/// GitHub 下载加速镜像选择与测速。
class GitHubProxySelector {
  GitHubProxySelector._();

  /// 设置值为 `auto` 时启用自动测速选路。
  static const autoMode = 'auto';

  /// 内置 GitHub 代理前缀（格式：`{prefix}{原始 GitHub URL}`）。
  static const builtInMirrors = <String>[
    'https://gh.xmly.dev/',
    'https://gh-proxy.org/',
    'https://ghfast.top/',
  ];

  /// 用于测速的小体积 GitHub 资源。
  static const _probeUrl = 'https://github.com/ldoubil/astral';

  static const _probeTimeout = Duration(seconds: 6);
  static const _cacheTtl = Duration(hours: 1);

  static String? _cachedPrefix;
  static DateTime? _cachedAt;
  static Future<String?>? _ongoingSelection;

  static bool isAutoMode(String value) => value.trim() == autoMode;

  static bool isAccelerationEnabled(String value) {
    final trimmed = value.trim();
    return trimmed.isNotEmpty;
  }

  static String normalizePrefix(String prefix) {
    final trimmed = prefix.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }

  static String buildProxiedUrl(String prefix, String rawUrl) {
    return '${normalizePrefix(prefix)}$rawUrl';
  }

  /// 解析实际使用的前缀：`auto` 时测速选最快，否则返回用户配置。
  static Future<String?> resolvePrefix(
    String setting, {
    bool forceRefresh = false,
  }) async {
    final trimmed = setting.trim();
    if (trimmed.isEmpty) return null;
    if (!isAutoMode(trimmed)) {
      return normalizePrefix(trimmed);
    }
    return selectFastest(forceRefresh: forceRefresh);
  }

  /// 从内置镜像中测速并返回最快可用前缀；全部失败时返回 `null`。
  static Future<String?> selectFastest({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cachedPrefix != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < _cacheTtl) {
      return _cachedPrefix;
    }

    if (!forceRefresh && _ongoingSelection != null) {
      return _ongoingSelection;
    }

    final selection = _runSelection();
    _ongoingSelection = selection;
    try {
      return await selection;
    } finally {
      _ongoingSelection = null;
    }
  }

  static Future<String?> _runSelection() async {
    final probes = await Future.wait(
      builtInMirrors.map(_probeMirror),
    );

    ProbeResult? best;
    for (final result in probes) {
      if (!result.success) continue;
      if (best == null || result.latency < best.latency) {
        best = result;
      }
    }

    if (best != null) {
      _cachedPrefix = best.prefix;
      _cachedAt = DateTime.now();
      return best.prefix;
    }

    return null;
  }

  static Future<ProbeResult> _probeMirror(String prefix) async {
    final normalized = normalizePrefix(prefix);
    final url = buildProxiedUrl(normalized, _probeUrl);
    final stopwatch = Stopwatch()..start();

    try {
      final request = http.Request('GET', Uri.parse(url))
        ..headers['User-Agent'] = 'astral'
        ..headers['Range'] = 'bytes=0-0';
      final streamed = await request.send().timeout(_probeTimeout);
      await streamed.stream.drain();
      stopwatch.stop();

      final success = streamed.statusCode >= 200 && streamed.statusCode < 400;
      return ProbeResult(
        prefix: normalized,
        latency: stopwatch.elapsed,
        success: success,
        statusCode: streamed.statusCode,
      );
    } on TimeoutException {
      stopwatch.stop();
      return ProbeResult(
        prefix: normalized,
        latency: stopwatch.elapsed,
        success: false,
      );
    } catch (_) {
      stopwatch.stop();
      return ProbeResult(
        prefix: normalized,
        latency: stopwatch.elapsed,
        success: false,
      );
    }
  }

  static void invalidateCache() {
    _cachedPrefix = null;
    _cachedAt = null;
  }
}

class ProbeResult {
  final String prefix;
  final Duration latency;
  final bool success;
  final int? statusCode;

  const ProbeResult({
    required this.prefix,
    required this.latency,
    required this.success,
    this.statusCode,
  });
}
