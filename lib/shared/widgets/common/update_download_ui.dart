import 'dart:io';

import 'package:astral/core/services/update_downloader.dart';
import 'package:astral/core/ui/app_snack_bars.dart';
import 'package:astral/shared/widgets/common/update_dialogs.dart';
import 'package:flutter/material.dart';

/// 更新下载 UI 编排（对话框 / SnackBar）
class UpdateDownloadUi {
  const UpdateDownloadUi._();

  static Future<void> handleDownload(
    BuildContext context,
    Map<String, dynamic> releaseInfo,
    UpdateDownloader downloader,
  ) async {
    if (!context.mounted) return;

    if (Platform.isAndroid) {
      showArchitectureSelectionDialog(
        context: context,
        onSelected: (fileName) {
          startDownload(context, releaseInfo, fileName, downloader);
        },
      );
      return;
    }

    final downloadUrl = downloader.getDownloadUrl(releaseInfo);
    if (downloadUrl == null) {
      AppSnackBars.error(context, '下载失败', '未找到当前平台的安装包');
      return;
    }

    final acceleratedUrl = await downloader.resolveAcceleratedUrl(downloadUrl);
    if (!context.mounted) return;

    final fileName = downloader.getPlatformFileName();
    if (fileName.isEmpty) {
      AppSnackBars.error(context, '下载失败', '当前平台暂不支持内置下载安装');
      return;
    }

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => DownloadProgressDialog(
            onDownload:
                (onProgress, isCancelled) => downloader.downloadFile(
                  acceleratedUrl,
                  fileName,
                  onProgress,
                  isCancelled,
                ),
            fileName: fileName,
          ),
    );
  }

  static Future<void> startDownload(
    BuildContext context,
    Map<String, dynamic> releaseInfo,
    String fileName,
    UpdateDownloader downloader,
  ) async {
    if (!context.mounted) return;

    final downloadUrl = downloader.getDownloadUrlForFile(releaseInfo, fileName);
    if (downloadUrl == null) {
      AppSnackBars.error(context, '下载失败', '未找到 $fileName 的下载链接');
      return;
    }

    final acceleratedUrl = await downloader.resolveAcceleratedUrl(downloadUrl);
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => DownloadProgressDialog(
            onDownload:
                (onProgress, isCancelled) => downloader.downloadFile(
                  acceleratedUrl,
                  fileName,
                  onProgress,
                  isCancelled,
                ),
            fileName: fileName,
          ),
    );
  }
}
