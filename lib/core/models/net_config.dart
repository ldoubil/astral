import 'dart:io';
import 'package:isar_community/isar.dart';
part 'net_config.g.dart';

@embedded
class ConnectionInfo {
  late String bindAddr;
  late String dstAddr;
  late String proto;
  ConnectionInfo() {
    bindAddr = '';
    dstAddr = '';
    proto = '';
  }
}

@embedded
class ConnectionManager {
  late String name; // 分组名称
  late List<ConnectionInfo> connections;
  late bool enabled;
  ConnectionManager() {
    name = '';
    connections = [];
    enabled = false;
  }
}

@collection
class NetConfig {
  /// 主键ID，固定为1因为只需要一个实例
  Id id = 1;

  String netns = ''; // 网络命名空间

  String hostname = Platform.localHostname; // 主机名

  String instance_name = 'default'; // 实例名称

  String ipv4 = ''; // IPv4地址

  bool dhcp = true; // 是否使用DHCP
  String network_name = ''; // 网络名称
  String network_secret = ''; // 网络密钥

  List<String> listeners = []; // 监听端口

  List<String> peer = []; // 服务器节点地址

  // 子网代理
  List<String> cidrproxy = []; // 代理地址

  // 转发配置
  List<ConnectionManager> connectionManagers = [];

  /// 默认协议
  String default_protocol = 'tcp'; //x

  /// 设备名称
  String dev_name = '';

  /// 是否启用加密
  bool enable_encryption = true; //x

  /// 是否启用IPv6
  bool enable_ipv6 = true;

  /// 最大传输单元
  int mtu = 1360; //x

  /// 是否优先考虑延迟
  bool latency_first = false; //x

  /// 是否启用出口节点
  bool enable_exit_node = false; //x

  /// 是否禁用TUN设备
  bool no_tun = false; //x

  /// 是否使用smoltcp网络栈
  bool use_smoltcp = false; //x

  /// 中继网络白名单
  String relay_network_whitelist = '*';

  /// 是否禁用P2P
  bool disable_p2p = false; //x

  /// 是否中继所有对等RPC
  bool relay_all_peer_rpc = false; //x

  /// 是否禁用UDP打洞
  bool disable_udp_hole_punching = false; //x

  /// 是否禁用TCP打洞
  bool disable_tcp_hole_punching = false; //x

  /// 是否禁用对称NAT打洞
  bool disable_sym_hole_punching = false; //x

  /// 是否启用多线程
  bool multi_thread = true; //x

  /// 数据压缩算法
  int data_compress_algo = 1; //x

  /// 是否绑定设备
  bool bind_device = true; //x

  /// 是否启用KCP代理
  bool enable_kcp_proxy = true; //x

  /// 是否禁用KCP输入
  bool disable_kcp_input = false; //x

  /// 是否禁用中继KCP
  bool disable_relay_kcp = true; //x

  /// 是否使用系统代理转发
  bool proxy_forward_by_system = false; //x

  /// accept_dns 魔术DNS
  bool accept_dns = false; //x

  /// 是否启用私有模式
  bool private_mode = false;

  /// 是否启用QUIC代理
  bool enable_quic_proxy = false;

  /// 是否禁用QUIC输入
  bool disable_quic_input = false;

  /// TCP端口白名单（逗号分隔，如: "80,443,8000-9000"）
  String tcp_whitelist = '';

  /// UDP端口白名单（逗号分隔，如: "53,5000-6000"）
  String udp_whitelist = '';
}
