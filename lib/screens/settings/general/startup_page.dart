import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/ui/base_settings_page.dart';

class StartupPage extends BaseSettingsPage {
  const StartupPage({super.key});

  @override
  String get title => LocaleKeys.startup_related.tr();

  @override
  Widget buildContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        buildSettingsCard(
          context: context,
          children: [
            SwitchListTile(
              title: Text(LocaleKeys.startup_on_boot.tr()),
              subtitle: Text(LocaleKeys.startup_on_boot_desc.tr()),
              value: ServiceManager().startupState.startup.value,
              onChanged: (value) {
                ServiceManager().appSettings.setStartup(value);
                // TODO: Implement startup setting handler
              },
            ),
            SwitchListTile(
              title: Text(LocaleKeys.startup_minimize.tr()),
              subtitle: Text(LocaleKeys.startup_minimize_desc.tr()),
              value: ServiceManager().startupState.startupMinimize.value,
              onChanged: (value) {
                ServiceManager().appSettings.setStartupMinimize(value);
              },
            ),
            SwitchListTile(
              title: Text(LocaleKeys.startup_auto_connect.tr()),
              subtitle: Text(LocaleKeys.startup_auto_connect_desc.tr()),
              value: ServiceManager().startupState.startupAutoConnect.value,
              onChanged: (value) {
                ServiceManager().appSettings.setStartupAutoConnect(value);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        buildSettingsCard(
          context: context,
          header: LocaleKeys.startup_description.tr(),
          children: [
            ListTile(
              title: Text(LocaleKeys.startup_on_boot_title.tr()),
              subtitle: Text(LocaleKeys.startup_on_boot_info.tr()),
              leading: const Icon(Icons.power_settings_new),
            ),
            buildDivider(),
            ListTile(
              title: Text(LocaleKeys.startup_minimize_title.tr()),
              subtitle: Text(LocaleKeys.startup_minimize_info.tr()),
              leading: const Icon(Icons.minimize),
            ),
            buildDivider(),
            ListTile(
              title: Text(LocaleKeys.startup_auto_connect_title.tr()),
              subtitle: Text(LocaleKeys.startup_auto_connect_info.tr()),
              leading: const Icon(Icons.play_arrow),
            ),
          ],
        ),
      ],
    );
  }
}
