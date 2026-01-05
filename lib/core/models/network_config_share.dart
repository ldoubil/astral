import 'dart:convert';
import 'package:astral/core/services/service_manager.dart';

/// 网络配置分享模型
/// 用于房间分享时携带网络配置
class NetworkConfigShare {
  // 基础配置
  final String ipv4;
  final bool dhcp;
  final List<String> listeners;
  final String hostname;

  // 高级配置（可选）
  final bool? enableEncryption;
  final int? mtu;
  final bool? latencyFirst;
  final bool? disableP2p;
  final bool? disableUdpHolePunching;
  final bool? disableSymHolePunching;
  final bool? multiThread;
  final int? dataCompressAlgo;
  final bool? enableKcpProxy;
  final bool? enableQuicProxy;

  NetworkConfigShare({
    required this.ipv4,
    required this.dhcp,
    required this.listeners,
    required this.hostname,
    this.enableEncryption,
    this.mtu,
    this.latencyFirst,
    this.disableP2p,
    this.disableUdpHolePunching,
    this.disableSymHolePunching,
    this.multiThread,
    this.dataCompressAlgo,
    this.enableKcpProxy,
    this.enableQuicProxy,
  });

  /// 序列化为JSON（使用短键名优化压缩）
  Map<String, dynamic> toJson() => {
    'ipv4': ipv4,
    'dhcp': dhcp ? 1 : 0,
    'listeners': listeners,
    'hostname': hostname,
    if (enableEncryption != null) 'enc': enableEncryption! ? 1 : 0,
    if (mtu != null) 'mtu': mtu,
    if (latencyFirst != null) 'lat': latencyFirst! ? 1 : 0,
    if (disableP2p != null) 'dp2p': disableP2p! ? 1 : 0,
    if (disableUdpHolePunching != null) 'dudp': disableUdpHolePunching! ? 1 : 0,
    if (disableSymHolePunching != null) 'dsym': disableSymHolePunching! ? 1 : 0,
    if (multiThread != null) 'mt': multiThread! ? 1 : 0,
    if (dataCompressAlgo != null) 'comp': dataCompressAlgo,
    if (enableKcpProxy != null) 'kcp': enableKcpProxy! ? 1 : 0,
    if (enableQuicProxy != null) 'quic': enableQuicProxy! ? 1 : 0,
  };

  /// 从JSON反序列化
  factory NetworkConfigShare.fromJson(Map<String, dynamic> json) {
    return NetworkConfigShare(
      ipv4: json['ipv4'] ?? '',
      dhcp: (json['dhcp'] ?? 1) == 1,
      listeners: List<String>.from(json['listeners'] ?? []),
      hostname: json['hostname'] ?? '',
      enableEncryption: json['enc'] != null ? json['enc'] == 1 : null,
      mtu: json['mtu'],
      latencyFirst: json['lat'] != null ? json['lat'] == 1 : null,
      disableP2p: json['dp2p'] != null ? json['dp2p'] == 1 : null,
      disableUdpHolePunching: json['dudp'] != null ? json['dudp'] == 1 : null,
      disableSymHolePunching: json['dsym'] != null ? json['dsym'] == 1 : null,
      multiThread: json['mt'] != null ? json['mt'] == 1 : null,
      dataCompressAlgo: json['comp'],
      enableKcpProxy: json['kcp'] != null ? json['kcp'] == 1 : null,
      enableQuicProxy: json['quic'] != null ? json['quic'] == 1 : null,
    );
  }

