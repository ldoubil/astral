import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/core/ui/base_settings_page.dart';
import 'package:astral/features/settings/widgets/network_settings_sections.dart';

class NetworkSettingsPage extends BaseSettingsPage {
  const NetworkSettingsPage({super.key});

  @override
  String get title => LocaleKeys.network_settings.tr();

  @override
  Widget buildContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        NetworkBasicSettingsCard(),
        const SizedBox(height: 16),
        NetworkAdvancedSettingsCard(),
        const SizedBox(height: 16),
        NetworkHopSettingsCard(),
      ],
    );
  }
}
