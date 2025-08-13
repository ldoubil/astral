import 'package:astral/utils/reg.dart';
import 'package:astral/k/app_s/aps.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

class StartupSettingsPage extends StatelessWidget {
  const StartupSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.startup_related.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(LocaleKeys.startup_on_boot.tr()),
                  subtitle: Text(LocaleKeys.startup_on_boot_desc.tr()),
                  value: Aps().startup.watch(context),
                  onChanged: (value) {
                    Aps().setStartup(value);
                    handleStartupSetting(value);
                  },
                ),
                SwitchListTile(
                  title: Text(LocaleKeys.startup_minimize.tr()),
                  subtitle: Text(LocaleKeys.startup_minimize_desc.tr()),
                  value: Aps().startupMinimize.watch(context),
                  onChanged: (value) {
                    Aps().setStartupMinimize(value);
                  },
                ),
                SwitchListTile(
                  title: Text(LocaleKeys.startup_auto_connect.tr()),
                  subtitle: Text(LocaleKeys.startup_auto_connect_desc.tr()),
                  value: Aps().startupAutoConnect.watch(context),
                  onChanged: (value) {
                    Aps().setStartupAutoConnect(value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void handleStartupSetting(bool value) {
    // TODO: 实现启动项设置功能
  }
}