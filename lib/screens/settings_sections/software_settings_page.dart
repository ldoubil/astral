import 'dart:io';

import 'package:astral/k/app_s/aps.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

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
      // 权限检查失败，默认为false
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

      await _checkInstallPermission(); // 重新检查权限状态

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status.isGranted
                ? LocaleKeys.permission_install_success.tr()
                : LocaleKeys.permission_install_failed.tr(),
          ),
        ),
      );

      // 如果权限被永久拒绝，提示用户去设置页面
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
                if (Platform.isAndroid)
                  ListTile(
                    leading: const Icon(Icons.install_mobile),
                    title: Text(LocaleKeys.get_install_permission.tr()),
                    subtitle: Text(
                      _hasInstallPermission
                          ? LocaleKeys.install_permission_granted.tr()
                          : LocaleKeys.install_permission_not_granted.tr(),
                    ),
                    trailing: _hasInstallPermission
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.warning, color: Colors.orange),
                    onTap:
                        _hasInstallPermission ? null : _requestInstallPermission,
                  ),
                if (!Platform.isAndroid)
                  SwitchListTile(
                    title: Text(LocaleKeys.minimize.tr()),
                    subtitle: Text(LocaleKeys.minimize_desc.tr()),
                    value: Aps().closeMinimize.watch(context),
                    onChanged: (value) {
                      Aps().updateCloseMinimize(value);
                    },
                  ),
                SwitchListTile(
                  title: Text(LocaleKeys.player_list_card.tr()),
                  subtitle: Text(LocaleKeys.player_list_card_desc.tr()),
                  value: Aps().userListSimple.watch(context),
                  onChanged: (value) {
                    Aps().setUserListSimple(value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}