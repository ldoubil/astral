import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/ui/base_settings_page.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ListenListPage extends BaseSettingsPage {
  const ListenListPage({super.key});

  @override
  String get title => LocaleKeys.listen_list.tr();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.add),
        onPressed: () => _addListenItem(context),
      ),
    ];
  }

  @override
  Widget buildContent(BuildContext context) {
    return Watch((context) {
      final listenList = ServiceManager().appSettingsState.listenList.value;

      if (listenList.isEmpty) {
        return buildEmptyState(
          context: context,
          icon: Icons.list_alt,
          title: '暂无监听项',
          actionLabel: LocaleKeys.add_listen_item.tr(),
          onAction: () => _addListenItem(context),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: listenList.length,
        itemBuilder: (context, index) {
          final item = listenList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(item),
              leading: const Icon(Icons.dns),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    tooltip: LocaleKeys.edit.tr(),
                    onPressed: () => _editListenItem(context, index, item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    tooltip: LocaleKeys.delete.tr(),
                    onPressed: () => _deleteListenItem(context, index, item),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Future<void> _addListenItem(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.add_listen_item.tr()),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: LocaleKeys.listen_item.tr(),
                hintText: 'localhost:8080',
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

    if (result != null && result.trim().isNotEmpty) {
      await ServiceManager().appSettings.addListen(result.trim());
    }
  }

  Future<void> _editListenItem(
    BuildContext context,
    int index,
    String item,
  ) async {
    final controller = TextEditingController(text: item);
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.edit_listen_item.tr()),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: LocaleKeys.listen_item.tr(),
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

    if (result != null && result.trim().isNotEmpty && result != item) {
      await ServiceManager().appSettings.updateListen(index, result.trim());
    }
  }

  Future<void> _deleteListenItem(
    BuildContext context,
    int index,
    String item,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.confirm_delete.tr()),
            content: Text(
              LocaleKeys.confirm_delete_listen_item.tr(
                namedArgs: {'item': item},
              ),
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
      await ServiceManager().appSettings.deleteListen(index);
    }
  }
}
