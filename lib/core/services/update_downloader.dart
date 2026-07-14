import 'dart:io';

import 'package:astral/core/services/service_manager.dart';
import 'package:astral/shared/utils/github_proxy_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// 更新包下载与 URL 解析（纯 IO，不含 UI）
class UpdateDownloader {
  static const requestTimeout = Duration(seconds: 15);

  Future<String> resolveAcceleratedUrl(String rawUrl) async {
    final setting = ServiceManager().updateState.downloadAccelerate.value;
    if (!GitHubProxySelector.isAccelerationEnabled(setting)) {
      return rawUrl;
    }

    final prefix = await GitHubProxySelector.resolvePrefix(setting);
    if (prefix == null || prefix.isEmpty) {
      return rawUrl;
    }

    if (GitHubProxySelector.isAutoMode(setting)) {
      ServiceManager().updateState.setResolvedDownloadAccelerate(prefix);
    }

    return GitHubProxySelector.buildProxiedUrl(prefix, rawUrl);
  }

  String getPlatformFileName() {
    if (Platform.isAndroid) {
      return 'astral-arm64-v8a.apk';
    } else if (Platform.isWindows) {
      return 'astral-windows-x64-setup.exe';
    } else {
      return '';
    }
  }

  String? getDownloadUrl(Map<String, dynamic> releaseInfo) {
    final fileName = getPlatformFileName();
    if (fileName.isEmpty) return null;
    return getDownloadUrlForFile(releaseInfo, fileName);
  }

  String? getDownloadUrlForFile(
    Map<String, dynamic> releaseInfo,
    String fileName,
  ) {
    final assets = releaseInfo['assets'] as List<dynamic>?;
    if (assets == null) return null;

    for (final asset in assets) {
      if (asset['name'] == fileName) {
        return asset['browser_download_url'] as String?;
      }
    }
    return null;
  }

  Future<String?> downloadFile(
    String url,
    String fileName,
    void Function(double) onProgress,
    bool Function() isCancelled,
  ) async {
    IOSink? sink;
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await request.send().timeout(requestTimeout);

      if (response.statusCode != 200) {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }

      final contentLength = response.contentLength;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');

      if (await file.exists()) {
        await file.delete();
      }

      sink = file.openWrite();
      var downloadedBytes = 0;

      await for (final chunk in response.stream) {
        if (isCancelled()) {
          throw Exception('下载已取消');
        }

        sink.add(chunk);
        downloadedBytes += chunk.length;

        if (contentLength != null && contentLength > 0) {
          onProgress(downloadedBytes / contentLength);
        }
      }

      await sink.flush();
      await sink.close();
      sink = null;

      onProgress(1.0);
      return file.path;
    } catch (e) {
      if (sink != null) {
        try {
          await sink.close();
        } catch (_) {}
      }

      try {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}

      debugPrint('下载失败: $e');
      return null;
    }
  }
}
