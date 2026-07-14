import 'package:astral/core/services/update_downloader.dart';
import 'package:astral/core/services/update_service.dart';
import 'package:astral/shared/widgets/common/update_dialogs.dart';
import 'package:astral/shared/widgets/common/update_download_ui.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 更新检查 UI 编排（对话框）
class UpdateCheckUi {
  const UpdateCheckUi._();

  static final _downloader = UpdateDownloader();

  static Future<void> checkAndPresent(
    BuildContext context,
    UpdateChecker checker, {
    bool showNoUpdateMessage = true,
    bool forceShowDownload = false,
    bool showFailureMessage = true,
  }) async {
    final result = await checker.check(
      forceShowDownload: forceShowDownload,
      showNoUpdateMessage: showNoUpdateMessage,
      showFailureMessage: showFailureMessage,
    );

    if (!context.mounted || result == null) return;
    _showDialog(context, result);
  }

  static void _showDialog(BuildContext context, UpdateCheckResult result) {
    final parentContext = context;
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder:
          (dialogContext) => UpdateDialog(
            version: result.version,
            releaseNotes: result.releaseNotes,
            downloadUrl: result.releasePage,
            isLatestVersion: result.isLatestVersion,
            releaseInfo: result.releaseInfo,
            onDownload:
                result.releaseInfo != null
                    ? () => UpdateDownloadUi.handleDownload(
                      parentContext,
                      result.releaseInfo!,
                      _downloader,
                    )
                    : null,
            onNetDiskDownload:
                result.releaseInfo != null
                    ? () => openNetDiskDownload(parentContext)
                    : null,
          ),
    );
  }

  static Future<void> openNetDiskDownload(BuildContext context) async {
    final uri = Uri.parse(
      'https://astral.fan/quick-start/download-install/',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
