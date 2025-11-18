import 'package:astral/models/user_info.dart';

import '../../core/persistent_signal.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 连接状态枚举
enum RoomConnectionState {
  /// 空闲状态
  idle,

  /// 连接中
  connecting,

  /// 已连接
  connected,
}

/// 基础状态管理基类
/// 提供应用中通用的 UI 状态信号与初始化逻辑
class V2BaseState {
  /// 应用程序名称信号（持久化存储）
  late final PersistentSignal<String> Name;

  /// 房间连接状态信号
  /// 用于控制连接动画和UI状态
  final Signal<RoomConnectionState> roomConnectionState = signal(
    RoomConnectionState.idle,
  );

  /// 是否正在连接
  final Signal<bool> isConnecting = signal(false);

  /// 网络状态
  final Signal<KVNetworkStatus?> netStatus = signal(null);

  /// 自定义VPN网段
  final Signal<List<String>> customVpn = signal([]);

  /// 用户信息列表
  final Signal<List<UserInfo>> userInfo = signal([]);

  /// 监听列表（持久化存储）
  late final PersistentSignal<List<String>> listenListPersistent;

  /* ------------------------ 构造函数与初始化 ------------------------ */
  /// 构造函数：初始化基础状态与副作用监听
  V2BaseState() {
    _initPersistentSignals();
  }

  /// 初始化持久化信号
  /// 在构造函数中调用，确保所有持久化信号都被正确初始化
  void _initPersistentSignals() {
    // 初始化应用程序名称（持久化）
    Name = persistentSignal('V2_app_name', 'Astral Game');

    // 初始化监听列表（持久化）
    listenListPersistent = persistentSignal('V2_listen_list', []);
  }

  /* ------------------------ 连接状态管理方法 ------------------------ */

  /// 设置连接状态为连接中
  void setConnecting() {
    roomConnectionState.value = RoomConnectionState.connecting;
  }

  /// 设置连接状态为已连接
  void setConnected() {
    roomConnectionState.value = RoomConnectionState.connected;
  }

  /// 重置连接状态为空闲
  void resetConnectionState() {
    roomConnectionState.value = RoomConnectionState.idle;
  }
}
