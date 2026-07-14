import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/shared/utils/github_proxy_selector.dart';
import 'package:astral/core/platform/app_info.dart';
import 'package:astral/core/services/update_service.dart';
import 'package:astral/shared/widgets/common/update_check_ui.dart';
import 'package:astral/features/settings/pages/general/history_versions_page.dart';

void checkForUpdates(BuildContext context) {
  final checker = UpdateChecker(owner: 'ldoubil', repo: 'astral');
  if (context.mounted) {
    UpdateCheckUi.checkAndPresent(context, checker);
  }
}

void navigateToHistoryVersions(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const HistoryVersionsPage()),
  );
}

void redownloadUpdate(BuildContext context) {
  final checker = UpdateChecker(owner: 'ldoubil', repo: 'astral');
  if (context.mounted) {
    UpdateCheckUi.checkAndPresent(context, checker, forceShowDownload: true);
  }
}

void showVersionInfo(BuildContext context) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(LocaleKeys.version_info.tr()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${LocaleKeys.current_version.tr()}: ${AppInfoUtil.getVersion()}',
              ),
              const SizedBox(height: 8),
              Text(
                '${LocaleKeys.update_channel.tr()}: ${ServiceManager().updateState.beta.value ? "Beta" : "Stable"}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(LocaleKeys.close.tr()),
            ),
          ],
        ),
  );
}

String downloadAccelerateDescription() {
  final setting = ServiceManager().updateState.downloadAccelerate.value;
  if (!GitHubProxySelector.isAccelerationEnabled(setting)) {
    return LocaleKeys.download_acceleration_disabled.tr();
  }
  if (GitHubProxySelector.isAutoMode(setting)) {
    final resolved =
        ServiceManager().updateState.resolvedDownloadAccelerate.value;
    if (resolved != null && resolved.isNotEmpty) {
      return LocaleKeys.download_acceleration_auto_current.tr(
        namedArgs: {'mirror': resolved},
      );
    }
    return LocaleKeys.download_acceleration_auto_pending.tr();
  }
  return setting;
}

void editDownloadAccelerate(BuildContext context) {
  final current = ServiceManager().updateState.downloadAccelerate.value;
  var mode = GitHubProxySelector.isAccelerationEnabled(current)
      ? (GitHubProxySelector.isAutoMode(current) ? 'auto' : 'manual')
      : 'off';
  final controller = TextEditingController(
    text: GitHubProxySelector.isAutoMode(current) ? '' : current,
  );
  var probing = false;
  String? probeResult;

  showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) {
        Future<void> runProbe() async {
          setState(() {
            probing = true;
            probeResult = null;
          });
          GitHubProxySelector.invalidateCache();
          final prefix = await GitHubProxySelector.selectFastest(
            forceRefresh: true,
          );
          if (!dialogContext.mounted) return;
          setState(() {
            probing = false;
            probeResult =
                prefix ?? LocaleKeys.download_acceleration_probe_failed.tr();
          });
          if (prefix != null) {
            ServiceManager().updateState.setResolvedDownloadAccelerate(prefix);
          }
        }

        return AlertDialog(
          title: Text(LocaleKeys.download_acceleration_title.tr()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(LocaleKeys.download_acceleration_info_desc.tr()),
                const SizedBox(height: 12),
                RadioGroup<String>(
                  groupValue: mode,
                  onChanged: (value) {
                    if (value != null) setState(() => mode = value);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<String>(
                        title: Text(LocaleKeys.download_acceleration_auto.tr()),
                        subtitle: Text(
                          GitHubProxySelector.builtInMirrors.join('\n'),
                          style: const TextStyle(fontSize: 12),
                        ),
                        value: 'auto',
                      ),
                      RadioListTile<String>(
                        title: Text(
                          LocaleKeys.download_acceleration_manual.tr(),
                        ),
                        value: 'manual',
                      ),
                      if (mode == 'manual')
                        TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText:
                                LocaleKeys.download_acceleration_manual_hint
                                    .tr(),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      RadioListTile<String>(
                        title: Text(
                          LocaleKeys.download_acceleration_disabled.tr(),
                        ),
                        value: 'off',
                      ),
                    ],
                  ),
                ),
                if (mode == 'auto') ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: probing ? null : runProbe,
                    icon: probing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.speed),
                    label: Text(
                      probing
                          ? LocaleKeys.download_acceleration_probing.tr()
                          : LocaleKeys.download_acceleration_reprobe.tr(),
                    ),
                  ),
                  if (probeResult != null) ...[
                    const SizedBox(height: 8),
                    Text(probeResult!, style: const TextStyle(fontSize: 13)),
                  ],
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(LocaleKeys.cancel.tr()),
            ),
            ElevatedButton(
              onPressed: () async {
                switch (mode) {
                  case 'auto':
                    await ServiceManager().appSettings.setDownloadAccelerate(
                      GitHubProxySelector.autoMode,
                    );
                    break;
                  case 'manual':
                    final value = controller.text.trim();
                    final normalized = GitHubProxySelector.normalizePrefix(
                      value.isEmpty
                          ? GitHubProxySelector.builtInMirrors.first
                          : value,
                    );
                    await ServiceManager().appSettings.setDownloadAccelerate(
                      normalized,
                    );
                    break;
                  case 'off':
                    await ServiceManager().appSettings.setDownloadAccelerate(
                      '',
                    );
                    GitHubProxySelector.invalidateCache();
                    ServiceManager()
                        .updateState
                        .setResolvedDownloadAccelerate(null);
                    break;
                }
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(LocaleKeys.save.tr()),
            ),
          ],
        );
      },
    ),
  ).then((_) => controller.dispose());
}
