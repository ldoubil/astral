import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/ui/base_settings_page.dart';
import 'package:astral/features/settings/widgets/update_settings_actions.dart';
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
        onPressed: () => checkForUpdates(context),
        tooltip: LocaleKeys.check_update.tr(),
      ),
    ];
  }

  @override
  Widget buildContent(BuildContext context) {
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
              value: ServiceManager().updateState.beta.watch(context),
              onChanged: (value) {
                ServiceManager().appSettings.setBeta(value);
              },
            ),
            if (!ServiceManager().updateState.beta.watch(context))
              SwitchListTile(
                title: Text(LocaleKeys.auto_update.tr()),
                subtitle: Text(LocaleKeys.auto_update_desc.tr()),
                value: ServiceManager().updateState.autoCheckUpdate.watch(
                  context,
                ),
                onChanged: (value) {
                  ServiceManager().appSettings.setAutoCheckUpdate(value);
                },
              ),
            buildDivider(),
            ListTile(
              leading: const Icon(Icons.bolt),
              title: Text(LocaleKeys.download_acceleration.tr()),
              subtitle: Text(downloadAccelerateDescription()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => editDownloadAccelerate(context),
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
              onTap: () => checkForUpdates(context),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(LocaleKeys.version_info.tr()),
              subtitle: Text(LocaleKeys.version_info_desc.tr()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showVersionInfo(context),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(LocaleKeys.history_versions.tr()),
              subtitle: Text(LocaleKeys.history_versions_desc.tr()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => navigateToHistoryVersions(context),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_download),
              title: const Text('重新下载'),
              subtitle: const Text('如果出现问题可以尝试重新下载！'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => redownloadUpdate(context),
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
  }
}
