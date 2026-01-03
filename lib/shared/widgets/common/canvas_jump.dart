import 'dart:async';
import 'package:flutter/material.dart';
import 'package:astral/core/models/room.dart';

class CanvasJump {
  static void show(BuildContext context, {required List<Room> rooms, required Function(Room) onSelect}) {
    showDialog(
      context: context,
      builder: (context) => _CanvasDialog(rooms: rooms, onSelect: onSelect),
    );
  }
}

// 弹窗状态管理私有类
class _CanvasDialog extends StatefulWidget {
  final List<Room> rooms;
  final Function(Room) onSelect;

  const _CanvasDialog({required this.rooms, required this.onSelect});

  @override
  State<_CanvasDialog> createState() => _CanvasDialogState();
}

class _CanvasDialogState extends State<_CanvasDialog> {
  late List<Room> _filteredRooms;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isScrolling = false;
  Timer? _scrollTimer;
  String _currentHoveredRoomName = '';

  @override
  void initState() {
    super.initState();
    _filteredRooms = widget.rooms;
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_isScrolling) {
      setState(() {
        _isScrolling = true;
      });
    }
    _scrollTimer?.cancel();
    _scrollTimer = Timer(Duration(milliseconds: 300), () {
      setState(() {
        _isScrolling = false;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _scrollTimer?.cancel();
    super.dispose();
  }

  void _filterRooms(String query) {
    setState(() {
      _filteredRooms = widget.rooms.where((room) => 
        room.name.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return AlertDialog(
      titlePadding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actionsPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: _buildTitle(colorScheme),
      content: SizedBox(
        width: screenSize.width / 1.2,
        height: (screenSize.height / 2) + 12, 
        child: Column(
          children: [
            _buildSearchField(colorScheme),
            Expanded(
              flex: 115, 
              child: _buildRoomList(colorScheme),
            ),
          ],
        ),
      ),
      actions: [
        _buildCancelButton(colorScheme),
      ],
    );
  }

  // 构建标题组件
  Widget _buildTitle(ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(Icons.meeting_room, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text('选择房间', style: TextStyle(fontSize: 18, color: colorScheme.primary)),
      ],
    );
  }

  // 构建搜索框
  Widget _buildSearchField(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索房间',
          prefixIcon: Icon(Icons.search, size: 24),
          border: OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: _filterRooms,
      ),
    );
  }

  // 构建房间列表
  Widget _buildRoomList(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Material(
              borderRadius: BorderRadius.circular(16), 
              color: Colors.transparent,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedOpacity(
                      opacity: _isScrolling ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 200),
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        trackVisibility: false,
                        thickness: 11,
                        radius: const Radius.circular(16),
                        interactive: true,
                        child: SizedBox.expand(),
                      ),
                    ),
                  ),
                  ListView.builder(
                    controller: _scrollController,
                    itemCount: _filteredRooms.length,
                    itemBuilder: (context, index) {
                      final room = _filteredRooms[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: MouseRegion(
                          onEnter: (_) {
                            setState(() {
                              _currentHoveredRoomName = room.name;
                            });
                          },
                          onExit: (_) {
                            setState(() {
                              _currentHoveredRoomName = '';
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: _currentHoveredRoomName == room.name
                                  ? colorScheme.primaryContainer.withOpacity(0.12)
                                  : (Theme.of(context).brightness == Brightness.light)
                                    ? colorScheme.surfaceVariant.withOpacity(0.95) 
                                    : colorScheme.surfaceVariant.withOpacity(0.15),
                              // 添加边框效果
                              border: Border.all(
                                color: _currentHoveredRoomName == room.name
                                    ? colorScheme.primary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                widget.onSelect(room);
                                Navigator.pop(context);
                              },
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                title: Text(room.name, style: TextStyle(fontSize: 16, color: colorScheme.onSurface)),
                                subtitle: Text(room.encrypted ? '加密房间' : '开放房间', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                                trailing: Icon(Icons.chevron_right, color: colorScheme.primary.withAlpha(150)),
                              ),
                            ),
                          ),
                        )
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建取消按钮
  Widget _buildCancelButton(ColorScheme colorScheme) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text('取消', 
        style: TextStyle(fontSize: 16, color: colorScheme.primary)
      ),
    ); 
  }
}