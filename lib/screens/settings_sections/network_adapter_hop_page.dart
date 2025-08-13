import 'package:astral/src/rust/api/hops.dart';
import 'package:astral/k/app_s/aps.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

class NetworkAdapterHopPage extends StatelessWidget {
  const NetworkAdapterHopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.network_adapter_hop_settings.tr()),
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
                  title: Text(LocaleKeys.auto_set_hop.tr()),
                  subtitle: Text(LocaleKeys.auto_set_hop_desc.tr()),
                  value: Aps().autoSetMTU.watch(context),
                  onChanged: (value) {
                    Aps().setAutoSetMTU(value);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.list),
                  title: Text(LocaleKeys.view_hop_list.tr()),
                  onTap: () async {
                    try {
                      final result = await getAllInterfacesMetrics();
                      if (!context.mounted) return;

                      await showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text(
                                LocaleKeys.network_adapter_hop_list.tr(),
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      result
                                          .map((e) => Text('${e.$1}: ${e.$2}'))
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
                    } catch (e, s) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(LocaleKeys.get_hop_list_failed.tr()),
                        ),
                      );
                    }
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