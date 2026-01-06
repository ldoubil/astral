import 'dart:convert';
import 'package:astral/core/services/service_manager.dart';

/// 网络配置分享模型
/// 用于房间分享时携带网络配置（仅高级设置）
class NetworkConfigShare {
  // 基础配置
  final bool? dhcp;
  final String? defaultProtocol;

  // 高级配置（可选）
  final bool? enableEncryption;
  final bool? latencyFirst;
  final bool? disableP2p;
  final bool? disableUdpHolePunching;
  final bool? disableSymHolePunching;
  final int? dataCompressAlgo;
  final bool? enableKcpProxy;
  final bool? enableQuicProxy;
  final bool? bindDevice;
  final bool? noTun;

  NetworkConfigShare({
    this.dhcp,
    this.defaultProtocol,
    this.enableEncryption,
    this.latencyFirst,
    this.disableP2p,
    this.disableUdpHolePunching,
    this.disableSymHolePunching,
    this.dataCompressAlgo,
    this.enableKcpProxy,
    this.enableQuicProxy,
    this.bindDevice,
    this.noTun,
  });

  /// 序列化为JSON（使用短键名优化压缩）
  Map<String, dynamic> toJson() => {
    if (dhcp != null) 'dhcp': dhcp! ? 1 : 0,
    if (defaultProtocol != null) 'proto': defaultProtocol,
    if (enableEncryption != null) 'enc': enableEncryption! ? 1 : 0,
    if (latencyFirst != null) 'lat': latencyFirst! ? 1 : 0,
    if (disableP2p != null) 'dp2p': disableP2p! ? 1 : 0,
    if (disableUdpHolePunching != null) 'dudp': disableUdpHolePunching! ? 1 : 0,
    if (disableSymHolePunching != null) 'dsym': disableSymHolePunching! ? 1 : 0,
    if (dataCompressAlgo != null) 'comp': dataCompressAlgo,
    if (enableKcpProxy != null) 'kcp': enableKcpProxy! ? 1 : 0,
    if (enableQuicProxy != null) 'quic': enableQuicProxy! ? 1 : 0,
    if (bindDevice != null) 'bind': bindDevice! ? 1 : 0,
    if (noTun != null) 'tun': noTun! ? 1 : 0,
  };

  /// 从JSON反序列化
  factory NetworkConfigShare.fromJson(Map<String, dynamic> json) {
    return NetworkConfigShare(
      dhcp: (json['dhcp'] ?? 1) == 1,
      defaultProtocol: json['proto'],
      enableEncryption: json['enc'] != null ? json['enc'] == 1 : null,
      latencyFirst: json['lat'] != null ? json['lat'] == 1 : null,
      disableP2p: json['dp2p'] != null ? json['dp2p'] == 1 : null,
      disableUdpHolePunching: json['dudp'] != null ? json['dudp'] == 1 : null,
      disableSymHolePunching: json['dsym'] != null ? json['dsym'] == 1 : null,
      dataCompressAlgo: json['comp'],
      enableKcpProxy: json['kcp'] != null ? json['kcp'] == 1 : null,
      enableQuicProxy: json['quic'] != null ? json['quic'] == 1 : null,
      bindDevice: json['bind'] != null ? json['bind'] == 1 : null,
      noTun: json['tun'] != null ? json['tun'] == 1 : null,
    );
  }

  /// 从当前网络配置状态创建
  factory NetworkConfigShare.fromCurrentConfig() {
    final services = ServiceManager();
    return NetworkConfigShare(
      dhcp: services.networkConfigState.dhcp.value,
      defaultProtocol: services.networkConfigState.defaultProtocol.value,
      enableEncryption: services.networkConfigState.enableEncryption.value,
      latencyFirst: services.networkConfigState.latencyFirst.value,
      disableP2p: services.networkConfigState.disableP2p.value,
      disableUdpHolePunching:
          services.networkConfigState.disableUdpHolePunching.value,
      disableSymHolePunching:
          services.networkConfigState.disableSymHolePunching.value,
      dataCompressAlgo: services.networkConfigState.dataCompressAlgo.value,
      enableKcpProxy: services.networkConfigState.enableKcpProxy.value,
      enableQuicProxy: services.networkConfigState.enableQuicProxy.value,
      bindDevice: services.networkConfigState.bindDevice.value,
      noTun: services.networkConfigState.noTun.value,
    );
  }

  /// 应用到网络配置服务
  Future<void> applyToConfig() async {
    final services = ServiceManager();

    // 应用DHCP配置（如果存在）
    if (dhcp != null) {
      await services.networkConfig.updateDhcp(dhcp!);
    }

    // 应用高级配置（如果存在）
    if (defaultProtocol != null && defaultProtocol!.isNotEmpty) {
      await services.networkConfig.updateDefaultProtocol(defaultProtocol!);
    }
    if (enableEncryption != null) {
      await services.networkConfig.updateEnableEncryption(enableEncryption!);
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
    if (dataCompressAlgo != null) {
      await services.networkConfig.updateDataCompressAlgo(dataCompressAlgo!);
    }
    if (enableKcpProxy != null) {
      await services.networkConfig.updateEnableKcpProxy(enableKcpProxy!);
    }
    if (enableQuicProxy != null) {
      await services.networkConfig.updateEnableQuicProxy(enableQuicProxy!);
    }
    if (bindDevice != null) {
      await services.networkConfig.updateBindDevice(bindDevice!);
    }
    if (noTun != null) {
      await services.networkConfig.updateNoTun(noTun!);
    }
  }

  /// 转换为可读的配置摘要
  List<String> toReadableSummary() {
    final lines = <String>[];

    if (dhcp != null) {
      lines.add('• DHCP: ${dhcp! ? "自动" : "手动"}');
    }

    if (defaultProtocol != null && defaultProtocol!.isNotEmpty) {
      lines.add('• 默认协议: ${defaultProtocol!.toUpperCase()}');
    }
    if (enableEncryption != null) {
      lines.add('• 加密: ${enableEncryption! ? "开启" : "关闭"}');
    }
    if (latencyFirst != null) {
      lines.add('• 延迟优先: ${latencyFirst! ? "开启" : "关闭"}');
    }
    if (disableP2p != null) {
      lines.add('• P2P: ${disableP2p! ? "禁用" : "启用"}');
    }
    if (disableUdpHolePunching != null) {
      lines.add('• UDP打洞: ${disableUdpHolePunching! ? "禁用" : "启用"}');
    }
    if (disableSymHolePunching != null) {
      lines.add('• 对称打洞: ${disableSymHolePunching! ? "禁用" : "启用"}');
    }
    if (dataCompressAlgo != null) {
      final algoName = dataCompressAlgo == 1 ? '无压缩' : '高性能压缩';
      lines.add('• 压缩算法: $algoName');
    }
    if (enableKcpProxy != null) {
      lines.add('• KCP代理: ${enableKcpProxy! ? "开启" : "关闭"}');
    }
    if (enableQuicProxy != null) {
      lines.add('• QUIC代理: ${enableQuicProxy! ? "开启" : "关闭"}');
    }
    if (bindDevice != null) {
      lines.add('• 绑定设备: ${bindDevice! ? "开启" : "关闭"}');
    }
    if (noTun != null) {
      lines.add('• TUN设备: ${noTun! ? "禁用" : "启用"}');
    }

    return lines;
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
