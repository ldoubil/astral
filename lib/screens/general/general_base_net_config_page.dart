import 'package:astral/models/net_node.dart';
import 'package:astral/widgets/config_switch_tile.dart';
import 'package:astral/widgets/config_dropdown_tile.dart';
import 'package:astral/widgets/config_text_field_tile.dart';
import 'package:astral/widgets/config_section.dart';
import 'package:flutter/material.dart';

class GeneralBaseNetConfigPage extends StatefulWidget {
  final NetNode netNode;
  const GeneralBaseNetConfigPage({super.key, required this.netNode});

  @override
  State<GeneralBaseNetConfigPage> createState() =>
      _GeneralBaseNetConfigPageState();
}

class _GeneralBaseNetConfigPageState extends State<GeneralBaseNetConfigPage> {
  /// 当前网络节点数据
  late NetNode netNode;

  @override
  void initState() {
    super.initState();
    netNode = widget.netNode;
  }

  /// 初始化控制器
  /// 基础网络配置控制器
  TextEditingController ipv4Controller = TextEditingController();
  TextEditingController devNameController = TextEditingController();
  TextEditingController mtuController = TextEditingController();

  /// P2P与中继控制器
  TextEditingController relayNetworkWhitelistController =
      TextEditingController();

  @override
  void dispose() {
    ipv4Controller.dispose();
    devNameController.dispose();
    mtuController.dispose();
    relayNetworkWhitelistController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 初始化控制器的值
    ipv4Controller.text = netNode.ipv4;
    devNameController.text = netNode.dev_name;
    mtuController.text = netNode.mtu.toString();
    relayNetworkWhitelistController.text = netNode.relay_network_whitelist;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 阻止默认的弹出行为
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // 手动处理弹出并返回netNode
          Navigator.of(context).pop(netNode);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("编辑基础网络配置"),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, netNode),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SizedBox(height: 16),
            ConfigSection(
              title: "基础网络配置",
              children: [
                ConfigTextFieldTile(
                  controller: ipv4Controller,
                  labelText: 'IPv4地址',
                  hintText: '例如: 192.168.1.100',
                  icon: Icons.network_check,
                  onChanged: (value) {
                    setState(() {
                      netNode.ipv4 = value;
                    });
                  },
                ),
                ConfigTextFieldTile(
                  controller: devNameController,
                  labelText: '设备名称',
                  icon: Icons.device_hub,
                  onChanged: (value) {
                    setState(() {
                      netNode.dev_name = value;
                    });
                  },
                ),
                ConfigSwitchTile(
                  title: '启用DHCP',
                  value: netNode.dhcp,
                  icon: Icons.settings_ethernet,
                  onChanged: (value) {
                    setState(() {
                      netNode.dhcp = value;
                    });
                  },
                ),
              ],
            ),

