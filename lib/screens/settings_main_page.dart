import 'dart:io';

import 'package:astral/screens/settings_sections/network_settings_page.dart';
import 'package:astral/screens/settings_sections/software_settings_page.dart';
import 'package:astral/screens/settings_sections/update_settings_page.dart';
import 'package:astral/screens/settings_sections/about_page.dart';
import 'package:astral/screens/settings_sections/forwarding_management_page.dart';
import 'package:astral/screens/settings_sections/network_adapter_hop_page.dart';
import 'package:astral/screens/settings_sections/startup_settings_page.dart';
import 'package:astral/screens/settings_sections/listen_list_page.dart';
import 'package:astral/screens/settings_sections/subnet_proxy_cidr_page.dart';
import 'package:astral/screens/settings_sections/custom_vpn_segment_page.dart';
import 'package:astral/k/app_s/aps.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

class SettingsMainPage extends StatelessWidget {
  const SettingsMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14.0),
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: const Icon(Icons.network_wifi),
            title: Text(LocaleKeys.network_settings.tr()),
            subtitle: Text(LocaleKeys.network_settings.tr()),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NetworkSettingsPage(),
                ),
              );
            },
          ),
        ),
        if (Platform.isWindows)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: const Icon(Icons.broadcast_on_personal),
              title: Text(LocaleKeys.forwarding_management.tr()),
              subtitle: Text(LocaleKeys.forwarding_management.tr()),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ForwardingManagementPage(),
                  ),
                );
              },
            ),
          ),
        if (Platform.isWindows)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: const Icon(Icons.network_check),
              title: Text(LocaleKeys.network_adapter_hop_settings.tr()),
              subtitle: Text(LocaleKeys.network_adapter_hop_settings.tr()),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NetworkAdapterHopPage(),
                  ),
                );
              },
            ),
          ),
        if (!Platform.isAndroid)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: const Icon(Icons.launch),
              title: Text(LocaleKeys.startup_related.tr()),
              subtitle: Text(LocaleKeys.startup_related.tr()),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const StartupSettingsPage(),
                  ),
                );
              },
            ),
          ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: const Icon(Icons.list_alt),
            title: Text(LocaleKeys.listen_list.tr()),
            subtitle: Text(LocaleKeys.listen_list.tr()),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ListenListPage(),
                ),
              );
            },
          ),
        ),
        if (!Platform.isAndroid)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: const Icon(Icons.route),
              title: Text(LocaleKeys.subnet_proxy_cidr.tr()),
              subtitle: Text(LocaleKeys.subnet_proxy_cidr.tr()),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SubnetProxyCidrPage(),
                  ),
                );
              },
            ),
          ),
        if (Platform.isAndroid)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: const Icon(Icons.vpn_lock),
              title: Text(LocaleKeys.custom_vpn_segment.tr()),
              subtitle: Text(LocaleKeys.custom_vpn_segment.tr()),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CustomVpnSegmentPage(),
                  ),
                );
              },
            ),
          ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: const Icon(Icons.settings_applications),
            title: Text(LocaleKeys.software_settings.tr()),
            subtitle: Text(LocaleKeys.software_settings.tr()),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SoftwareSettingsPage(),
                ),
              );
            },
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: const Icon(Icons.system_update),
            title: Text(LocaleKeys.update_settings.tr()),
            subtitle: Text(LocaleKeys.update_settings.tr()),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UpdateSettingsPage(),
                ),
              );
            },
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: const Icon(Icons.info),
            title: Text(LocaleKeys.about.tr()),
            subtitle: Text(LocaleKeys.about.tr()),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AboutPage(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}