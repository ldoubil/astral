import 'dart:io';
import 'package:astral/models/base.dart';
import 'package:astral/models/server_node.dart';

/// 网络节点的 Hive 模型
class NetNode {
  String netns = ''; // 网络命名空间

  String hostname = Platform.localHostname; // 主机名

  String instance_name = 'default'; // 实例名称

  String ipv4 = ''; // IPv4地址

  bool dhcp = true; // 是否使用DHCP

  String network_name = ''; // 网络名称

  String network_secret = ''; // 网络密钥

  List<String> listeners = []; // 监听列表

  List<ServerNode> peer = []; // 服务器节点地址

  List<String> cidrproxy = []; // 代理地址

  List<ConnectionManager> connectionManagers = [];

  String default_protocol = 'tcp'; //x

  String dev_name = '';

  bool enable_encryption = true; //x

  bool enable_ipv6 = true;

  int mtu = 1360; //x

  bool latency_first = true; //x

  bool enable_exit_node = false; //x

  bool no_tun = false; //x

  bool use_smoltcp = false; //x
  String relay_network_whitelist = '*';

  bool disable_p2p = false; //x

  bool relay_all_peer_rpc = false; //x

  bool disable_udp_hole_punching = false; //x

  bool multi_thread = true; //x

  int data_compress_algo = 1; //x

  bool bind_device = true; //x

  bool enable_kcp_proxy = true; //x

  bool disable_kcp_input = false; //x

  bool disable_relay_kcp = false; //x

  bool proxy_forward_by_system = false; //x

  bool accept_dns = true; //x

  bool private_mode = false;

  bool enable_quic_proxy = true;

  bool disable_quic_input = false;
}
