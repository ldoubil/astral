import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/ui/base_settings_page.dart';
import 'package:signals_flutter/signals_flutter.dart';

class SoftwareSettingsPage extends BaseStatefulSettingsPage {
  const SoftwareSettingsPage({super.key});

  @override
  BaseStatefulSettingsPageState<SoftwareSettingsPage> createState() =>
      _SoftwareSettingsPageState();
}

class _SoftwareSettingsPageState
    extends BaseStatefulSettingsPageState<SoftwareSettingsPage> {
  bool _hasInstallPermission = false;
  bool _hasNotificationPermission = false;

  @override
  String get title => LocaleKeys.software_settings.tr();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _checkInstallPermission();
      _checkNotificationPermission();
    }
  }

  Future<void> _checkNotificationPermission() async {
    try {
      final status = await Permission.notification.status;
      if (mounted) {
        setState(() {
          _hasNotificationPermission = status.isGranted;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasNotificationPermission = false;
        });
      }
    }
  }

  Future<void> _requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      if (!context.mounted) return;

      await _checkNotificationPermission();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status.isGranted
                ? LocaleKeys.permission_notification_success.tr()
                : LocaleKeys.permission_notification_failed.tr(),
          ),
        ),
      );

      if (status.isPermanentlyDenied) {
        _showNotificationPermissionDialog();
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocaleKeys.permission_notification_request_failed.tr()),
        ),
      );
    }
  }

  void _showNotificationPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocaleKeys.permission_denied.tr()),
          content: Text(LocaleKeys.permission_notification_denied_message.tr()),
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
  Widget buildContent(BuildContext context) {
    return Watch((context) {
      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          buildSettingsCard(
            context: context,
            children: [
              ListTile(
                title: Text(LocaleKeys.software_settings.tr()),
                subtitle: Text(LocaleKeys.software_behavior_desc.tr()),
                leading: const Icon(Icons.settings),
              ),
              buildDivider(),
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
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.warning, color: Colors.orange),
                  onTap:
                      _hasInstallPermission ? null : _requestInstallPermission,
                ),
              if (!Platform.isAndroid)
                SwitchListTile(
                  title: Text(LocaleKeys.minimize.tr()),
                  subtitle: Text(LocaleKeys.minimize_desc.tr()),
                  value: ServiceManager().windowState.closeMinimize.value,
                  onChanged: (value) {
                    ServiceManager().appSettings.updateCloseMinimize(value);
                  },
                ),
              SwitchListTile(
                title: Text(LocaleKeys.player_list_card.tr()),
                subtitle: Text(LocaleKeys.player_list_card_desc.tr()),
                value: ServiceManager().displayState.userListSimple.value,
                onChanged: (value) {
                  ServiceManager().appSettings.setUserListSimple(value);
                },
              ),
              SwitchListTile(
                title: Text(LocaleKeys.enable_banner_carousel.tr()),
                subtitle: Text(LocaleKeys.enable_banner_carousel_desc.tr()),
                value: ServiceManager().appSettingsState.enableBannerCarousel
                    .watch(context),
                onChanged: (value) async {
                  await ServiceManager().appSettings.updateEnableBannerCarousel(
                    value,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (Platform.isAndroid)
            buildSettingsCard(
              context: context,
              children: [
                ListTile(
                  title: Text(LocaleKeys.android_settings.tr()),
                  subtitle: Text(LocaleKeys.android_settings_desc.tr()),
                  leading: const Icon(Icons.android),
                ),
                buildDivider(),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(LocaleKeys.get_notification_permission.tr()),
                  subtitle: Text(
                    _hasNotificationPermission
                        ? LocaleKeys.notification_permission_granted.tr()
                        : LocaleKeys.notification_permission_not_granted.tr(),
                  ),
                  trailing:
                      _hasNotificationPermission
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.warning, color: Colors.orange),
                  onTap:
                      _hasNotificationPermission
                          ? null
                          : _requestNotificationPermission,
                ),
                SwitchListTile(
                  title: Text(LocaleKeys.enable_connection_notification.tr()),
                  subtitle: Text(LocaleKeys.enable_connection_notification_desc.tr()),
                  value: ServiceManager().appSettingsState.enableConnectionNotification.watch(context),
                  onChanged: (value) async {
                    if (value && !_hasNotificationPermission) {
                      await _requestNotificationPermission();
                      // 如果请求后仍没有权限，则不允许开启
                      if (!_hasNotificationPermission) return;
                    }
                    await ServiceManager().appSettings.updateEnableConnectionNotification(value);
                  },
                ),
                buildDivider(),
                ListTile(
                  title: Text(LocaleKeys.permission_description.tr()),
                  subtitle: Text(LocaleKeys.permission_description_desc.tr()),
                  leading: const Icon(Icons.info_outline),
                ),
              ],
            ),
        ],
      );
    });
  }
}
