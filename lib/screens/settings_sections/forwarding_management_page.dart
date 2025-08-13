import 'package:astral/k/app_s/aps.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

class ForwardingManagementPage extends StatefulWidget {
  const ForwardingManagementPage({super.key});

  @override
  State<ForwardingManagementPage> createState() =>
      _ForwardingManagementPageState();
}

class _ForwardingManagementPageState extends State<ForwardingManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.forwarding_management.tr()),
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
                final connections = Aps().connections.watch(context);
                return Column(
                  children: [
                    ...List.generate(connections.length, (index) {
                      final manager = connections[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: ExpansionTile(
                          leading: Switch(
                            value: manager.enabled,
                            onChanged: (value) async {
                              await Aps().updateConnectionEnabled(
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
                                onPressed: () => _editConnectionManager(
                                      context,
                                      index,
                                      manager,
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                tooltip: LocaleKeys.delete.tr(),
                                onPressed: () => _deleteConnectionManager(
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
                                title: Text(
                                  '${conn.bindAddr} → ${conn.dstAddr}',
                                ),
                                subtitle: Text(
                                  '${LocaleKeys.protocol.tr()}: ${conn.proto}',
                                ),
                              ),
                            ),
                            if (manager.connections.isEmpty)
                              ListTile(
                                dense: true,
                                title: Text(
                                  LocaleKeys.no_connection_config.tr(),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: Text(LocaleKeys.add_forwarding_group.tr()),
                      onTap: () => _addConnectionManager(context),
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

  void _addConnectionManager(BuildContext context) {
    // TODO: 实现添加连接管理器功能
  }

  void _editConnectionManager(
      BuildContext context, int index, dynamic manager) {
    // TODO: 实现编辑连接管理器功能
  }

  void _deleteConnectionManager(
      BuildContext context, int index, String name) {
    // TODO: 实现删除连接管理器功能
  }
}