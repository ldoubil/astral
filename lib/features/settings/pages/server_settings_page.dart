import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/models/server_mod.dart';
import 'package:astral/shared/utils/network/blocked_servers.dart';
import 'package:astral/shared/utils/dialogs/server_dialog.dart';
import 'package:astral/core/ui/base_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ServerSettingsPage extends BaseStatefulSettingsPage {
  const ServerSettingsPage({super.key});

  @override
  BaseStatefulSettingsPageState<ServerSettingsPage> createState() =>
      _ServerSettingsPageState();
}

class _ServerSettingsPageState
    extends BaseStatefulSettingsPageState<ServerSettingsPage> {
  @override
  String get title => '服务器管理';

  @override
  Widget? buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => showAddServerDialog(context),
      child: const Icon(Icons.add),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Watch((context) {
      final servers = ServiceManager().serverState.servers.watch(context);

      if (servers.isEmpty) {
        return buildEmptyState(
          context: context,
          icon: Icons.dns_outlined,
          title: '暂无服务器',
          actionLabel: '添加服务器',
          onAction: () => showAddServerDialog(context),
        );
      }

      return ReorderableListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: servers.length,
        buildDefaultDragHandles: false,
        proxyDecorator: (child, index, animation) {
          return Material(
            elevation: 0,
            color: Colors.transparent,
            child: child,
          );
        },
        onReorder: (oldIndex, newIndex) async {
          final newServers = List<ServerMod>.from(servers);
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final server = newServers.removeAt(oldIndex);
          newServers.insert(newIndex, server);
          await ServiceManager().server.reorderServers(newServers);
        },
        itemBuilder: (context, index) {
          final server = servers[index];

          return ReorderableDragStartListener(
            key: ValueKey(server.id),
            index: index,
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                title: Text(
                  server.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  BlockedServers.isBlocked(server.url) ? '***' : server.url,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: server.enable,
                        onChanged: (value) {
                          ServiceManager().server.setServerEnable(
                            server,
                            value,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 4),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          if (BlockedServers.isBlocked(server.url)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('此服务器不可编辑'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } else {
                            showEditServerDialog(context, server: server);
                          }
                        } else if (value == 'delete') {
                          _showDeleteConfirmDialog(server);
                        }
                      },
                      itemBuilder:
                          (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                    color:
                                        BlockedServers.isBlocked(server.url)
                                            ? colorScheme.outline
                                            : colorScheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '编辑',
                                    style: TextStyle(
                                      color:
                                          BlockedServers.isBlocked(server.url)
                                              ? colorScheme.outline
                                              : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                    color: colorScheme.error,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '删除',
                                    style: TextStyle(color: colorScheme.error),
                                  ),
                                ],
                              ),
                            ),
                          ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  void _showDeleteConfirmDialog(ServerMod server) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('删除服务器'),
            content: Text('确定要删除服务器 "${server.name}" 吗？此操作不可撤销。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  ServiceManager().server.deleteServer(server);
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('删除'),
              ),
            ],
          ),
    );
  }
}
