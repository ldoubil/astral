import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:astral/k/models/room.dart';
import 'package:astral/k/services/service_manager.dart';

// 添加DragHandle定义
class DragHandle extends StatelessWidget {
  const DragHandle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 16,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outline,
        borderRadius: BorderRadius.circular(2.5),
      ),
    );
  }
}

class RoomReorderSheet extends StatefulWidget {
  final List<Room> rooms;
  final Function(List<Room>) onReorder;

  const RoomReorderSheet({
    Key? key,
    required this.rooms,
    required this.onReorder,
  }) : super(key: key);

  @override
  State<RoomReorderSheet> createState() => _RoomReorderSheetState();

  static Future<void> show(BuildContext context, List<Room> rooms) async {
    final services = ServiceManager();

    if (MediaQuery.of(context).size.width > 600) {
      // PC端显示为对话框
      await showDialog(
        context: context,
        builder:
            (context) => Dialog(
              child: Container(
                width: 400,
                height: 600,
                child: RoomReorderSheet(
                  rooms: List.from(rooms),
                  onReorder: (reorderedRooms) {
                    services.room.reorderRooms(reorderedRooms);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
      );
    } else {
      // 移动端显示为底部弹窗
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) => DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder:
                  (context, scrollController) => Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: RoomReorderSheet(
                      rooms: List.from(rooms),
                      onReorder: (reorderedRooms) {
                        services.room.reorderRooms(reorderedRooms);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
            ),
      );
    }
  }
}

class _RoomReorderSheetState extends State<RoomReorderSheet> {
  late List<Room> _rooms;
  String _currentHoveredRoomName = ''; // 新增悬停状态变量

  @override
  void initState() {
    super.initState();
    _rooms = List.from(widget.rooms);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // 标题栏
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.sort, color: colorScheme.primary, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '房间排序',
                    style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '拖拽房间卡片来调整显示顺序',
                textAlign: TextAlign.left,
                maxLines: null,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // 房间列表 - 使用 Expanded 填充剩余空间
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: ReorderableListView.builder(
              // 移除水平内边距
              padding: EdgeInsets.zero,
              // 列表项数量为房间数组长度
              itemCount: _rooms.length,
              // proxyDecorator 用于自定义拖拽时的视觉效果
              proxyDecorator: (child, index, animation) {
                return child;
              },
              // 处理重新排序的回调
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  // 由于移除项后列表长度减1，需要调整新位置的索引
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  // 移除原位置的房间并插入到新位置
                  final room = _rooms.removeAt(oldIndex);
                  _rooms.insert(newIndex, room);
                });
              },
              // 构建列表项
              itemBuilder: (context, index) {
                final room = _rooms[index];
                return Padding(
                  key: ValueKey(room.id), // 将key提升到Padding层级
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: _RoomReorderItem(room: room, index: index),
                );
              },
            ),
          ),
        ),

        // 底部按钮
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('取消'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () => widget.onReorder(_rooms),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('确认'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoomReorderItem extends StatefulWidget {
  final Room room;
  final int index;

  const _RoomReorderItem({Key? key, required this.room, required this.index})
    : super(key: key);

  @override
  _RoomReorderItemState createState() => _RoomReorderItemState();
}

class _RoomReorderItemState extends State<_RoomReorderItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ReorderableDragStartListener(
      index: widget.index,
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            _isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // 保持原有背景色，仅通过边框变化表示悬停状态
            color:
                (theme.brightness == Brightness.light)
                    ? colorScheme.surfaceVariant.withOpacity(1.0)
                    : colorScheme.surfaceVariant.withOpacity(1.0),
            border: Border.all(
              // 仅在悬停时显示边框
              color: _isHovered ? colorScheme.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              title: Text(
                widget.room.name,
                style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
              ),
              subtitle: Text(
                widget.room.encrypted ? '加密房间' : '开放房间',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
