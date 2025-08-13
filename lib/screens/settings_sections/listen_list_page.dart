import 'package:astral/k/app_s/aps.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

class ListenListPage extends StatelessWidget {
  const ListenListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.listen_list.tr()),
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
                final listenList = Aps().listenList.watch(context);
                return Column(
                  children: [
                    ...List.generate(listenList.length, (index) {
                      final item = listenList[index];
                      return ListTile(
                        title: Text(item),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              tooltip: LocaleKeys.edit.tr(),
                              onPressed: () async {
                                final controller = TextEditingController(
                                  text: item,
                                );
                                final result = await showDialog<String>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: Text(
                                          LocaleKeys.edit_listen_item.tr(),
                                        ),
                                        content: TextField(
                                          controller: controller,
                                          autofocus: true,
                                          decoration: InputDecoration(
                                            labelText:
                                                LocaleKeys.listen_item.tr(),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
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
                                            child: Text(LocaleKeys.save.tr()),
                                          ),
                                        ],
                                      ),
                                );
                                if (result != null &&
                                    result.trim().isNotEmpty &&
                                    result != item) {
                                  await Aps().updateListen(
                                    index,
                                    result.trim(),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              tooltip: LocaleKeys.delete.tr(),
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
                                              .confirm_delete_listen_item
                                              .tr(namedArgs: {'item': item}),
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
                                  await Aps().deleteListen(index);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: Text(LocaleKeys.add_listen_item.tr()),
                      onTap: () async {
                        final controller = TextEditingController();
                        final result = await showDialog<String>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('新增监听项'),
                                content: TextField(
                                  controller: controller,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    labelText: LocaleKeys.listen_item.tr(),
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
                        if (result != null && result.trim().isNotEmpty) {
                          await Aps().addListen(result.trim());
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