import 'dart:io';
import 'package:astral/models/base.dart';
import 'package:hive/hive.dart';


part 'net_node.g.dart';



/// 网络节点的 Hive 模型
@HiveType(typeId: 11)
class NetNode {
  // 主键自增
  @HiveField(0)
  int id = 0;
  @HiveField(1)
  String netns = ''; // 网络命名空间

  @HiveField(2)
  String hostname = Platform.localHostname; // 主机名

  @HiveField(3)
  String instance_name = 'default'; // 实例名称

  @HiveField(4)
  String ipv4 = ''; // IPv4地址

  @HiveField(5)
  bool dhcp = true; // 是否使用DHCP
  @HiveField(6)
  String network_name = ''; // 网络名称
  @HiveField(7)
  String network_secret = ''; // 网络密钥

  @HiveField(8)
  List<String> listeners = []; // 监听端口

  @HiveField(9)
  List<String> peer = []; // 服务器节点地址

  // 子网代理
  @HiveField(10)
  List<String> cidrproxy = []; // 代理地址

  // 转发配置
  @HiveField(11)
  List<ConnectionManager> connectionManagers = [];

  /// 默认协议
  @HiveField(12)
  String default_protocol = 'tcp'; //x

  /// 设备名称
  @HiveField(13)
  String dev_name = '';

  /// 是否启用加密
  @HiveField(14)
  bool enable_encryption = true; //x

  /// 是否启用IPv6
  @HiveField(15)
  bool enable_ipv6 = true;

  /// 最大传输单元
  @HiveField(16)
  int mtu = 1360; //x

  /// 是否优先考虑延迟
  @HiveField(17)
  bool latency_first = false; //x

  /// 是否启用出口节点
  @HiveField(18)
  bool enable_exit_node = false; //x

  /// 是否禁用TUN设备
  @HiveField(19)
  bool no_tun = false; //x

  /// 是否使用smoltcp网络栈
  @HiveField(20)
  bool use_smoltcp = false; //x

  /// 中继网络白名单
  @HiveField(21)
  String relay_network_whitelist = '*';

  /// 是否禁用P2P
  @HiveField(22)
  bool disable_p2p = false; //x

  /// 是否中继所有对等RPC
  @HiveField(23)
  bool relay_all_peer_rpc = false; //x

  /// 是否禁用UDP打洞
  @HiveField(24)
  bool disable_udp_hole_punching = false; //x

  /// 是否启用多线程
  @HiveField(25)
  bool multi_thread = true; //x

  /// 数据压缩算法
  @HiveField(26)
  int data_compress_algo = 1; //x

  /// 是否绑定设备
  @HiveField(27)
  bool bind_device = true; //x

  /// 是否启用KCP代理
  @HiveField(28)
  bool enable_kcp_proxy = true; //x

  /// 是否禁用KCP输入
  @HiveField(29)
  bool disable_kcp_input = false; //x

  /// 是否禁用中继KCP
  @HiveField(30)
  bool disable_relay_kcp = true; //x

  /// 是否使用系统代理转发
  @HiveField(31)
  bool proxy_forward_by_system = false; //x

  /// accept_dns 魔术DNS
  @HiveField(32)
  bool accept_dns = false; //x

  /// 是否启用私有模式
  @HiveField(33)
  bool private_mode = false;

  /// 是否启用QUIC代理
  @HiveField(34)
  bool enable_quic_proxy = false;

  /// 是否禁用QUIC输入
  @HiveField(35)
  bool disable_quic_input = false;
}