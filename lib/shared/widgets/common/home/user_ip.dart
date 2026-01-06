import 'package:astral/core/services/service_manager.dart';
import 'package:astral/shared/widgets/common/home_box.dart';
import 'package:astral/core/constants/rooms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:signals_flutter/signals_flutter.dart';

class UserIpBox extends StatefulWidget {
  const UserIpBox({super.key});

  @override
  State<UserIpBox> createState() => _UserIpBoxState();
}

class _UserIpBoxState extends State<UserIpBox> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();

  final FocusNode _usernameControllerFocusNode = FocusNode();

  final _services = ServiceManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 初始化时同步一次状态
      _usernameController.text = _services.playerState.playerName.value;
      final roomConfig = _services.roomState.selectedRoom;
      _roomController.text = roomConfig.name;

      // 强制开启DHCP
      if (!_services.networkConfigState.dhcp.value) {
        _services.networkConfig.updateDhcp(true);
      }
    });
  }

  @override
  void dispose() {
    // 清理监听器
    _usernameController.dispose();
    _usernameControllerFocusNode.dispose();
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    return Watch((context) {
      final connectionState = ServiceManager().connectionState.connectionState
          .watch(context);
      final selectedRoomIndex = ServiceManager().roomState.selectedRoomIndex
          .watch(context);
      final selectedRoom = RoomsConstants.getRoomByIndex(selectedRoomIndex);
      final rooms = RoomsConstants.rooms;

      return HomeBox(
        widthSpan: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: colorScheme.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  LocaleKeys.user_info.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                if (connectionState != CoState.idle)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      LocaleKeys.locked.tr(),
                      style: TextStyle(
                        color: colorScheme.onSecondaryContainer,
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _usernameController,
              focusNode: _usernameControllerFocusNode,
              enabled: (connectionState != CoState.idle) ? false : true,
              onChanged: (value) {
                // 调用Service层方法，同时更新State和持久化
                _services.appSettings.updatePlayerName(value);
              },
              decoration: InputDecoration(
                labelText: LocaleKeys.username.tr(),
                hintText: LocaleKeys.username_hint.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: colorScheme.primary),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
              ),
            ),

            const SizedBox(height: 14),
            InkWell(
              onTap:
                  connectionState == CoState.idle
                      ? () => _showRoomPicker(context, rooms, selectedRoomIndex)
                      : null,
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: LocaleKeys.select_room.tr(),
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.apartment, color: colorScheme.primary),
                  suffixIcon: Icon(
                    Icons.arrow_drop_down,
                    color:
                        connectionState == CoState.idle
                            ? colorScheme.primary
                            : colorScheme.onSurface.withOpacity(0.38),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  enabled: connectionState == CoState.idle,
                ),
                child: Text(
                  selectedRoom.name,
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        connectionState == CoState.idle
                            ? colorScheme.onSurface
                            : colorScheme.onSurface.withOpacity(0.38),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),
          ],
        ),
      );
    });
  }

  // 显示自定义房间选择器
  void _showRoomPicker(
    BuildContext context,
    List<RoomConfig> rooms,
    int currentIndex,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.apartment,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      LocaleKeys.select_room.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16),
              // 房间列表
              ...List.generate(rooms.length, (index) {
                final room = rooms[index];
                final isSelected = currentIndex == index;
                return ListTile(
                  leading: Icon(
                    Icons.room,
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  title: Text(
                    room.name,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                    ),
                  ),
                  trailing:
                      isSelected
                          ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                          : null,
                  onTap: () {
                    _services.room.selectRoomByIndex(index);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
