import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/k/services/service_manager.dart';
import 'package:signals_flutter/signals_flutter.dart';

class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.startup_related.tr()),
        centerTitle: true,
      ),
      body: Watch((context) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text(LocaleKeys.startup_related.tr()),
                    subtitle: Text(LocaleKeys.startup_behavior_desc.tr()),
                    leading: const Icon(Icons.launch),
                  ),

                  const Divider(),

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
                    value:
                        ServiceManager().startupState.startupAutoConnect.value,
                    onChanged: (value) {
                      ServiceManager().appSettings.setStartupAutoConnect(value);
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
                    title: Text(LocaleKeys.startup_description.tr()),
                    subtitle: Text(LocaleKeys.startup_description_desc.tr()),
                    leading: const Icon(Icons.info_outline),
                  ),

                  const Divider(),

                  ListTile(
                    title: Text(LocaleKeys.startup_on_boot_title.tr()),
                    subtitle: Text(LocaleKeys.startup_on_boot_info.tr()),
                    leading: const Icon(Icons.power_settings_new),
                  ),

                  ListTile(
                    title: Text(LocaleKeys.startup_minimize_title.tr()),
                    subtitle: Text(LocaleKeys.startup_minimize_info.tr()),
                    leading: const Icon(Icons.minimize),
                  ),

                  ListTile(
                    title: Text(LocaleKeys.startup_auto_connect_title.tr()),
                    subtitle: Text(LocaleKeys.startup_auto_connect_info.tr()),
                    leading: const Icon(Icons.play_arrow),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
