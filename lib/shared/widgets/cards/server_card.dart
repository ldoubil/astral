import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/models/server_mod.dart';
import 'package:astral/shared/utils/network/blocked_servers.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ServerCard extends StatefulWidget {
  final ServerMod server;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ServerCard({
    super.key,
    required this.server,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ServerCard> createState() => _ServerCardState();
}

class _ServerCardState extends State<ServerCard> {
  late final Signal<bool> _hoveredSignal = signal(false);

  @override
  Widget build(BuildContext context) {
    final server = widget.server;
    final colorScheme = Theme.of(context).colorScheme;
    final isHovered = _hoveredSignal.value;

    return MouseRegion(
      onEnter: (_) => _hoveredSignal.value = true,
      onExit: (_) => _hoveredSignal.value = false,
      child: Card(
        elevation: isHovered ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color:
                isHovered
                    ? colorScheme.primary.withOpacity(0.5)
                    : colorScheme.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // 左侧信息区域
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 服务器名称
                      Text(
                        server.name,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // 服务器地址
                      Row(
                        children: [
                          Icon(
                            Icons.language,
                            size: 14,
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.7,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              BlockedServers.isBlocked(server.url)
                                  ? '***'
                                  : server.url,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // 右侧操作区域
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 开关
                    Transform.scale(
                      scale: 0.85,
                      child: Watch((context) {
                        // 监听服务器状态变化
                        final currentServer = ServiceManager().serverState
                            .getServerById(server.id);
                        final isEnabled =
                            currentServer?.enable ?? server.enable;

                        return Switch(
                          value: isEnabled,
                          onChanged: (value) {
                            ServiceManager().server.setServerEnable(
                              server,
                              value,
                            );
                          },
                        );
                      }),
                    ),
                    const SizedBox(width: 4),
                    // 更多操作菜单
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, size: 20),
                      iconSize: 20,
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      tooltip: '更多操作',
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
                            widget.onEdit?.call();
                          }
                        } else if (value == 'delete') {
                          widget.onDelete?.call();
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
