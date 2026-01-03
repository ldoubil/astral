import 'dart:io';
import 'dart:async';
import 'package:flutter/widgets.dart';

import 'package:astral/utils/random_name.dart';
import 'package:astral/k/models/net_config.dart';
import 'package:astral/k/models/room.dart';
import 'package:astral/k/models/server_mod.dart';
import 'package:astral/src/rust/api/firewall.dart';
import 'package:astral/src/rust/api/hops.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:astral/k/database/app_data.dart';
import 'package:uuid/uuid.dart';
export 'package:signals_flutter/signals_flutter.dart';

enum CoState { idle, connecting, connected }

class NetAstral {
  // peer_id
  final String peerId;
  // 网络名称
  final String netName;
  // net6
  final String net6;
  // 发送时间戳
  final String sendTimeStamp;

  // 初始化
  NetAstral({
    this.peerId = "",
    this.netName = '',
    this.net6 = '',
    this.sendTimeStamp = '',
  });
}

/// 全局状态管理类
class Aps {
  // 静态单例实例
  static Aps? _instance;

  // 工厂构造函数，用于获取单例实例
  factory Aps() {
    _instance ??= Aps._internal();
    return _instance!;
  }

  Aps._internal() {
    _initThemeSettings();
    updateNetConfig();
    initMisc();
    loadStartupSettings();
  }

  // 在类中混入WidgetsBindingObserver
  void Function()? _setState;
  void setState(VoidCallback fn) {
    if (_setState != null) {
      _setState!();
    } else {
      fn();
    }
  }

  bool get mounted => true; // 添加mounted属性模拟

  // 初始化主题设置
  Future<void> _initThemeSettings() async {
    final database = AppDatabase();
    themeMode.value = await database.themeSettings.getThemeMode();
    themeColor.value = Color(await database.themeSettings.getThemeColor());
    // 初始化语言设置，默认为中文

    currentLanguage.value = 'zh';
  }

  // 杂项初始化
  // 在initMisc方法中修改房间加载逻辑
  Future<void> initMisc() async {
    // 获取房间时按排序字段排序
    var roomsList = await AppDatabase().RoomSetting.getAllRooms();
    roomsList.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    rooms.value = roomsList;

    if (rooms.value.isEmpty) {
      final s = Room(
        name: RandomName(),
        encrypted: true,
        roomName: Uuid().v4(),
        password: Uuid().v4(),
        tags: [],
        sortOrder: 0, // 添加排序字段
      );
      await addRoom(s);
      // 并且 selectroom 如果没有选中任何一个房间 就选中第一个
      if (await AppDatabase().AllSettings.getRoom() == null) {
        await AppDatabase().AllSettings.updateRoom(s);
      }
    }
    selectroom.value = await AppDatabase().AllSettings.getRoom();
    PlayerName.value = await AppDatabase().AllSettings.getPlayerName();
    listenList.value = await AppDatabase().AllSettings.getListenList();
    servers.value = await AppDatabase().ServerSetting.getAllServers();

    userListSimple.value = await AppDatabase().AllSettings.getUserMinimal();
    sortOption.value = await AppDatabase().AllSettings.getSortOption();
    sortOrder.value = await AppDatabase().AllSettings.getSortOrder();
    displayMode.value = await AppDatabase().AllSettings.getDisplayMode();
    closeMinimize.value = await AppDatabase().AllSettings.getCloseMinimize();
    customVpn.value = await AppDatabase().AllSettings.getCustomVpn();
    beta.value = await AppDatabase().AllSettings.getBeta();
    autoCheckUpdate.value =
        await AppDatabase().AllSettings.getAutoCheckUpdate();
    downloadAccelerate.value =
        await AppDatabase().AllSettings.getDownloadAccelerate();
    enableBannerCarousel.value =
        await AppDatabase().AllSettings.getEnableBannerCarousel();
    // window平台
    if (Platform.isWindows) {
      updateFirewallStatus();
      autoSetMTU.value = await AppDatabase().AllSettings.getAutoSetMTU();
      Aps().updateConnections();
    }

    // 初始化最新版本号
    latestVersion.value = await AppDatabase().AllSettings.getLatestVersion();
  }

  // ConnectionManager
  final Signal<List<ConnectionManager>> connections = signal([]);

