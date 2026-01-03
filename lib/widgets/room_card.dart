// 修改RoomCard类，接收 Room 对象和分类名称列表
import 'package:astral/k/services/service_manager.dart';
import 'package:astral/k/models/room.dart';
import 'package:astral/widgets/home/connect_button.dart';
import 'package:flutter/material.dart';

class RoomCard extends StatefulWidget {
  final Room room;
  final bool isSelected;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  const RoomCard({
    super.key,
    required this.room,
    this.isSelected = false,
    this.onEdit,
    this.onDelete,
    this.onShare,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Card(
        color:
            widget.isSelected
                ? Theme.of(context).brightness == Brightness.dark
                    ? HSLColor.fromColor(
                      colorScheme.primary,
                    ).withLightness(0.10).toColor()
                    : HSLColor.fromColor(
                      colorScheme.primary,
                    ).withLightness(0.95).toColor()
                : colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color:
                (widget.isSelected || _isHovered)
                    ? colorScheme.primary
                    : Colors.transparent,
            width: (_isHovered && !widget.isSelected) ? 1 : 2,
          ),
        ),
        child: InkWell(
          onTap: () {
            ServiceManager().room.setRoom(room);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (widget.isSelected)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.check_circle,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              room.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        if (widget.onShare != null)
                          IconButton(
                            icon: const Icon(Icons.share, size: 20),
                            onPressed: widget.onShare,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: '分享房间',
                          ),
                        if (widget.onShare != null &&
                            (widget.onDelete != null || widget.onEdit != null))
                          const SizedBox(width: 8),
                        if (widget.onDelete != null)
                          widget.isSelected
                              ? Tooltip(
                                message: '不能删除正在连接的房间',
                                child: IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: null,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  disabledColor: colorScheme.outline,
                                ),
                              )
                              : IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('确认删除'),
                                          content: const Text('确定要删除这个房间吗？'),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text('取消'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                widget.onDelete?.call();
                                              },
                                              child: const Text(
                                                '删除',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: '删除房间',
                              ),
                        if (widget.onDelete != null && widget.onEdit != null)
                          const SizedBox(width: 8),
                        if (widget.onEdit != null)
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: widget.onEdit,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: '编辑房间',
                          ),
                        const SizedBox(width: 8),
                        Icon(
                          room.encrypted ? Icons.lock : Icons.lock_open,
                          color: room.encrypted ? Colors.red : Colors.green,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '类型: ${room.encrypted ? "保护" : "不保护"}',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    if (room.servers.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '携带服务器',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
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
