import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/k/services/service_manager.dart';
import 'package:signals_flutter/signals_flutter.dart';

class SubnetProxyPage extends StatelessWidget {
  const SubnetProxyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.subnet_proxy_cidr.tr()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addCidrProxy(context),
          ),
        ],
      ),
      body: Watch((context) {
        final cidrList = ServiceManager().networkConfigState.cidrproxy.value;

        if (cidrList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.route,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No CIDR proxy rules',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _addCidrProxy(context),
                  icon: const Icon(Icons.add),
                  label: Text(LocaleKeys.add_cidr_proxy.tr()),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: cidrList.length,
          itemBuilder: (context, index) {
            final cidr = cidrList[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(cidr),
                leading: const Icon(Icons.network_cell),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: LocaleKeys.edit.tr(),
                      onPressed: () => _editCidr(context, index, cidr),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      tooltip: LocaleKeys.delete.tr(),
                      onPressed: () => _deleteCidr(context, index, cidr),
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

  Future<void> _addCidrProxy(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.add_cidr_proxy.tr()),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: LocaleKeys.cidr_format_example.tr(),
                hintText: LocaleKeys.cidr_input_hint.tr(),
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
      await ServiceManager().networkConfig.addCidrproxy(result);
    }
  }

  Future<void> _editCidr(BuildContext context, int index, String cidr) async {
    final controller = TextEditingController(text: cidr);
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.edit_cidr.tr()),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: LocaleKeys.cidr_format_example.tr(),
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
      await ServiceManager().networkConfig.updateCidrproxy(index, result);
    }
  }

  Future<void> _deleteCidr(BuildContext context, int index, String cidr) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.confirm_delete.tr()),
            content: Text(
              LocaleKeys.confirm_delete_cidr.tr(namedArgs: {'cidr': cidr}),
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
      await ServiceManager().networkConfig.deleteCidrproxy(index);
    }
  }
}
