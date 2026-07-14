import 'dart:io';

import 'package:astral/core/services/service_manager.dart';
import 'package:astral/features/home/widgets/connect_npcap_guard.dart';

/// 连接前置检查（无 UI）
abstract final class ConnectionConnectGuard {
  static bool hasConnectTarget() {
    final services = ServiceManager();
    final room = services.roomState.selectedRoom.value;
    if (room == null) return false;

    final enabledServers =
        services.serverState.servers.value.where((s) => s.enable).toList();
    return enabledServers.isNotEmpty || room.servers.isNotEmpty;
  }

  static Future<bool> isNpcapReady() async {
    if (!Platform.isWindows) return true;

    final services = ServiceManager();
    final room = services.roomState.selectedRoom.value;
    if (room == null) return true;

    final enabledServers =
        services.serverState.servers.value.where((s) => s.enable).toList();
    if (!containsFaketcp(room, enabledServers)) return true;

    return hasNpcapDriver();
  }

  /// 启动时自动连接（静默，无 SnackBar / 对话框）
  static Future<void> tryStartupAutoConnect() async {
    if (!ServiceManager().startupState.startupAutoConnect.value) return;
    if (!hasConnectTarget()) return;
    if (!await isNpcapReady()) return;

    await ServiceManager().connection.connect(isManual: false);
  }

  /// 手动连接前置检查（不含 UI）
  static Future<bool> canManualConnect() async {
    if (!hasConnectTarget()) return false;
    return isNpcapReady();
  }
}
