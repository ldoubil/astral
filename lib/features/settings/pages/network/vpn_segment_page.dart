import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/ui/base_settings_page.dart';
import 'package:signals_flutter/signals_flutter.dart';

class VpnSegmentPage extends BaseSettingsPage {
  const VpnSegmentPage({super.key});

  @override
  String get title => LocaleKeys.custom_vpn_segment.tr();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.add),
        onPressed: () => _addVpnSegment(context),
      ),
    ];
  }

  @override
  Widget buildContent(BuildContext context) {
    return Watch((context) {
      final vpnList = ServiceManager().vpnState.customVpn.value;

      if (vpnList.isEmpty) {
        return buildEmptyState(
          context: context,
          icon: Icons.vpn_lock,
          title: 'No VPN segments configured',
          actionLabel: LocaleKeys.add_vpn_segment.tr(),
          onAction: () => _addVpnSegment(context),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: vpnList.length,
        itemBuilder: (context, index) {
          final vpn = vpnList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(vpn),
              leading: const Icon(Icons.network_wifi),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    tooltip: LocaleKeys.edit.tr(),
                    onPressed: () => _editVpnSegment(context, index, vpn),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    tooltip: LocaleKeys.delete.tr(),
                    onPressed: () => _deleteVpnSegment(context, index, vpn),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Future<void> _addVpnSegment(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.add_vpn_segment.tr()),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: LocaleKeys.vpn_segment_format_example.tr(),
                hintText: LocaleKeys.vpn_segment_input_hint.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(LocaleKeys.cancel.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: Text(LocaleKeys.add.tr()),
              ),
            ],
          ),
    );

    if (result != null && result.isNotEmpty) {
      await ServiceManager().appSettings.addCustomVpn(result);
    }
  }

  Future<void> _editVpnSegment(
    BuildContext context,
    int index,
    String vpn,
  ) async {
    final controller = TextEditingController(text: vpn);
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.edit_vpn_segment.tr()),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: LocaleKeys.vpn_segment_format_example.tr(),
                border: const OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(LocaleKeys.cancel.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: Text(LocaleKeys.save.tr()),
              ),
            ],
          ),
    );

    if (result != null && result.isNotEmpty) {
      await ServiceManager().appSettings.updateCustomVpn(index, result);
    }
  }

  Future<void> _deleteVpnSegment(
    BuildContext context,
    int index,
    String vpn,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.confirm_delete.tr()),
            content: Text(
              LocaleKeys.confirm_delete_vpn_segment.tr(namedArgs: {'vpn': vpn}),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(LocaleKeys.cancel.tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(LocaleKeys.delete.tr()),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await ServiceManager().appSettings.deleteCustomVpn(index);
    }
  }
}
