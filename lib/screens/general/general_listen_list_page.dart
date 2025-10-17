import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

class GeneralListenListPage extends StatefulWidget {
  final List<String> listeners;
  const GeneralListenListPage({super.key, this.listeners = const []});

  @override
  State<GeneralListenListPage> createState() => _GeneralListenListPageState();
}

class _GeneralListenListPageState extends State<GeneralListenListPage> {
  late List<String> _listeners;

  @override
  void initState() {
    super.initState();
    _listeners = List.from(widget.listeners);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("编辑监听列表"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _listeners),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addListenItem(context),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (_listeners.isEmpty) {
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
            itemCount: _listeners.length,
            itemBuilder: (context, index) {
              final item = _listeners[index];
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
                        onPressed:
                            () => _deleteListenItem(context, index, item),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
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
      setState(() {
        _listeners.add(result.trim());
      });
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
      setState(() {
        _listeners[index] = result.trim();
      });
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
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(LocaleKeys.delete.tr()),
              ),
            ],
          ),
    );

    if (confirm == true) {
      setState(() {
        _listeners.removeAt(index);
      });
    }
  }
}
