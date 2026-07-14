import 'package:astral/core/states/server_status_state.dart';
import 'package:flutter/material.dart';

/// 服务器状态指示色（首页卡片 / 服务器页共用）
class ServerStatusStyle {
  const ServerStatusStyle._();

  static Color color(ServerStatus status, ColorScheme colorScheme) {
    switch (status) {
      case ServerStatus.online:
        return Colors.green;
      case ServerStatus.offline:
        return Colors.red;
      case ServerStatus.inUse:
        return Colors.blue;
      case ServerStatus.unknown:
        return colorScheme.outline;
    }
  }
}
