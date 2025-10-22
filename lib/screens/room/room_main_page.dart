import 'package:flutter/material.dart';
import 'package:astral/state/child/room_state.dart';
import 'package:astral/models/room_config.dart';
import 'package:astral/screens/room/room_config_form_page.dart';
import 'package:signals_flutter/signals_flutter.dart';

class RoomMainPage extends StatefulWidget {
  const RoomMainPage({super.key});

  @override
  State<RoomMainPage> createState() => _RoomMainPageState();
}

class _RoomMainPageState extends State<RoomMainPage> {
  final RoomState _roomState = RoomState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Watch((context) {
        final roomConfigs = _roomState.roomConfig.value;

        if (roomConfigs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.meeting_room_outlined,
                  size: 64,
                  color: colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  '暂无房间配置',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '点击右下角按钮添加房间配置',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: roomConfigs.length,
          itemBuilder: (context, index) {
            final roomConfig = roomConfigs[index];
            return _buildRoomConfigCard(roomConfig, index);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToRoomConfigForm(),
        tooltip: '添加房间配置',
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// 构建房间配置卡片
  Widget _buildRoomConfigCard(RoomConfig roomConfig, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.1), width: 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Row(
          children: [
            Expanded(
              child: Text(
                roomConfig.room_name.isNotEmpty
                    ? roomConfig.room_name
                    : '未命名房间',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (roomConfig.room_desc.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                roomConfig.room_desc,
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
              const SizedBox(height: 8),
            ] else
              const SizedBox(height: 4),

            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.dns,
                  size: 12,
                  color: colorScheme.primary.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  '服务器: ${roomConfig.server.length} 个',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: colorScheme.primary.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  '创建: ${_formatDateTime(roomConfig.create_time)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _navigateToRoomConfigForm(roomConfig: roomConfig, index: index);
                break;
              case 'delete':
                _deleteRoomConfig(index);
                break;
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '编辑',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: colorScheme.error),
                      const SizedBox(width: 8),
                      Text('删除', style: TextStyle(color: colorScheme.error)),
                    ],
                  ),
                ),
              ],
        ),
        isThreeLine: true,
      ),
    );
  }

  /// 导航到房间配置表单页面
  Future<void> _navigateToRoomConfigForm({
    RoomConfig? roomConfig,
    int? index,
  }) async {
    final result = await Navigator.push<RoomConfig>(
      context,
      MaterialPageRoute(
        builder:
            (context) => RoomConfigFormPage(
              roomConfig: roomConfig,
              isEditing: roomConfig != null,
            ),
      ),
    );

    if (result != null) {
      if (index != null) {
        // 编辑现有配置
        _updateRoomConfig(index, result);
      } else {
        // 添加新配置
        _addRoomConfig(result);
      }
    }
  }

  /// 添加房间配置
  void _addRoomConfig(RoomConfig roomConfig) {
    final currentList = List<RoomConfig>.from(_roomState.roomConfig.value);
    currentList.add(roomConfig);
    _roomState.roomConfig.value = currentList;
  }

  /// 更新房间配置
  void _updateRoomConfig(int index, RoomConfig roomConfig) {
    final currentList = List<RoomConfig>.from(_roomState.roomConfig.value);
    currentList[index] = roomConfig;
    _roomState.roomConfig.value = currentList;
  }

  /// 删除房间配置
  void _deleteRoomConfig(int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              '确认删除',
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              '确定要删除这个房间配置吗？此操作不可撤销。',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.8)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onSurface.withOpacity(0.6),
                ),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  final currentConfigs = List<RoomConfig>.from(
                    _roomState.roomConfig.value,
                  );
                  currentConfigs.removeAt(index);
                  _roomState.roomConfig.value = currentConfigs;

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('房间配置删除成功'),
                      backgroundColor: colorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('删除'),
              ),
            ],
          ),
    );
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
