import 'dart:convert';
import 'dart:math';

import 'package:astral/core/platform/app_info.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:http/http.dart' as http;

enum UpdateCheckKind { updateAvailable, upToDate, failed }

class UpdateCheckResult {
  final UpdateCheckKind kind;
  final String version;
  final String releaseNotes;
  final String releasePage;
  final Map<String, dynamic>? releaseInfo;

  const UpdateCheckResult({
    required this.kind,
    required this.version,
    required this.releaseNotes,
    required this.releasePage,
    this.releaseInfo,
  });

  bool get isLatestVersion => kind == UpdateCheckKind.upToDate;
}

/// 应用更新检查（纯 IO / 逻辑，不含 UI）
class UpdateChecker {
  static const _requestTimeout = Duration(seconds: 15);

  final String owner;
  final String repo;
  final String branch;

  UpdateChecker({
    required this.owner,
    required this.repo,
    this.branch = 'main',
  });

  Future<UpdateCheckResult?> check({
    bool showNoUpdateMessage = true,
    bool forceShowDownload = false,
    bool showFailureMessage = true,
  }) async {
    try {
      final releaseInfo = await _fetchLatestRelease(
        includePrereleases: ServiceManager().updateState.beta.value,
      );
      if (releaseInfo == null) {
        if (!showFailureMessage) return null;
        return UpdateCheckResult(
          kind: UpdateCheckKind.failed,
          version: '检查更新失败',
          releaseNotes: '无法获取最新版本信息',
          releasePage: _releasesPage,
        );
      }

      final currentVersion = await _getCurrentVersion();
      final latestVersion = _extractString(releaseInfo, 'tag_name');
      if (latestVersion.isEmpty) {
        if (!showFailureMessage) return null;
        return UpdateCheckResult(
          kind: UpdateCheckKind.failed,
          version: '检查更新失败',
          releaseNotes: '无法解析版本号',
          releasePage: _releasesPage,
        );
      }

      await ServiceManager().appSettings.updateLatestVersion(latestVersion);

      final releaseNotes = _extractString(
        releaseInfo,
        'body',
        fallback: '新版本已发布',
      );
      final releasePage = _extractString(
        releaseInfo,
        'html_url',
        fallback: _releasesPage,
      );

      if (_shouldUpdate(currentVersion, latestVersion) || forceShowDownload) {
        return UpdateCheckResult(
          kind: UpdateCheckKind.updateAvailable,
          version: latestVersion,
          releaseNotes: releaseNotes,
          releasePage: releasePage,
          releaseInfo: releaseInfo,
        );
      }

      if (!showNoUpdateMessage) return null;
      return UpdateCheckResult(
        kind: UpdateCheckKind.upToDate,
        version: '当前已是最新版本',
        releaseNotes: '当前版本为: $currentVersion',
        releasePage: _releasesPage,
      );
    } catch (e) {
      if (!showFailureMessage) return null;
      return UpdateCheckResult(
        kind: UpdateCheckKind.failed,
        version: '更新检查失败',
        releaseNotes: '检查更新时发生错误: $e',
        releasePage: _releasesPage,
      );
    }
  }

  String get _releasesPage => 'https://github.com/$owner/$repo/releases';

  Future<Map<String, dynamic>?> _fetchLatestRelease({
    bool includePrereleases = false,
  }) async {
    try {
      final apiUrl =
          'https://api.github.com/repos/$owner/$repo/releases?per_page=20';

      final response = await http
          .get(
            Uri.parse(apiUrl),
            headers: {
              'Accept': 'application/vnd.github.v3+json',
              'User-Agent': 'astral',
            },
          )
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        return null;
      }

      final decoded = json.decode(response.body);
      if (decoded is! List) {
        return null;
      }

      for (final item in decoded) {
        if (item is! Map) {
          continue;
        }
        final release = Map<String, dynamic>.from(item);
        final isDraft = release['draft'] == true;
        final isPrerelease = release['prerelease'] == true;
        if (isDraft) continue;
        if (!includePrereleases && isPrerelease) continue;
        return release;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String> _getCurrentVersion() async {
    try {
      return AppInfoUtil.getVersion();
    } catch (_) {
      return '0.0.0';
    }
  }

  bool _shouldUpdate(String currentVersion, String latestVersion) {
    final current = currentVersion.replaceAll(RegExp(r'^v'), '');
    final latest = latestVersion.replaceAll(RegExp(r'^v'), '');

    final currentParts = current.split('-');
    final latestParts = latest.split('-');

    final currentMain = _parseVersionParts(currentParts[0]);
    final latestMain = _parseVersionParts(latestParts[0]);

    for (int i = 0; i < 3; i++) {
      final curr = i < currentMain.length ? currentMain[i] : 0;
      final lat = i < latestMain.length ? latestMain[i] : 0;

      if (lat > curr) return true;
      if (lat < curr) return false;
    }

    if (currentParts.length == 1) return latestParts.length > 1;
    if (latestParts.length == 1) return true;

    return _comparePreRelease(currentParts[1], latestParts[1]) < 0;
  }

  List<int> _parseVersionParts(String version) {
    return version.split('.').map((s) => int.tryParse(s) ?? 0).toList();
  }

  int _comparePreRelease(String a, String b) {
    final aParts = a.split('.');
    final bParts = b.split('.');

    for (int i = 0; i < max(aParts.length, bParts.length); i++) {
      final aVal = i < aParts.length ? aParts[i] : '';
      final bVal = i < bParts.length ? bParts[i] : '';

      final aNum = int.tryParse(aVal);
      final bNum = int.tryParse(bVal);

      if (aNum != null && bNum != null) {
        if (aNum != bNum) return aNum.compareTo(bNum);
      } else {
        final cmp = aVal.compareTo(bVal);
        if (cmp != 0) return cmp;
      }
    }
    return 0;
  }

  String _extractString(
    Map<String, dynamic> source,
    String key, {
    String fallback = '',
  }) {
    final value = source[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return fallback;
  }
}
