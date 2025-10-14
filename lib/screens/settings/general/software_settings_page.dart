import 'dart:io';
import 'package:astral/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:signals_flutter/signals_flutter.dart';

class SoftwareSettingsPage extends StatefulWidget {
  const SoftwareSettingsPage({super.key});

  @override
  State<SoftwareSettingsPage> createState() => _SoftwareSettingsPageState();
}

class _SoftwareSettingsPageState extends State<SoftwareSettingsPage> {
  bool _hasInstallPermission = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _checkInstallPermission();
    }
  }

  Future<void> _checkInstallPermission() async {
    try {
      final status = await Permission.requestInstallPackages.status;
      if (mounted) {
        setState(() {
          _hasInstallPermission = status.isGranted;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasInstallPermission = false;
        });
      }
    }
  }

  Future<void> _requestInstallPermission() async {
    try {
      final status = await Permission.requestInstallPackages.request();
      if (!context.mounted) return;

      await _checkInstallPermission();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status.isGranted
                ? LocaleKeys.permission_install_success.tr()
                : LocaleKeys.permission_install_failed.tr(),
          ),
        ),
      );

      if (status.isPermanentlyDenied) {
        _showPermissionDialog();
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.permission_install_request_failed.tr()),
        ),
      );
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocaleKeys.permission_denied.tr()),
          content: Text(LocaleKeys.permission_denied_message.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(LocaleKeys.cancel.tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text(LocaleKeys.go_settings.tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.software_settings.tr()),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(LocaleKeys.software_settings.tr()),
                  subtitle: Text('Application behavior and permissions'),
                  leading: const Icon(Icons.settings),
                ),

                const Divider(),

                if (Platform.isAndroid)
                  ListTile(
                    leading: const Icon(Icons.install_mobile),
                    title: Text(LocaleKeys.get_install_permission.tr()),
                    subtitle: Text(
                      _hasInstallPermission
                          ? LocaleKeys.install_permission_granted.tr()
                          : LocaleKeys.install_permission_not_granted.tr(),
                    ),
                    trailing:
                        _hasInstallPermission
                            ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                            : const Icon(Icons.warning, color: Colors.orange),
                    onTap:
                        _hasInstallPermission
                            ? null
                            : _requestInstallPermission,
                  ),

                if (!Platform.isAndroid)
                  SwitchListTile(
                    title: Text(LocaleKeys.minimize.tr()),
                    subtitle: Text(LocaleKeys.minimize_desc.tr()),
                    value: AppState().applicationState.closeMinimize.watch(context),
                    onChanged: (value) {
                      AppState().applicationState.closeMinimize.set(value);
                    },
                  ),

                SwitchListTile(
                  title: Text(LocaleKeys.player_list_card.tr()),
                  subtitle: Text(LocaleKeys.player_list_card_desc.tr()),
                  value: AppState().applicationState.userListSimple.watch(context),
                  onChanged: (value) {
                    AppState().applicationState.userListSimple.set(value);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (Platform.isAndroid)
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: Text('Android 设置'),
                    subtitle: Text('Android 特定的设置选项'),
                    leading: const Icon(Icons.android),
                  ),

                  const Divider(),

                  ListTile(
                    title: Text('权限说明'),
                    subtitle: Text('安装权限用于自动更新应用程序'),
                    leading: const Icon(Icons.info_outline),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
