import 'package:astral/src/rust/api/firewall.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:astral/state/app_state.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../core/persistent_signal.dart';

/// 基础状态管理基类
/// 提供应用中通用的 UI 状态信号与初始化逻辑
class BaseState {
  /* ------------------------ 普通信号（非持久化） ------------------------ */

  /// 当前页面信号
  final currentPage = signal('home');

  /// 玩家名称
  final Signal<String> PlayerName = signal('');

  /// 是否为桌面设备
  final Signal<bool> isDesktop = signal(false);

  /// 鼠标悬停索引
  final Signal<int?> hoveredIndex = signal(null);

  /// 当前选中的导航项索引
  final Signal<int> selectedIndex = signal(0);

  /// IPv6地址
  final Signal<String> ipv6 = signal('');

  /// 最新版本号
  final Signal<String?> latestVersion = signal(null);

  /// 日志内容
  final Signal<List<String>> logs = signal([]);

  /// 自定义vpn网段
  final Signal<List<String>> customVpn = signal([]);

  /// 网络状态
  final Signal<KVNetworkStatus?> netStatus = signal(null);

  /// 是否正在连接
  final Signal<bool> isConnecting = signal(false);

  /// 排序选项（0: 不排序, 1: 按延迟排序, 2: 按用户名长度排序）
  final Signal<int> sortOption = signal(0);

  /// 添加排序顺序状态
  final Signal<int> sortOrder = signal(0); // 0: 升序, 1: 降序

  /// 添加显示模式状态
  final Signal<int> displayMode = signal(0); // 0: 默认, 1: 仅用户, 2: 仅服务器

  final Signal<CoState> Connec_state = signal(CoState.idle);

  ///防火墙状态 只要有一个没有关闭就是false
  final Signal<bool> firewallStatus = signal(false);
  
  // 设置防火墙状态
  Future<void> setFirewall(bool value) async {
    firewallStatus.value = value;
    await setFirewallStatus(profileIndex: 1, enable: value);
    await setFirewallStatus(profileIndex: 2, enable: value);
    await setFirewallStatus(profileIndex: 3, enable: value);
  }
  /* ------------------------ 持久化信号 ------------------------ */

  /// 应用程序名称信号（持久化存储）
  late final PersistentSignal<String> appName;

  /// 屏幕分割宽度（持久化存储，用于区分手机/桌面布局）
  late final PersistentSignal<double> screenSplitWidth;

  /// 当前选中的语言信号（持久化存储）
  late final PersistentSignal<String> currentLanguage;

  /// 监听列表（持久化存储）
  late final PersistentSignal<List<String>> listenListPersistent;

  /* ------------------------ 构造函数与初始化 ------------------------ */

  /// 构造函数：初始化基础状态与副作用监听
  BaseState() {
    _initPersistentSignals();
    _init();
  }

  /// 初始化持久化信号
  /// 在构造函数中调用，确保所有持久化信号都被正确初始化
  void _initPersistentSignals() {
    // 初始化应用程序名称（持久化）
    appName = persistentSignal('app_name', 'Astral Game');

    // 初始化屏幕分割宽度（持久化）
    screenSplitWidth = persistentSignal('screen_split_width', 480.0);

    // 初始化当前语言（持久化）
    currentLanguage = persistentSignal('current_language', 'zh');

    // 初始化监听列表（持久化）
    listenListPersistent = persistentSignal('listen_list', []);
  }

  /// 初始化状态与副作用
  /// - 根据 screenSplitWidth 自动计算 isDesktop
  void _init() {
    effect(() {
      isDesktop.value = screenSplitWidth.value > 480;
    });
  }

  /* ------------------------ 公共方法 ------------------------ */

  /// 更新屏幕分割宽度
  /// 调用此方法可动态调整 screenSplitWidth 的值
  void updateScreenSplitWidth(double width) {
    screenSplitWidth.value = width;
  }
}
