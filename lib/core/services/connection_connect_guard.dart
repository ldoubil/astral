import 'dart:io';

import 'package:astral/core/services/service_manager.dart';
import 'package:astral/features/home/widgets/connect_npcap_guard.dart';

/// 连接前置检查失败原因（用于提示，避免多种原因共用一条误导文案）
enum ConnectTargetIssue {
  /// 未选择房间
  noRoom,

  /// 全局服务器列表为空，且房间也没有内置服务器
  noServers,

  /// 已有全局服务器，但全部未启用，且房间没有内置服务器
  noneEnabled,
}

/// 连接前置检查（无 UI）
abstract final class ConnectionConnectGuard {
  static ConnectTargetIssue? connectTargetIssue() {
    final services = ServiceManager();
    final room = services.roomState.selectedRoom.value;
    if (room == null) return ConnectTargetIssue.noRoom;

    if (room.servers.isNotEmpty) return null;

    final servers = services.serverState.servers.value;
    if (servers.isEmpty) return ConnectTargetIssue.noServers;
    if (servers.every((s) => !s.enable)) return ConnectTargetIssue.noneEnabled;
    return null;
  }

  static bool hasConnectTarget() => connectTargetIssue() == null;

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
