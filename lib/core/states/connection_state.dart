import 'package:astral/src/rust/api/simple.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 连接状态
enum CoState { idle, connecting, connected }

class ConnectionState {
  // 连接状态
  final connectionState = signal(CoState.idle);

  // 是否正在连接
  final isConnecting = signal(false);

  // 网络状态
  final netStatus = signal<KVNetworkStatus?>(null);
}
