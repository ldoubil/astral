import 'package:astral/utils/random_name.dart';
import 'package:astral/utils/show_add_room_dialog.dart';
import 'package:astral/utils/show_edit_room_dialog.dart';
import 'package:astral/utils/room_share_helper.dart';
import 'package:astral/screens/user_page.dart';
import 'package:astral/widgets/room_card.dart';
import 'package:astral/widgets/room_reorder_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:astral/k/services/service_manager.dart';
import 'package:astral/k/models/room.dart';
import 'package:uuid/uuid.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

// 在_RoomPageState类中添加排序相关方法
class _RoomPageState extends State<RoomPage> {
  final _services = ServiceManager();
  bool isHovered = false;
  bool _isReorderMode = false; // 添加重排序模式标志

  // 根据宽度计算列数
  int _getColumnCount(double width) {
    if (width >= 1200) {
      return 4;
    } else if (width >= 900) {
      return 3;
    } else if (width >= 600) {
      return 2;
    }
    return 1;
  }

  // 显示输入分享码的弹窗
  void _showPasteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String shareCode = '';
        return AlertDialog(
          title: const Text('导入房间'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  shareCode = value;
                },
                decoration: const InputDecoration(
                  hintText: '请输入分享码或链接',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await RoomShareHelper.importFromClipboard(context);
                  },
                  icon: const Icon(Icons.paste),
                  label: const Text('从剪贴板导入'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                if (shareCode.isNotEmpty) {
                  Navigator.of(context).pop();
                  await RoomShareHelper.importRoom(context, shareCode);
                }
              },
              child: const Text('导入'),
            ),
          ],
        );
      },
    );
  }

  // 构建房间列表视图
  Widget _buildRoomsView(BuildContext context, BoxConstraints constraints) {
    final columnCount = _getColumnCount(constraints.maxWidth);
    final rooms = _services.roomState.rooms.value;
    final selectedRoom = _services.roomState.selectedRoom.value;

    // 如果是重排序模式，使用ReorderableListView
    if (_isReorderMode) {
      return ReorderableListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: rooms.length,
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final List<Room> reorderedRooms = List.from(rooms);
          final Room item = reorderedRooms.removeAt(oldIndex);
          reorderedRooms.insert(newIndex, item);
          _services.room.reorderRooms(reorderedRooms);
        },
        itemBuilder: (context, index) {
          final room = rooms[index];
          return Card(
            key: ValueKey(room.id),
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.drag_handle),
              title: Text(room.name),
              subtitle: Text('排序: ${room.sortOrder}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  showEditRoomDialog(context, room: room);
                },
              ),
            ),
          );
        },
      );
    }

    // 正常的网格视图
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: columnCount,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              final isSelected = selectedRoom?.id == room.id;
              return RoomCard(
                room: room,
                isSelected: isSelected,
                onEdit: () {
                  showEditRoomDialog(context, room: room);
                },
                onDelete: () {
                  _services.room.deleteRoom(room.id);
                },
                onShare: () {
                  RoomShareHelper.showShareDialog(context, room);
                },
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 监听连接状态
    final isConnected = _services.connectionState.connectionState.value;
    // 获取当前选中房间（如无此逻辑请替换为你的实际选中房间变量）
    final selectedRoom =
        _services.roomState.selectedRoom.value; // 假设有 selectedRoom 字段

    return Scaffold(
      body: Column(
        children: [
          // 顶部显示当前选中房间信息
          if (selectedRoom != null && isConnected == CoState.connected)
            MouseRegion(
              onEnter: (_) => setState(() => isHovered = true),
              onExit: (_) => setState(() => isHovered = false),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: Card(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color:
                          isHovered
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: double.infinity,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap:
                            isConnected == CoState.connected
                                ? () {
                                  RoomShareHelper.copyShareLink(
                                    context,
                                    selectedRoom,
                                    linkOnly: true,
                                  );
                                }
                                : () {},
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Text('当前房间: ${selectedRoom.name}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '连接状态: ${isConnected == CoState.connected
                                    ? '已连接'
                                    : isConnected == CoState.connecting
                                    ? '连接中'
                                    : '未连接'}${isConnected == CoState.connected ? ' (点击分享房间)' : ''}',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child:
                isConnected != CoState.idle
                    // 已连接：显示用户列表
                    ? const UserPage()
                    // 未连接：显示房间列表
                    : LayoutBuilder(
                      builder: (context, constraints) {
                        return _buildRoomsView(context, constraints);
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton:
          isConnected != CoState.idle
              ? null // 已连接时不显示按钮
              : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 排序按钮移到最前
                  FloatingActionButton(
                    heroTag: 'room_sort',
                    onPressed: () {
                      RoomReorderSheet.show(
                        context,
                        _services.roomState.rooms.value,
                      );
                    },
                    child: const Icon(Icons.sort),
                  ),
                  const SizedBox(width: 16),
                  // 黏贴按钮居中
                  FloatingActionButton(
                    heroTag: 'paste',
                    onPressed: _showPasteDialog,
                    child: const Icon(Icons.paste),
                  ),
                  const SizedBox(width: 16),
                  // 增加按钮最后
                  FloatingActionButton(
                    heroTag: 'add',
                    onPressed: () => showAddRoomDialog(context),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
    );
  }
}

void addEncryptedRoom(
  bool isEncrypted,
  String? name,
  String? roomname,
  String? password,
) {
  var room = Room(
    name: name ?? RandomName(), // 如果 name 为 null，则使用空字符串
    encrypted: isEncrypted,
    roomName:
        isEncrypted ? Uuid().v4() : (roomname ?? ""), // 如果未加密，则使用随机UUID作为房间名
    password: isEncrypted ? Uuid().v4() : (password ?? ""), // 如果未加密，则生成一个随机密码
    messageKey: isEncrypted ? Uuid().v4() : "",
    tags: [],
  );
  ServiceManager().room.addRoom(room);
}