  // 更新连接管理器列表
  Future<void> updateConnections() async {
    connections.value =
        await AppDatabase().netConfigSetting.getConnectionManagers();
  }

  // 添加连接管理器
  Future<void> addConnection(ConnectionManager manager) async {
    await AppDatabase().netConfigSetting.addConnectionManager(manager);
    await updateConnections();
  }

  // 更新连接管理器
  Future<void> updateConnection(int index, ConnectionManager manager) async {
    await AppDatabase().netConfigSetting.updateConnectionManager(
      index,
      manager,
    );
    await updateConnections();
  }

  // 删除连接管理器
  Future<void> removeConnection(int index) async {
    await AppDatabase().netConfigSetting.removeConnectionManager(index);
    await updateConnections();
  }

  // 更新连接管理器启用状态
  Future<void> updateConnectionEnabled(int index, bool enabled) async {
    await AppDatabase().netConfigSetting.updateConnectionManagerEnabled(
      index,
      enabled,
    );
    await updateConnections();
  }

  // 日志内容
  final Signal<List<String>> logs = signal([]);
  // 开机自启动
  final Signal<KVNetworkStatus?> netStatus = signal(null); // 网络状态
  /// 更新玩家名称
  Future<void> updatePlayerName(String name) async {
    PlayerName.value = name;
    await AppDatabase().AllSettings.setPlayerName(name);
  }

  /// PLAYERname
  final Signal<String> PlayerName = signal(''); // 玩家名称

  /// listenList
  final Signal<List<String>> listenList = signal([]); // 房间列表

  /// userListSimple
  final Signal<bool> userListSimple = signal(false); // 玩家列表

  /// 添加排序选项状态
  final Signal<int> sortOption = signal(0); // 0: 不排序, 1: 按延迟排序, 2: 按用户名长度排序

  /// 启用轮播图
  final Signal<bool> enableBannerCarousel = signal(true);

  /// 更新轮播图开关
  Future<void> updateEnableBannerCarousel(bool enable) async {
    enableBannerCarousel.value = enable;
    await AppDatabase().AllSettings.setEnableBannerCarousel(enable);
  }

  /// 是否已显示轮播图提示
  final Signal<bool> hasShownBannerTip = signal(false);

  /// 更新轮播图提示标记
  Future<void> updateHasShownBannerTip(bool hasShown) async {
    hasShownBannerTip.value = hasShown;
    await AppDatabase().AllSettings.setHasShownBannerTip(hasShown);
  }

  /// 加载轮播图提示标记
  Future<void> loadHasShownBannerTip() async {
    hasShownBannerTip.value =
        await AppDatabase().AllSettings.getHasShownBannerTip();
  }

  /// 设置sortOption
  Future<void> setSortOption(int option) async {
    sortOption.value = option;
    await AppDatabase().AllSettings.setSortOption(option);
  }

  /// 添加排序顺序状态
  final Signal<int> sortOrder = signal(0); // 0: 升序, 1: 降序

  /// 添加显示模式状态
  final Signal<int> displayMode = signal(0); // 0: 默认, 1: 仅用户, 2: 仅服务器

  /// 设置sortOrder
  Future<void> setSortOrder(int order) async {
    sortOrder.value = order;
    await AppDatabase().AllSettings.setSortOrder(order);
  }

  /// 设置displayMode
  Future<void> setDisplayMode(int mode) async {
    displayMode.value = mode;
    await AppDatabase().AllSettings.setDisplayMode(mode);
  }

  /// beta - 参与测试版
  final Signal<bool> beta = signal(false);

  /// autoCheckUpdate - 自动检查更新
  final Signal<bool> autoCheckUpdate = signal(true);

  /// downloadAccelerate - 下载加速
  final Signal<String> downloadAccelerate = signal('https://gh.xmly.dev/');

  /// 设置beta
  Future<void> setBeta(bool value) async {
    beta.value = value;
    await AppDatabase().AllSettings.setBeta(value);
  }

  /// 设置autoCheckUpdate
  Future<void> setAutoCheckUpdate(bool value) async {
    autoCheckUpdate.value = value;
    await AppDatabase().AllSettings.setAutoCheckUpdate(value);
  }

