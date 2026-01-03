import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/k/services/service_manager.dart';
import 'package:astral/utils/up.dart';
import 'package:astral/screens/settings/general/history_versions_page.dart';
import 'package:signals_flutter/signals_flutter.dart';

class UpdateSettingsPage extends StatelessWidget {
  const UpdateSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.update_settings.tr()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _checkForUpdates(context),
            tooltip: LocaleKeys.check_update.tr(),
          ),
        ],
      ),
      body: Watch((context) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text(LocaleKeys.update_settings.tr()),
                    subtitle: Text(LocaleKeys.update_behavior_desc.tr()),
                    leading: const Icon(Icons.system_update),
                  ),

                  const Divider(),

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
                ],
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text(LocaleKeys.update_operations.tr()),
                    subtitle: Text(LocaleKeys.update_operations_desc.tr()),
                    leading: const Icon(Icons.update),
                  ),

                  const Divider(),

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
            ),

            const SizedBox(height: 16),

            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text(LocaleKeys.update_description.tr()),
                    subtitle: Text(LocaleKeys.update_description_desc.tr()),
                    leading: const Icon(Icons.help_outline),
                  ),

                  const Divider(),

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
            ),
          ],
        );
      }),
    );
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

  void _openNetDiskDownload(BuildContext context) {
    final updateChecker = UpdateChecker(owner: 'ldoubil', repo: 'astral');
    updateChecker.openNetDiskDownload(context);
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
}
