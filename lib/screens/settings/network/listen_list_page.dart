import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/k/services/service_manager.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ListenListPage extends StatelessWidget {
  const ListenListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.listen_list.tr()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addListenItem(context),
          ),
        ],
      ),
      body: Watch((context) {
        final listenList = ServiceManager().appSettingsState.listenList.value;

        if (listenList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.list_alt,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无监听项',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _addListenItem(context),
                  icon: const Icon(Icons.add),
                  label: Text(LocaleKeys.add_listen_item.tr()),
                ),
              ],
            ),
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
      }),
    );
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