  /// 设置downloadAccelerate
  Future<void> setDownloadAccelerate(String value) async {
    downloadAccelerate.value = value;
    await AppDatabase().AllSettings.setDownloadAccelerate(value);
  }

  ///防火墙状态 只要有一个没有关闭就是false
  final Signal<bool> firewallStatus = signal(false);
  final Signal<bool> wfpStatus = signal(false);

  /// autoSetMTU
  final Signal<bool> autoSetMTU = signal(true); // 自动设置MTU
  /// 设置autoSetMTU
  Future<void> setAutoSetMTU(bool value) async {
    autoSetMTU.value = value;
    await AppDatabase().AllSettings.setAutoSetMTU(value);
    setInterfaceMetric(interfaceName: "astral", metric: 0);
  }

  // 设置防火墙状态
  Future<void> setFirewall(bool value) async {
    firewallStatus.value = value;
    await setFirewallStatus(profileIndex: 1, enable: value);
    await setFirewallStatus(profileIndex: 2, enable: value);
    await setFirewallStatus(profileIndex: 3, enable: value);
    updateListenListFromDb();
  }

  // 更新防火墙状态
  Future<void> updateFirewallStatus() async {
    firewallStatus.value =
        await getFirewallStatus(profileIndex: 1) &&
        await getFirewallStatus(profileIndex: 2) &&
        await getFirewallStatus(profileIndex: 3);
  }

  /// 设置userListSimple
  Future<void> setUserListSimple(bool value) async {
    userListSimple.value = value;
    await AppDatabase().AllSettings.setUserMinimal(value);
  }

  /// 获取监听列表
  Future<void> updateListenListFromDb() async {
    listenList.value = await AppDatabase().AllSettings.getListenList();
  }

  /// 设置监听列表
  Future<void> setListenList(List<String> list) async {
    listenList.value = list;
    await AppDatabase().AllSettings.setListenList(list);
  }

  /// 添加监听项
  Future<void> addListen(String listen) async {
    // 先获取可变副本
    final list = List<String>.from(listenList.value);
    list.add(listen);
    listenList.value = list;
    await AppDatabase().AllSettings.setListenList(list);
  }

  /// 删除监听项
  Future<void> deleteListen(int index) async {
    // 先获取可变副本
    final list = List<String>.from(listenList.value);
    list.removeAt(index);
    listenList.value = list;
    await AppDatabase().AllSettings.setListenList(list);
  }

  /// 修改监听项
  Future<void> updateListen(int index, String listen) async {
    await AppDatabase().AllSettings.updateListenList(index, listen);
    listenList.value = await AppDatabase().AllSettings.getListenList();
  }

  /// **********************************************************************************************************
  /// 主题颜色
  final Signal<Color> themeColor = signal(Colors.blue);
  // 更新主题颜色
  Future<void> updateThemeColor(Color color) async {
    themeColor.value = color;
    await AppDatabase().themeSettings.updateThemeColor(color.toARGB32());
  }

