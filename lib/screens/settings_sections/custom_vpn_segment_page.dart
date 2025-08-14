import 'package:astral/k/app_s/aps.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

class CustomVpnSegmentPage extends StatelessWidget {
  const CustomVpnSegmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.custom_vpn_segment.tr()),
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
            child: Builder(
              builder: (context) {
                final vpnList = Aps().customVpn.watch(context);
                return Column(
                  children: [
                    ...List.generate(vpnList.length, (index) {
                      final vpn = vpnList[index];
                      return ListTile(
                        title: Text(vpn),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () async {
                                final controller = TextEditingController(
                                  text: vpn,
                                );
                                final result = await showDialog<String>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: Text(
                                          LocaleKeys.edit_vpn_segment.tr(),
                                        ),
                                        content: TextField(
                                          controller: controller,
                                          decoration: InputDecoration(
                                            labelText:
                                                LocaleKeys
                                                    .vpn_segment_format_example
                                                    .tr(),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () =>
                                                    Navigator.pop(context),
                                            child: Text(
                                              LocaleKeys.cancel.tr(),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  controller.text,
                                                ),
                                            child: Text(
                                              LocaleKeys.save.tr(),
                                            ),
                                          ),
                                        ],
                                      ),
                                );
                                if (result != null && result.isNotEmpty) {
                                  await Aps().updateCustomVpn(
                                    index,
                                    result,
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: Text(
                                          LocaleKeys.confirm_delete.tr(),
                                        ),
                                        content: Text(
                                          LocaleKeys
                                              .confirm_delete_vpn_segment
                                              .tr(namedArgs: {'vpn': vpn}),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: Text(
                                              LocaleKeys.cancel.tr(),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: Text(
                                              LocaleKeys.delete.tr(),
                                            ),
                                          ),
                                        ],
                                      ),
                                );
                                if (confirm == true) {
                                  await Aps().deleteCustomVpn(index);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: Text(LocaleKeys.add_vpn_segment.tr()),
                      onTap: () async {
                        final controller = TextEditingController();
                        final result = await showDialog<String>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text(
                                  LocaleKeys.add_vpn_segment.tr(),
                                ),
                                content: TextField(
                                  controller: controller,
                                  decoration: InputDecoration(
                                    labelText:
                                        LocaleKeys
                                            .vpn_segment_format_example
                                            .tr(),
                                    hintText:
                                        LocaleKeys.vpn_segment_input_hint
                                            .tr(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(LocaleKeys.cancel.tr()),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(
                                          context,
                                          controller.text,
                                        ),
                                    child: Text(LocaleKeys.add.tr()),
                                  ),
                                ],
                              ),
                        );
                        if (result != null && result.isNotEmpty) {
                          await Aps().addCustomVpn(result);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}