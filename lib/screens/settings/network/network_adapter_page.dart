import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/k/services/service_manager.dart';
import 'package:astral/src/rust/api/hops.dart';
import 'package:signals_flutter/signals_flutter.dart';

class NetworkAdapterPage extends StatelessWidget {
  const NetworkAdapterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.network_adapter_hop_settings.tr()),
        centerTitle: true,
      ),
      body: Watch((context) {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(LocaleKeys.auto_set_hop.tr()),
                    subtitle: Text(LocaleKeys.auto_set_hop_desc.tr()),
                    value: ServiceManager().networkConfigState.autoSetMTU.value,
                    onChanged: (value) {
                      ServiceManager().networkConfig.setAutoSetMTU(value);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.list),
                    title: Text(LocaleKeys.view_hop_list.tr()),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showHopList(context),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _showHopList(BuildContext context) async {
    try {
      final result = await getAllInterfacesMetrics();
      if (!context.mounted) return;

      await showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(LocaleKeys.network_adapter_hop_list.tr()),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      result
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text('${e.$1}: ${e.$2}'),
                            ),
                          )
                          .toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(LocaleKeys.close.tr()),
                ),
              ],
            ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocaleKeys.get_hop_list_failed.tr())),
      );
    }
  }
}
