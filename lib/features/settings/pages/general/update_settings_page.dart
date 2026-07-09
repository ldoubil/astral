import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/shared/utils/helpers/github_proxy_selector.dart';
import 'package:astral/shared/utils/helpers/update_helper.dart';
import 'package:astral/features/settings/pages/general/history_versions_page.dart';
import 'package:astral/core/ui/base_settings_page.dart';
import 'package:signals_flutter/signals_flutter.dart';

class UpdateSettingsPage extends BaseSettingsPage {
  const UpdateSettingsPage({super.key});

  @override
  String get title => LocaleKeys.update_settings.tr();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () => _checkForUpdates(context),
        tooltip: LocaleKeys.check_update.tr(),
      ),
    ];
  }

  @override
  Widget buildContent(BuildContext context) {
    return Watch((context) {
      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          buildSettingsCard(
            context: context,
            children: [
              ListTile(
                title: Text(LocaleKeys.update_settings.tr()),
                subtitle: Text(LocaleKeys.update_behavior_desc.tr()),
                leading: const Icon(Icons.system_update),
              ),
              buildDivider(),
              SwitchListTile(
                title: Text(LocaleKeys.join_beta.tr()),
                subtitle: Text(LocaleKeys.join_beta_desc.tr()),
                value: ServiceManager().updateState.beta.value,
                onChanged: (value) {
                  ServiceManager().appSettings.setBeta(value);
                },
              ),
              if (!ServiceManager().updateState.beta.value)
                SwitchListTile(
                  title: Text(LocaleKeys.auto_update.tr()),
                  subtitle: Text(LocaleKeys.auto_update_desc.tr()),
                  value: ServiceManager().updateState.autoCheckUpdate.value,
                  onChanged: (value) {
                    ServiceManager().appSettings.setAutoCheckUpdate(value);
                  },
                ),
              buildDivider(),
              ListTile(
                leading: const Icon(Icons.bolt),
                title: Text(LocaleKeys.download_acceleration.tr()),
                subtitle: Text(_downloadAccelerateDescription()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _editDownloadAccelerate(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          buildSettingsCard(
            context: context,
            children: [
              ListTile(
                title: Text(LocaleKeys.update_operations.tr()),
                subtitle: Text(LocaleKeys.update_operations_desc.tr()),
                leading: const Icon(Icons.update),
              ),
              buildDivider(),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: Text(LocaleKeys.check_update.tr()),
                subtitle: Text(LocaleKeys.check_update_available.tr()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _checkForUpdates(context),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(LocaleKeys.version_info.tr()),
                subtitle: Text(LocaleKeys.version_info_desc.tr()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showVersionInfo(context),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: Text(LocaleKeys.history_versions.tr()),
                subtitle: Text(LocaleKeys.history_versions_desc.tr()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _navigateToHistoryVersions(context),
              ),
              ListTile(
                leading: const Icon(Icons.cloud_download),
                title: const Text('重新下载'),
                subtitle: const Text('如果出现问题可以尝试重新下载！'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _redownload(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          buildSettingsCard(
            context: context,
            children: [
              ListTile(
                title: Text(LocaleKeys.update_description.tr()),
                subtitle: Text(LocaleKeys.update_description_desc.tr()),
                leading: const Icon(Icons.help_outline),
              ),
              buildDivider(),
              ListTile(
                title: Text(LocaleKeys.beta_version.tr()),
                subtitle: Text(LocaleKeys.beta_version_desc.tr()),
                leading: const Icon(Icons.science),
              ),
              ListTile(
                title: Text(LocaleKeys.auto_update_title.tr()),
                subtitle: Text(LocaleKeys.auto_update_info_desc.tr()),
                leading: const Icon(Icons.auto_awesome),
              ),
            ],
          ),
        ],
      );
    });
  }

  void _checkForUpdates(BuildContext context) {
    final updateChecker = UpdateChecker(owner: 'ldoubil', repo: 'astral');
    if (context.mounted) {
      updateChecker.checkForUpdates(context);
    }
  }

  void _navigateToHistoryVersions(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                const HistoryVersionsPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _redownload(BuildContext context) {
    final updateChecker = UpdateChecker(owner: 'ldoubil', repo: 'astral');
    if (context.mounted) {
      updateChecker.checkForUpdates(context, forceShowDownload: true);
    }
  }

  void _showVersionInfo(BuildContext context) {
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

  String _downloadAccelerateDescription() {
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

  void _editDownloadAccelerate(BuildContext context) {
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
              probeResult = prefix ?? LocaleKeys.download_acceleration_probe_failed.tr();
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
                  RadioListTile<String>(
                    title: Text(LocaleKeys.download_acceleration_auto.tr()),
                    subtitle: Text(
                      GitHubProxySelector.builtInMirrors.join('\n'),
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: 'auto',
                    groupValue: mode,
                    onChanged: (value) => setState(() => mode = value!),
                  ),
                  RadioListTile<String>(
                    title: Text(LocaleKeys.download_acceleration_manual.tr()),
                    value: 'manual',
                    groupValue: mode,
                    onChanged: (value) => setState(() => mode = value!),
                  ),
                  if (mode == 'manual')
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: LocaleKeys.download_acceleration_manual_hint.tr(),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  RadioListTile<String>(
                    title: Text(LocaleKeys.download_acceleration_disabled.tr()),
                    value: 'off',
                    groupValue: mode,
                    onChanged: (value) => setState(() => mode = value!),
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
                      await ServiceManager().appSettings.setDownloadAccelerate('');
                      GitHubProxySelector.invalidateCache();
                      ServiceManager().updateState.setResolvedDownloadAccelerate(null);
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
}
