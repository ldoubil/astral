import 'package:astral/k/app_s/aps.dart1';
import 'package:astral/widgets/home_box.dart';
import 'package:astral/widgets/canvas_jump.dart';
import 'package:astral/k/models/room.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

class UserIpBox extends StatefulWidget {
  const UserIpBox({super.key});

  @override
  State<UserIpBox> createState() => _UserIpBoxState();
}

class _UserIpBoxState extends State<UserIpBox> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _virtualIPController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();

  final FocusNode _usernameControllerFocusNode = FocusNode();
  final FocusNode _virtualIPFocusNode = FocusNode();

  final Aps _aps = Aps();
  bool _isValidIP = true;

  bool _isValidIPv4(String ip) {
    // 检查是否包含子网掩码格式
    final parts = ip.split('/');
    if (parts.length > 2) return false;

    // 验证IP地址部分
    final ipPart = parts[0];
    if (ipPart.isEmpty) return false;

    // 优化IP地址验证逻辑
    final octets = ipPart.split('.');
    if (octets.length != 4) return false;

    for (final octet in octets) {
      try {
        final value = int.parse(octet);
        if (value < 0 || value > 255) return false;
      } catch (e) {
        return false;
      }
    }

    // 如果包含子网掩码，验证子网掩码部分
    if (parts.length == 2) {
      final maskPart = parts[1];
      if (maskPart.isEmpty) return false;

      try {
        final mask = int.parse(maskPart);
        if (mask < 0 || mask > 32) return false;
      } catch (e) {
        return false;
      }
    }

    return true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 初始化时同步一次状态
      effect(() {
        // 只在控件没有焦点时才更新，避免与用户输入冲突
        if (!_usernameControllerFocusNode.hasFocus) {
          _usernameController.text = _aps.PlayerName.value; // 监听玩家名变化
        }
        if (!_virtualIPFocusNode.hasFocus) {
          final newIP = _aps.ipv4.value;
          _virtualIPController.text = newIP; // 监听IP地址变化
          // 同时更新验证状态
          setState(() {
            _isValidIP = _isValidIPv4(newIP);
          });
        }
        // 房间选择器不是文本输入框，可以直接更新
        _roomController.text = _aps.selectroom.value?.name ?? ''; // 监听房间选择变化
      });

      // 初始化验证状态
      setState(() {
        _isValidIP = _isValidIPv4(_virtualIPController.text);
      });
    });
  }

  @override
  void dispose() {
    // 清理监听器
    _usernameController.dispose();
    _virtualIPController.dispose();
    _usernameControllerFocusNode.dispose();
    _virtualIPFocusNode.dispose();
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
              const Spacer(),
              if (Aps().Connec_state.watch(context) != CoState.idle)
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
            enabled:
                (Aps().Connec_state.watch(context) != CoState.idle)
                    ? false
                    : true,
            onChanged: (value) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _aps.updatePlayerName(value);
              });
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
                Aps().Connec_state.watch(context) != CoState.connected
                    ? () => CanvasJump.show(
                      context,
                      rooms: _aps.rooms.watch(context).cast<Room>(),
                      onSelect: (Room room) {
                        _aps.setRoom(room);
                      },
                    )
                    : null,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: LocaleKeys.select_room.tr(),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                enabled: Aps().Connec_state.watch(context) == CoState.idle,
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.apartment, color: colorScheme.primary),
                suffixIcon: Icon(Icons.menu, color: colorScheme.primary),
              ),
              child: IgnorePointer(
                ignoring:
                    Aps().Connec_state.watch(context) == CoState.connected,
                child: Text(
                  Aps().selectroom.watch(context)?.name ?? LocaleKeys.select_room_hint.tr(),
                  style: TextStyle(
                    color:
                        Aps().Connec_state.watch(context) != CoState.connected
                            ? Theme.of(context).textTheme.bodyLarge?.color
                            : Theme.of(context).disabledColor,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 9),

          SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _virtualIPController,
                    focusNode: _virtualIPFocusNode,
                    enabled:
                        !_aps.dhcp.watch(context) &&
                        (Aps().Connec_state.watch(context) == CoState.idle),
                    onChanged: (value) {
                      if (!_aps.dhcp.watch(context)) {
                        // 实时更新IPv4值并立即验证
                        _aps.updateIpv4(value);
                        setState(() {
                          _isValidIP = _isValidIPv4(value);
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: LocaleKeys.virtual_network_ip.tr(),
                      // 添加提示文本
                      hintText: LocaleKeys.virtual_network_ip_hint.tr(),
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lan, color: colorScheme.primary),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 12,
                      ),
                      errorText:
                          (!_aps.dhcp.watch(context) && !_isValidIP)
                              ? LocaleKeys.invalid_ipv4_error.tr()
                              : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Switch(
                      value: _aps.dhcp.watch(context),
                      onChanged: (value) {
                        if (Aps().Connec_state.watch(context) == CoState.idle) {
                          _aps.updateDhcp(value);
                        }
                      },
                    ),
                    Text(
                      _aps.dhcp.watch(context) ? LocaleKeys.automatic.tr() : LocaleKeys.manual.tr(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_aps.dhcp.watch(context))
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(LocaleKeys.auto_assign_ip_notice.tr(), style: const TextStyle(fontSize: 12)),
            )
          else
            const SizedBox(height: 12),
        ],
      ),
    );
  }
}
