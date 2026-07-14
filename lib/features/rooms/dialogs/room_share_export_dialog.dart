import 'package:flutter/material.dart';
import 'package:astral/core/models/room.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/features/rooms/dialogs/room_share_copy_link.dart';
import 'package:astral/features/rooms/dialogs/room_share_export_body.dart';

/// 房间分享导出对话框与相关 UI
class RoomShareExportDialogs {
  /// 复制房间分享链接到剪贴板
  ///
  /// [linkOnly] 是否只复制链接（不包含说明文字）
  static Future<void> copyShareLink(
    BuildContext context,
    Room room, {
    bool linkOnly = false,
  }) => copyRoomShareLink(context, room, linkOnly: linkOnly);

  /// 显示房间分享对话框
  /// 支持选择是否携带服务器列表和网络配置
  static Future<void> showShareDialog(BuildContext context, Room room) async {
    final selectedServers = <String>[];

    final networkConfigOptions = <String, bool>{
      'dhcp': false,
      'defaultProtocol': false,
      'enableEncryption': false,
      'latencyFirst': false,
      'disableP2p': false,
      'disableUdpHolePunching': false,
      'disableTcpHolePunching': false,
      'disableSymHolePunching': false,
      'dataCompressAlgo': false,
      'enableKcpProxy': false,
      'bindDevice': false,
      'noTun': false,
    };

    final allServers = await ServiceManager().server.getAllServers();
    final enabledServers = allServers.where((s) => s.enable).toList();
    final enabledServerUrls =
        enabledServers.expand((s) {
          final urls = <String>[];
          if (s.tcp) urls.add('tcp://${s.url}');
          if (s.faketcp) urls.add('faketcp://${s.url}');
          if (s.udp) urls.add('udp://${s.url}');
          if (s.ws) urls.add('ws://${s.url}');
          if (s.wss) urls.add('wss://${s.url}');
          if (s.quic) urls.add('quic://${s.url}');
          if (s.wg) urls.add('wg://${s.url}');
          if (s.txt) urls.add('txt://${s.url}');
          if (s.srv) urls.add('srv://${s.url}');
          if (s.http) urls.add('http://${s.url}');
          if (s.https) urls.add('https://${s.url}');
          return urls;
        }).toList();

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final share = buildRoomToShare(
              room: room,
              selectedServers: selectedServers,
              networkConfigOptions: networkConfigOptions,
            );
            final colorScheme = Theme.of(context).colorScheme;

            return buildRoomShareExportDialogBody(
              context: context,
              room: room,
              roomToShare: share.roomToShare,
              selectedServers: selectedServers,
              networkConfigOptions: networkConfigOptions,
              enabledServerUrls: enabledServerUrls,
              hasServers: share.hasServers,
              hasNetworkConfig: share.hasNetworkConfig,
              setState: setState,
              colorScheme: colorScheme,
            );
          },
        );
      },
    );
  }
}