  /// 从当前网络配置状态创建
  factory NetworkConfigShare.fromCurrentConfig() {
    final services = ServiceManager();
    return NetworkConfigShare(
      ipv4: services.networkConfigState.ipv4.value,
      dhcp: services.networkConfigState.dhcp.value,
      listeners: services.networkConfigState.listeners.value,
      hostname: services.networkConfigState.hostname.value,
      enableEncryption: services.networkConfigState.enableEncryption.value,
      mtu: services.networkConfigState.mtu.value,
      latencyFirst: services.networkConfigState.latencyFirst.value,
      disableP2p: services.networkConfigState.disableP2p.value,
      disableUdpHolePunching:
          services.networkConfigState.disableUdpHolePunching.value,
      disableSymHolePunching:
          services.networkConfigState.disableSymHolePunching.value,
      multiThread: services.networkConfigState.multiThread.value,
      dataCompressAlgo: services.networkConfigState.dataCompressAlgo.value,
      enableKcpProxy: services.networkConfigState.enableKcpProxy.value,
      enableQuicProxy: services.networkConfigState.enableQuicProxy.value,
    );
  }

  /// 应用到网络配置服务
  Future<void> applyToConfig() async {
    final services = ServiceManager();

    // 应用基础配置
    if (!dhcp && ipv4.isNotEmpty) {
      await services.networkConfig.updateIpv4(ipv4);
    }
    await services.networkConfig.updateDhcp(dhcp);
    await services.networkConfig.updateListeners(listeners);
    if (hostname.isNotEmpty) {
      await services.networkConfig.updateHostname(hostname);
    }

    // 应用高级配置（如果存在）
    if (enableEncryption != null) {
      await services.networkConfig.updateEnableEncryption(enableEncryption!);
    }
    if (mtu != null) {
      await services.networkConfig.updateMtu(mtu!);
    }
    if (latencyFirst != null) {
      await services.networkConfig.updateLatencyFirst(latencyFirst!);
    }
    if (disableP2p != null) {
      await services.networkConfig.updateDisableP2p(disableP2p!);
    }
    if (disableUdpHolePunching != null) {
      await services.networkConfig.updateDisableUdpHolePunching(
        disableUdpHolePunching!,
      );
    }
    if (disableSymHolePunching != null) {
      await services.networkConfig.updateDisableSymHolePunching(
        disableSymHolePunching!,
      );
    }
    if (multiThread != null) {
      await services.networkConfig.updateMultiThread(multiThread!);
    }
    if (dataCompressAlgo != null) {
      await services.networkConfig.updateDataCompressAlgo(dataCompressAlgo!);
    }
    if (enableKcpProxy != null) {
      await services.networkConfig.updateEnableKcpProxy(enableKcpProxy!);
    }
    if (enableQuicProxy != null) {
      await services.networkConfig.updateEnableQuicProxy(enableQuicProxy!);
    }
  }

  /// 转换为可读的配置摘要
  String toReadableSummary() {
    final buffer = StringBuffer();

    buffer.writeln('• DHCP: ${dhcp ? "自动" : "手动"}');
    if (!dhcp && ipv4.isNotEmpty) {
      buffer.writeln('• IPv4: $ipv4');
    }
    if (listeners.isNotEmpty) {
      buffer.writeln('• 监听: ${listeners.join(", ")}');
    }
    if (hostname.isNotEmpty) {
      buffer.writeln('• 主机名: $hostname');
    }
    if (enableEncryption != null) {
      buffer.writeln('• 加密: ${enableEncryption! ? "开启" : "关闭"}');
    }
    if (mtu != null) {
      buffer.writeln('• MTU: $mtu');
    }
    if (latencyFirst != null) {
      buffer.writeln('• 延迟优先: ${latencyFirst! ? "开启" : "关闭"}');
    }
    if (disableP2p != null) {
      buffer.writeln('• P2P: ${disableP2p! ? "禁用" : "启用"}');
    }
    if (multiThread != null) {
      buffer.writeln('• 多线程: ${multiThread! ? "开启" : "关闭"}');
    }

    return buffer.toString().trim();
  }

  /// 序列化为JSON字符串
  String toJsonString() => jsonEncode(toJson());

  /// 从JSON字符串反序列化
  static NetworkConfigShare? fromJsonString(String jsonString) {
    try {
      return NetworkConfigShare.fromJson(jsonDecode(jsonString));
    } catch (e) {
      return null;
    }
  }
}