  /// **********************************************************************************************************
  /// 主题模式
  final Signal<ThemeMode> themeMode = signal(ThemeMode.system); // 初始化为跟随系统
  // 更新主题模式
  Future<void> updateThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await AppDatabase().themeSettings.updateThemeMode(mode);
  }

  /// **********************************************************************************************************
  /// 语言设置
  final Signal<String> currentLanguage = signal('zh'); // 初始化为中文
  // 更新语言设置
  Future<void> updateLanguage(String languageCode) async {
    currentLanguage.value = languageCode;
  }

  /// **********************************************************************************************************

  /// 软件名
  final Signal<String> appName = signal('Astral Game'); // 初始化为Astral Game

  /// **********************************************************************************************************

  /// 获取屏幕分割宽度 区分手机和桌面
  final Signal<double> screenSplitWidth = signal(480); // 初始化为480
  //更新屏幕分割宽度
  void updateScreenSplitWidth(double width) {
    screenSplitWidth.value = width;
    // 判断是否为桌面
    isDesktop.value = width > 480;
  }

  /// **********************************************************************************************************

  /// 是否为桌面
  final Signal<bool> isDesktop = signal(false); // 初始化为false
  /// **********************************************************************************************************

  // 添加鼠标悬停状态跟踪
  final Signal<int?> hoveredIndex = signal(null);

  /// **********************************************************************************************************

  // 构建导航项
  final Signal<int> selectedIndex = Signal(0);

  /// 网络配置
  final Signal<String> netns = signal(''); // 网络命名空间
  final Signal<String> hostname = signal(''); // 主机名
  final Signal<String> instanceName = signal('default'); // 实例名称
  final Signal<String> ipv4 = signal(''); // IPv4地址
  final Signal<String> ipv6 = signal(''); // IPv4地址
  final Signal<bool> dhcp = signal(true); // DHCP设置
  final Signal<String> networkName = signal(''); // 网络名称
  final Signal<String> networkSecret = signal(''); // 网络密钥
  final Signal<List<String>> listeners = signal([]); // 监听端口列表
  final Signal<List<String>> peer = signal([]); // 对等节点列表
  final Signal<String> defaultProtocol = signal(''); // 默认协议
  final Signal<String> devName = signal(''); // 设备名称
  final Signal<bool> enableEncryption = signal(true); // 加密设置
  final Signal<bool> enableIpv6 = signal(true); // IPv6设置
  final Signal<int> mtu = signal(1360); // MTU值
  final Signal<bool> latencyFirst = signal(false); // 延迟优先设置
  final Signal<bool> enableExitNode = signal(false); // 出口节点设置
  final Signal<bool> noTun = signal(false); // TUN设备禁用设置
  final Signal<bool> useSmoltcp = signal(false); // smoltcp网络栈设置
  final Signal<String> relayNetworkWhitelist = signal(''); // 中继网络白名单
  final Signal<bool> disableP2p = signal(false); // P2P禁用设置
  final Signal<bool> privateMode = signal(false); // 私有模式设置
  final Signal<bool> enableQuicProxy = signal(false); // QUIC代理设置
  final Signal<bool> disableQuicInput = signal(false); // 禁用QUIC输入设置
  final Signal<bool> relayAllPeerRpc = signal(false); // 中继所有对等RPC设置
  final Signal<bool> disableUdpHolePunching = signal(false); // UDP打洞禁用设置
  final Signal<bool> disableSymHolePunching = signal(false); // 对称NAT打洞禁用设置
  final Signal<bool> multiThread = signal(true); // 多线程设置
  final Signal<int> dataCompressAlgo = signal(1);
  final Signal<List<String>> cidrproxy = signal([]);

  /// 数据压缩算法(0:不压缩)
  final Signal<bool> bindDevice = signal(false);

  /// 是否绑定设备
  final Signal<bool> enableKcpProxy = signal(false);

  /// 是否启用KCP代理
  final Signal<bool> disableKcpInput = signal(false);

  /// 是否禁用KCP输入
  final Signal<bool> disableRelayKcp = signal(false);

  /// 是否禁用中继KCP
  final Signal<bool> proxyForwardBySystem = signal(false);

  final Signal<bool> accept_dns = signal(false);

  // 更新网络配置
  /// 从数据库加载并更新所有网络配置
  Future<void> updateNetConfig() async {
    final database = AppDatabase();
    // 获取基本网络配置
    netns.value = await database.netConfigSetting.getNetns(); // 网络命名空间
    hostname.value = await database.netConfigSetting.getHostname(); // 主机名
    instanceName.value =
        await database.netConfigSetting.getInstanceName(); // 实例名称
    ipv4.value = await database.netConfigSetting.getIpv4(); // IPv4地址
    dhcp.value = await database.netConfigSetting.getDhcp(); // DHCP设置

    // 获取网络连接相关配置
    networkName.value =
        await database.netConfigSetting.getNetworkName(); // 网络名称
    networkSecret.value =
        await database.netConfigSetting.getNetworkSecret(); // 网络密钥
    listeners.value = await database.netConfigSetting.getListeners(); // 监听端口列表
    peer.value = await database.netConfigSetting.getPeer(); // 对等节点列表
    defaultProtocol.value =
        await database.netConfigSetting.getDefaultProtocol(); // 默认协议
    devName.value = await database.netConfigSetting.getDevName(); // 设备名称

    // 获取网络功能开关配置
    enableEncryption.value =
        await database.netConfigSetting.getEnableEncryption(); // 加密设置
    enableIpv6.value =
        await database.netConfigSetting.getEnableIpv6(); // IPv6设置
    mtu.value = await database.netConfigSetting.getMtu(); // MTU值
    latencyFirst.value =
        await database.netConfigSetting.getLatencyFirst(); // 延迟优先
    enableExitNode.value =
        await database.netConfigSetting.getEnableExitNode(); // 出口节点
    noTun.value = await database.netConfigSetting.getNoTun(); // TUN设备禁用
    useSmoltcp.value =
        await database.netConfigSetting.getUseSmoltcp(); // smoltcp网络栈
    dataCompressAlgo.value =
        await database.netConfigSetting.getDataCompressAlgo(); // 数据压缩算法

    cidrproxy.value = await database.netConfigSetting.getCidrproxy();
    // 获取高级网络配置
    relayNetworkWhitelist.value =
        await database.netConfigSetting.getRelayNetworkWhitelist(); // 中继网络白名单
    disableP2p.value = await database.netConfigSetting.getDisableP2p(); // P2P禁用
    privateMode.value =
        await database.netConfigSetting.getPrivateMode(); // 私有模式
    enableQuicProxy.value =
        await database.netConfigSetting.getEnableQuicProxy(); // QUIC代理设置
    disableQuicInput.value =
        await database.netConfigSetting.getDisableQuicInput(); // 禁用QUIC输入设置

    relayAllPeerRpc.value =
        await database.netConfigSetting.getRelayAllPeerRpc(); // 中继所有对等RPC
    disableUdpHolePunching.value =
        await database.netConfigSetting.getDisableUdpHolePunching(); // UDP打洞禁用
    disableSymHolePunching.value =
        await database.netConfigSetting
            .getDisableSymHolePunching(); // 对称NAT打洞禁用
    multiThread.value =
        await database.netConfigSetting.getMultiThread(); // 多线程设置
    enableKcpProxy.value =
        await database.netConfigSetting.getEnableKcpProxy(); // 启用KCP代理
    disableKcpInput.value =
        await database.netConfigSetting.getDisableKcpInput(); // 禁用KCP输入
    disableRelayKcp.value =
        await database.netConfigSetting.getDisableRelayKcp(); // 禁用中继KCP
    proxyForwardBySystem.value =
        await database.netConfigSetting.getProxyForwardBySystem(); // 代理转发系统
    accept_dns.value = await database.netConfigSetting.getAcceptDns();
  }

  // 更新网络命名空间
  Future<void> updateNetns(String value) async {
    netns.value = value;
    await AppDatabase().netConfigSetting.updateNetns(value);
  }

  // 更新主机名
  Future<void> updateHostname(String value) async {
    hostname.value = value;
    await AppDatabase().netConfigSetting.updateHostname(value);
  }

  // 更新实例名称
  Future<void> updateInstanceName(String value) async {
    instanceName.value = value;
    await AppDatabase().netConfigSetting.updateInstanceName(value);
  }

  // 更新IPv4地址
  Future<void> updateIpv4(String value) async {
    ipv4.value = value;
    await AppDatabase().netConfigSetting.updateIpv4(value);
  }

  // 更新DHCP设置
  Future<void> updateDhcp(bool value) async {
    dhcp.value = value;
    await AppDatabase().netConfigSetting.updateDhcp(value);
  }

  // 更新网络名称
  Future<void> updateNetworkName(String value) async {
    networkName.value = value;
    await AppDatabase().netConfigSetting.updateNetworkName(value);
  }

  // 更新网络密钥
  Future<void> updateNetworkSecret(String value) async {
    networkSecret.value = value;
    await AppDatabase().netConfigSetting.updateNetworkSecret(value);
  }

  // 更新监听端口列表
  Future<void> updateListeners(List<String> value) async {
    listeners.value = value;
    await AppDatabase().netConfigSetting.updateListeners(value);
  }

  // 更新对等节点列表
  Future<void> updatePeer(List<String> value) async {
    peer.value = value;
    await AppDatabase().netConfigSetting.updatePeer(value);
  }

  // 更新默认协议
  Future<void> updateDefaultProtocol(String value) async {
    defaultProtocol.value = value;
    await AppDatabase().netConfigSetting.updateDefaultProtocol(value);
  }

  // 更新设备名称
  Future<void> updateDevName(String value) async {
    devName.value = value;
    await AppDatabase().netConfigSetting.updateDevName(value);
  }

  /// 更新加密设置 会顺便更新mtu
  /// 如果开启加密则mtu为1360 否则为1380
  Future<void> updateEnableEncryption(bool value) async {
    enableEncryption.value = value;
    if (value) {
      //设置mtu为1360
      updateMtu(1360);
    } else {
      //设置mtu为1380
      updateMtu(1380);
    }
    await AppDatabase().netConfigSetting.updateEnableEncryption(value);
  }

  // 更新IPv6设置
  Future<void> updateEnableIpv6(bool value) async {
    enableIpv6.value = value;
    await AppDatabase().netConfigSetting.updateEnableIpv6(value);
  }

  // 更新MTU值
  Future<void> updateMtu(int value) async {
    mtu.value = value;
    await AppDatabase().netConfigSetting.updateMtu(value);
  }

  // 更新延迟优先设置
  Future<void> updateLatencyFirst(bool value) async {
    latencyFirst.value = value;
    await AppDatabase().netConfigSetting.updateLatencyFirst(value);
  }

  // 更新出口节点设置
  Future<void> updateEnableExitNode(bool value) async {
    enableExitNode.value = value;
    await AppDatabase().netConfigSetting.updateEnableExitNode(value);
  }

  // 更新TUN设备禁用设置
  Future<void> updateNoTun(bool value) async {
    noTun.value = value;
    await AppDatabase().netConfigSetting.updateNoTun(value);
  }

  /// 添加CIDR代理
  Future<void> addCidrproxy(String cidr) async {
    final list = List<String>.from(cidrproxy.value);
    list.add(cidr);
    cidrproxy.value = list;
    await AppDatabase().netConfigSetting.setCidrproxy(list);
  }

  /// 删除CIDR代理
  Future<void> deleteCidrproxy(int index) async {
    final list = List<String>.from(cidrproxy.value);
    list.removeAt(index);
    cidrproxy.value = list;
    await AppDatabase().netConfigSetting.setCidrproxy(list);
  }

  /// 更新CIDR代理
  Future<void> updateCidrproxy(int index, String cidr) async {
    await AppDatabase().netConfigSetting.updateCidrproxy(index, cidr);
    cidrproxy.value = await AppDatabase().netConfigSetting.getCidrproxy();
  }

  // 更新smoltcp网络栈设置
  Future<void> updateUseSmoltcp(bool value) async {
    useSmoltcp.value = value;
    await AppDatabase().netConfigSetting.updateUseSmoltcp(value);
  }

  // 更新中继网络白名单
  Future<void> updateRelayNetworkWhitelist(String value) async {
    relayNetworkWhitelist.value = value;
    await AppDatabase().netConfigSetting.updateRelayNetworkWhitelist(value);
  }

  // 更新P2P禁用设置
  Future<void> updateDisableP2p(bool value) async {
    disableP2p.value = value;
    await AppDatabase().netConfigSetting.updateDisableP2p(value);
  }

  // 更新中继所有对等RPC设置
  Future<void> updateRelayAllPeerRpc(bool value) async {
    relayAllPeerRpc.value = value;
    await AppDatabase().netConfigSetting.updateRelayAllPeerRpc(value);
  }

  // 更新UDP打洞禁用设置
  Future<void> updateDisableUdpHolePunching(bool value) async {
    disableUdpHolePunching.value = value;
    await AppDatabase().netConfigSetting.updateDisableUdpHolePunching(value);
  }

  // 更新对称NAT打洞禁用设置
  Future<void> updateDisableSymHolePunching(bool value) async {
    disableSymHolePunching.value = value;
    await AppDatabase().netConfigSetting.updateDisableSymHolePunching(value);
  }

  // 更新多线程设置
  Future<void> updateMultiThread(bool value) async {
    multiThread.value = value;
    await AppDatabase().netConfigSetting.updateMultiThread(value);
  }

  // 更新数据压缩算法
  Future<void> updateDataCompressAlgo(int value) async {
    dataCompressAlgo.value = value;
    await AppDatabase().netConfigSetting.updateDataCompressAlgo(value);
  }

  // 更新是否绑定设备
  Future<void> updateBindDevice(bool value) async {
    bindDevice.value = value;
    await AppDatabase().netConfigSetting.updateBindDevice(value);
  }

  // 更新是否启用KCP代理
  Future<void> updateEnableKcpProxy(bool value) async {
    enableKcpProxy.value = value;
    await AppDatabase().netConfigSetting.updateEnableKcpProxy(value);
  }

  // 更新是否禁用KCP输入
  Future<void> updateDisableKcpInput(bool value) async {
    disableKcpInput.value = value;
    await AppDatabase().netConfigSetting.updateDisableKcpInput(value);
  }

  // 更新是否禁用中继KCP
  Future<void> updateDisableRelayKcp(bool value) async {
    disableRelayKcp.value = value;
    await AppDatabase().netConfigSetting.updateDisableRelayKcp(value);
  }

  // 更新是否使用系统代理转发
  Future<void> updateProxyForwardBySystem(bool value) async {
    proxyForwardBySystem.value = value;
    await AppDatabase().netConfigSetting.updateProxyForwardBySystem(value);
  }

  //accept_dns
  Future<void> updateAcceptDns(bool value) async {
    accept_dns.value = value;
    await AppDatabase().netConfigSetting.updateAcceptDns(value);
  }

  // 更新私有模式设置
  Future<void> updatePrivateMode(bool value) async {
    privateMode.value = value;
    await AppDatabase().netConfigSetting.updatePrivateMode(value);
  }

  // 更新QUIC代理设置
  Future<void> updateEnableQuicProxy(bool value) async {
    enableQuicProxy.value = value;
    await AppDatabase().netConfigSetting.updateEnableQuicProxy(value);
  }

  // 更新禁用QUIC输入设置
  Future<void> updateDisableQuicInput(bool value) async {
    disableQuicInput.value = value;
    await AppDatabase().netConfigSetting.updateDisableQuicInput(value);
  }

  /// 房间列表
  final Signal<List<Room>> rooms = signal([]);

  /// 最新版本号
  final Signal<String?> latestVersion = signal(null);

  /// 添加房间
  Future<void> addRoom(Room room) async {
    await AppDatabase().RoomSetting.addRoom(room);
    rooms.value = await AppDatabase().RoomSetting.getAllRooms(); // 重新加载房间列表
  }

  /// 更新最新版本号
  Future<void> updateLatestVersion(String version) async {
    latestVersion.value = version;
    await AppDatabase().AllSettings.setLatestVersion(version);
  }

  /// 删除房间
  Future<void> deleteRoom(int id) async {
    await AppDatabase().RoomSetting.deleteRoom(id);
    rooms.value = await AppDatabase().RoomSetting.getAllRooms();
  }

  /// 根据ID获取房间
  Future<Room?> getRoomById(int id) async {
    return await AppDatabase().RoomSetting.getRoomById(id);
  }

  /// 获取所有房间
  Future<List<Room>> getAllRooms() async {
    final roomsList = await AppDatabase().RoomSetting.getAllRooms();
    rooms.value = roomsList; // 更新 Signal
    return roomsList;
  }

  /// 更新房间
  Future<int> updateRoom(Room room) async {
    await AppDatabase().RoomSetting.updateRoom(room);
    rooms.value = await AppDatabase().RoomSetting.getAllRooms();
    return room.id;
  }

  /// 重新排序房间
  Future<void> reorderRooms(List<Room> reorderedRooms) async {
    await AppDatabase().RoomSetting.updateRoomsOrder(reorderedRooms);
    rooms.value = await AppDatabase().RoomSetting.getAllRooms();
  }

  /// 所选房间
  final Signal<Room?> selectroom = signal(null);

  /// 设置当前选中的房间
  Future<void> setRoom(Room room) async {
    await AppDatabase().AllSettings.updateRoom(room);
    selectroom.value = await AppDatabase().AllSettings.getRoom();
  }

  /// 服务器列表
  final Signal<List<ServerMod>> servers = signal([]);

  /// 添加服务器
  Future<void> addServer(ServerMod server) async {
    try {
      await AppDatabase().ServerSetting.addServer(server);
      servers.value = await AppDatabase().ServerSetting.getAllServers();
    } catch (e, stackTrace) {
      // 记录错误日志
      debugPrint('添加服务器失败: $e\n$stackTrace');
    }
  }

  /// 删除服务器
  Future<void> deleteServerid(int id) async {
    await AppDatabase().ServerSetting.deleteServerid(id);
    servers.value = await AppDatabase().ServerSetting.getAllServers();
  }

  /// 根据ID获取服务器
  Future<ServerMod?> getServerById(int id) async {
    return await AppDatabase().ServerSetting.getServerById(id);
  }

  /// 获取所有服务器
  Future<List<ServerMod>> getAllServers() async {
    final serversList = await AppDatabase().ServerSetting.getAllServers();
    servers.value = serversList; // 更新 Signal
    return serversList;
  }

  /// 更新服务器
  Future<int> updateServer(ServerMod server) async {
    await AppDatabase().ServerSetting.updateServer(server);
    servers.value = await AppDatabase().ServerSetting.getAllServers();
    return server.id;
  }

  /// 删除服务器
  Future<void> deleteServer(ServerMod server) async {
    await AppDatabase().ServerSetting.deleteServer(server);
    servers.value = await AppDatabase().ServerSetting.getAllServers();
  }

  /// 重新排序服务器
  Future<void> reorderServers(List<ServerMod> reorderedServers) async {
    await AppDatabase().ServerSetting.updateServersOrder(reorderedServers);
    servers.value = await AppDatabase().ServerSetting.getAllServers(); // 新增状态更新
  }

  /// 是否处于连接中
  final Signal<bool> isConnecting = signal(false);
  final Signal<CoState> Connec_state = signal(CoState.idle);

  /// 是否关闭最小化到托盘
  final Signal<bool> closeMinimize = signal(true);

  /// 更新是否关闭最小化到托盘
  Future<void> updateCloseMinimize(bool value) async {
    closeMinimize.value = value;
    await AppDatabase().AllSettings.closeMinimize(value);
  }

  /// 自定义vpn网段
  final Signal<List<String>> customVpn = signal([]);

  /// 添加自定义vpn网段
  Future<void> addCustomVpn(String value) async {
    final list = List<String>.from(customVpn.value);
    list.add(value);
    customVpn.value = list;
    await AppDatabase().AllSettings.setCustomVpn(list);
  }

  /// 删除自定义vpn网段
  Future<void> deleteCustomVpn(int index) async {
    final list = List<String>.from(customVpn.value);
    list.removeAt(index);
    customVpn.value = list;
    await AppDatabase().AllSettings.setCustomVpn(list);
  }

  /// 更新自定义vpn网段
  Future<void> updateCustomVpn(int index, String value) async {
    await AppDatabase().AllSettings.updateCustomVpn(index, value);
    customVpn.value = await AppDatabase().AllSettings.getCustomVpn();
  }

  /// 开机自启
  final Signal<bool> startup = signal(false);

  /// 启动后最小化
  final Signal<bool> startupMinimize = signal(false);

  /// 启动后自动连接
  final Signal<bool> startupAutoConnect = signal(false);

  /// 设置开机自启
  Future<void> setStartup(bool value) async {
    startup.value = value;
    await AppDatabase().AllSettings.setStartup(value);
  }

  /// 设置启动后最小化
  Future<void> setStartupMinimize(bool value) async {
    startupMinimize.value = value;
    await AppDatabase().AllSettings.setStartupMinimize(value);
  }

  /// 设置启动后自动连接
  Future<void> setStartupAutoConnect(bool value) async {
    startupAutoConnect.value = value;
    await AppDatabase().AllSettings.setStartupAutoConnect(value);
  }

  /// 从数据库加载启动相关设置
  Future<void> loadStartupSettings() async {
    startup.value = await AppDatabase().AllSettings.getStartup();
    startupMinimize.value =
        await AppDatabase().AllSettings.getStartupMinimize();
    startupAutoConnect.value =
        await AppDatabase().AllSettings.getStartupAutoConnect();
  }

  Timer? _pingTimer;

  void dispose() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  // Ping测试
  Future<List<ServerMod>> setServerEnable(ServerMod server, bool enable) async {
    server.enable = enable;
    await AppDatabase().ServerSetting.updateServer(server);
    servers.value = await AppDatabase().ServerSetting.getAllServers();

    return AppDatabase().ServerSetting.getAllServers();
  }
}
