import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/shared/utils/ui/route_helper.dart';
import 'package:astral/core/ui/base_settings_page.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ForwardingManagementPage extends BaseSettingsPage {
  const ForwardingManagementPage({super.key});

  @override
  String get title => LocaleKeys.forwarding_management.tr();

  @override
  Widget buildContent(BuildContext context) {
    return Watch((context) {
      final connections = ServiceManager().connectionState.connections.value;
      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ...List.generate(connections.length, (index) {
            final manager = connections[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ExpansionTile(
                leading: Switch(
                  value: manager.enabled,
                  onChanged: (value) async {
                    await ServiceManager().connection.updateConnectionEnabled(
                      index,
                      value,
                    );
                  },
                ),
                title: Text(
                  manager.name.isEmpty
                      ? LocaleKeys.unnamed_group.tr()
                      : manager.name,
                ),
                subtitle: Text(
                  '${manager.connections.length} ${LocaleKeys.connections_count.tr()}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: LocaleKeys.edit.tr(),
                      onPressed:
                          () => editConnectionManager(context, index, manager),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      tooltip: LocaleKeys.delete.tr(),
                      onPressed:
                          () => deleteConnectionManager(
                            context,
                            index,
                            manager.name,
                          ),
                    ),
                  ],
                ),
                children: [
                  ...manager.connections.map(
                    (conn) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.link, size: 16),
                      title: Text('${conn.bindAddr} → ${conn.dstAddr}'),
                      subtitle: Text(
                        '${LocaleKeys.protocol.tr()}: ${conn.proto}',
                      ),
                    ),
                  ),
                  if (manager.connections.isEmpty)
                    ListTile(
                      dense: true,
                      title: Text(LocaleKeys.no_connection_config.tr()),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.add),
              title: Text(LocaleKeys.add_forwarding_group.tr()),
              onTap: () => addConnectionManager(context),
            ),
          ),
        ],
      );
    });
  }
}
