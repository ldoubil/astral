import 'package:astral/state/child/base_state.dart';
import 'package:astral/state/child/server_state.dart';
import 'package:astral/state/child/theme_state.dart';
enum CoState { idle, connecting, connected }
/// 应用状态管理类
/// 在基础状态之上提供单例与对外接口
class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;

  /// 私有构造：初始化基础状态
  AppState._internal();

  /// 基础状态管理实例
  final BaseState baseState = BaseState();

  /// 主题状态管理实例
  final ThemeState themeState = ThemeState();

  /// 服务器状态管理实例
  final ServerState serverState = ServerState();
}