            // 协议与加密区域
            ConfigSection(
              title: "协议与加密",
              children: [
                ConfigDropdownTile<String>(
                  title: '默认协议',
                  subtitle: '选择首选的网络协议',
                  value: netNode.default_protocol.isEmpty ? 'tcp' : netNode.default_protocol,
                  icon: Icons.segment,
                  options: const [
                    DropdownOption(value: 'tcp', label: 'TCP'),
                    DropdownOption(value: 'udp', label: 'UDP'),
                    DropdownOption(value: 'ws', label: 'WebSocket'),
                    DropdownOption(value: 'wss', label: 'WSS'),
                    DropdownOption(value: 'quic', label: 'QUIC'),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        netNode.default_protocol = value;
                      });
                    }
                  },
                ),
                ConfigTextFieldTile(
                  controller: mtuController,
                  labelText: '最大传输单元 (MTU)',
                  icon: Icons.settings_ethernet,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      netNode.mtu = int.tryParse(value) ?? 1360;
                    });
                  },
                ),
                ConfigSwitchTile(
                  title: '启用加密',
                  value: netNode.enable_encryption,
                  icon: Icons.enhanced_encryption,
                  onChanged: (value) {
                    setState(() {
                      netNode.enable_encryption = value;
                    });
                  },
                ),
                ConfigDropdownTile<int>(
                  title: '数据压缩算法',
                  subtitle: '选择数据压缩算法类型',
                  value: netNode.data_compress_algo,
                  icon: Icons.compress,
                  options: const [
                    DropdownOption(value: 1, label: '无压缩'),
                    DropdownOption(value: 2, label: '高性能压缩'),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        netNode.data_compress_algo = value;
                      });
                    }
                  },
                ),
                ConfigSwitchTile(
                  title: '启用IPv6',
                  value: netNode.enable_ipv6,
                  icon: Icons.language,
                  onChanged: (value) {
                    setState(() {
                      netNode.enable_ipv6 = value;
                    });
                  },
                ),
              ],
            ),

            // P2P与中继区域
            ConfigSection(
              title: "P2P与中继",
              children: [
                ConfigSwitchTile(
                  title: '禁用P2P',
                  value: netNode.disable_p2p,
                  icon: Icons.block,
                  onChanged: (value) {
                    setState(() {
                      netNode.disable_p2p = value;
                    });
                  },
                ),
                ConfigSwitchTile(
                  title: '禁用UDP打洞',
                  value: netNode.disable_udp_hole_punching,
                  icon: Icons.security,
                  onChanged: (value) {
                    setState(() {
                      netNode.disable_udp_hole_punching = value;
                    });
                  },
                ),
                ConfigSwitchTile(
                  title: '中继所有对等RPC',
                  value: netNode.relay_all_peer_rpc,
                  icon: Icons.router,
                  onChanged: (value) {
                    setState(() {
                      netNode.relay_all_peer_rpc = value;
                    });
                  },
                ),
              ],
            ),

            // 高级网络功能区域
            ConfigSection(
              title: "高级网络功能",
              children: [
                ConfigSwitchTile(
                  title: '启用出口节点',
                  value: netNode.enable_exit_node,
                  icon: Icons.exit_to_app,
                  onChanged: (value) {
                    setState(() {
                      netNode.enable_exit_node = value;
                    });
                  },
                ),
                ConfigSwitchTile(
                  title: '禁用TUN',
                  value: netNode.no_tun,
                  icon: Icons.network_check,
                  onChanged: (value) {
                    setState(() {
                      netNode.no_tun = value;
                    });
                  },
                ),
                ConfigSwitchTile(
                  title: '使用SmolTCP',
                  value: netNode.use_smoltcp,
                  icon: Icons.network_wifi,
                  onChanged: (value) {
                    setState(() {
                      netNode.use_smoltcp = value;
                    });
                  },
                ),
                ConfigSwitchTile(
                  title: '绑定设备',
                  value: netNode.bind_device,
                  icon: Icons.device_hub,
                  onChanged: (value) {
                    setState(() {
                      netNode.bind_device = value;
                    });
                  },
                ),
                ConfigSwitchTile(
                  title: '接受DNS',
                  value: netNode.accept_dns,
                  icon: Icons.dns,
                  onChanged: (value) {
                    setState(() {
                      netNode.accept_dns = value;
                    });
                  },
                ),
                ConfigSwitchTile(
                  title: '私有模式',
                  value: netNode.private_mode,
                  icon: Icons.privacy_tip,
                  onChanged: (value) {
                    setState(() {
                      netNode.private_mode = value;
                    });
                  },
                ),
              ],
            ),

            // 性能与优化区域
            ConfigSection(
              title: "性能与优化",
              children: [
                ConfigSwitchTile(
                  title: '延迟优先',
                  value: netNode.latency_first,
                  icon: Icons.speed,
                  onChanged: (value) {
                    setState(() {
                      netNode.latency_first = value;
                    });
                  },
                ),
                ConfigSwitchTile(
                  title: '多线程',
                  value: netNode.multi_thread,
                  icon: Icons.memory,
                  onChanged: (value) {
                    setState(() {
                      netNode.multi_thread = value;
                    });
                  },
                ),
              ],
            ),

            // KCP/QUIC 代理区域
            ConfigSection(
              title: "KCP/QUIC 代理",
              children: [
                ConfigSwitchTile(
                  title: '启用KCP代理',
                  value: netNode.enable_kcp_proxy,
                  icon: Icons.speed,
                  onChanged: (value) {
                    setState(() {
                      netNode.enable_kcp_proxy = value;
                    });
                  },
                ),
                ConfigSwitchTile(
                  title: '禁用KCP输入',
                  value: netNode.disable_kcp_input,
                  icon: Icons.input,
                  onChanged: (value) {
                    setState(() {
                      netNode.disable_kcp_input = value;
                    });
                  },
                ),
                ConfigSwitchTile(
                  title: '启用QUIC代理',
                  value: netNode.enable_quic_proxy,
                  icon: Icons.flash_on,
                  onChanged: (value) {
                    setState(() {
                      netNode.enable_quic_proxy = value;
                    });
                  },
                ),
                ConfigSwitchTile(
                  title: '禁用QUIC输入',
                  value: netNode.disable_quic_input,
                  icon: Icons.flash_off,
                  onChanged: (value) {
                    setState(() {
                      netNode.disable_quic_input = value;
                    });
                  },
                ),
              ],
            ),

            // 网络白名单区域
            ConfigSection(
              title: "网络白名单",
              children: [
                ConfigTextFieldTile(
                  controller: relayNetworkWhitelistController,
                  labelText: '中继网络白名单',
                  icon: Icons.list,
                  onChanged: (value) {
                    setState(() {
                      netNode.relay_network_whitelist = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
