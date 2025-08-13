import 'package:astral/utils/up.dart';
import 'package:astral/k/app_s/aps.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

class UpdateSettingsPage extends StatelessWidget {
  const UpdateSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.update_settings.tr()),
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
                  title: Text(LocaleKeys.join_beta.tr()),
                  subtitle: Text(LocaleKeys.join_beta_desc.tr()),
                  value: Aps().beta.watch(context),
                  onChanged: (value) {
                    Aps().setBeta(value);
                  },
                ),
                if (!Aps().beta.watch(context))
                  SwitchListTile(
                    title: Text(LocaleKeys.auto_update.tr()),
                    subtitle: Text(LocaleKeys.auto_update_desc.tr()),
                    value: Aps().autoCheckUpdate.watch(context),
                    onChanged: (value) {
                      Aps().setAutoCheckUpdate(value);
                    },
                  ),
                ListTile(
                  title: Text(LocaleKeys.download_acceleration.tr()),
                  subtitle: TextFormField(
                    decoration: InputDecoration(
                      hintText: LocaleKeys.download_acceleration_hint.tr(),
                      border: const OutlineInputBorder(),
                    ),
                    initialValue: Aps().downloadAccelerate.watch(context),
                    onChanged: (value) {
                      Aps().setDownloadAccelerate(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}