import 'package:astral/models/net_node.dart';
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

  /// 协议与加密控制器
  TextEditingController defaultProtocolController = TextEditingController();
  TextEditingController dataCompressAlgoController = TextEditingController();

  /// P2P与中继控制器
  TextEditingController relayNetworkWhitelistController =
      TextEditingController();

  @override
  void dispose() {
    ipv4Controller.dispose();
    devNameController.dispose();
    mtuController.dispose();
    defaultProtocolController.dispose();
    dataCompressAlgoController.dispose();
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
    defaultProtocolController.text = netNode.default_protocol;
    dataCompressAlgoController.text = netNode.data_compress_algo.toString();
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
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                "基础网络配置",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Card(
              child: Column(
                children: [
                  // IPv4地址
                  ListTile(
                    leading: Icon(
                      Icons.network_check,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: TextFormField(
                      controller: ipv4Controller,
                      decoration: InputDecoration(
                        labelText: 'IPv4地址',
                        border: OutlineInputBorder(),
                        hintText: '例如: 192.168.1.100',
                      ),
                      keyboardType: TextInputType.text,
                      onChanged: (value) {
                        setState(() {
                          netNode.ipv4 = value;
                        });
                      },
                    ),
                  ),
                  // 设备名称
                  ListTile(
                    leading: Icon(
                      Icons.device_hub,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: TextFormField(
                      controller: devNameController,
                      decoration: InputDecoration(
                        labelText: '设备名称',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          netNode.dev_name = value;
                        });
                      },
                    ),
                  ),
                  // 最大传输单元
                  ListTile(
                    leading: Icon(
                      Icons.settings_ethernet,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: TextFormField(
                      controller: mtuController,
                      decoration: InputDecoration(
                        labelText: '最大传输单元 (MTU)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          netNode.mtu = int.tryParse(value) ?? 1360;
                        });
                      },
                    ),
                  ),
                  // 启用IPv6
                  SwitchListTile(
                    title: Text('启用IPv6'),
                    value: netNode.enable_ipv6,
                    onChanged: (value) {
                      setState(() {
                        netNode.enable_ipv6 = value;
                      });
                    },
                    secondary: Icon(
                      Icons.language,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  // 启用DHCP
                  SwitchListTile(
                    title: Text('启用DHCP'),
                    value: netNode.dhcp,
                    onChanged: (value) {
                      setState(() {
                        netNode.dhcp = value;
                      });
                    },
                    secondary: Icon(
                      Icons.settings_ethernet,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
              child: Text(
                "协议与加密",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Card(
              child: Column(
                children: [
                  // 默认协议
                  ListTile(
                    leading: Icon(
                      Icons.segment,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: TextFormField(
                      controller: defaultProtocolController,
                      decoration: InputDecoration(
                        labelText: '默认协议',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          netNode.default_protocol = value;
                        });
                      },
                    ),
                  ),
                  // 启用加密
                  SwitchListTile(
                    title: Text('启用加密'),
                    value: netNode.enable_encryption,
                    onChanged: (value) {
                      setState(() {
                        netNode.enable_encryption = value;
                      });
                    },
                    secondary: Icon(
                      Icons.enhanced_encryption,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  // 数据压缩算法
                  ListTile(
                    leading: Icon(
                      Icons.compress,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: TextFormField(
                      controller: dataCompressAlgoController,
                      decoration: InputDecoration(
                        labelText: '数据压缩算法',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          netNode.data_compress_algo = int.tryParse(value) ?? 1;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
              child: Text(
                "P2P与中继",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Card(
              child: Column(
                children: [
                  // 禁用P2P
                  SwitchListTile(
                    title: Text('禁用P2P'),
                    value: netNode.disable_p2p,
                    onChanged: (value) {
                      setState(() {
                        netNode.disable_p2p = value;
                      });
                    },
                    secondary: Icon(
                      Icons.block,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SwitchListTile(
                    title: Text('禁用UDP打洞'),
                    value: netNode.disable_udp_hole_punching,
                    onChanged: (value) {
                      setState(() {
                        netNode.disable_udp_hole_punching = value;
                      });
                    },
                    secondary: Icon(
                      Icons.security,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SwitchListTile(
                    title: Text('中继所有对等RPC'),
                    value: netNode.relay_all_peer_rpc,
                    onChanged: (value) {
                      setState(() {
                        netNode.relay_all_peer_rpc = value;
                      });
                    },
                    secondary: Icon(
                      Icons.router,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
              child: Text(
                "高级网络功能",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Card(
              child: Column(
                children: [
                  // 启用出口节点
                  SwitchListTile(
                    title: Text('启用出口节点'),
                    value: netNode.enable_exit_node,
                    onChanged: (value) {
                      setState(() {
                        netNode.enable_exit_node = value;
                      });
                    },
                    secondary: Icon(
                      Icons.exit_to_app,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SwitchListTile(
                    title: Text('禁用TUN'),
                    value: netNode.no_tun,
                    onChanged: (value) {
                      setState(() {
                        netNode.no_tun = value;
                      });
                    },
                    secondary: Icon(
                      Icons.network_check,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SwitchListTile(
                    title: Text('使用SmolTCP'),
                    value: netNode.use_smoltcp,
                    onChanged: (value) {
                      setState(() {
                        netNode.use_smoltcp = value;
                      });
                    },
                    secondary: Icon(
                      Icons.network_wifi,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SwitchListTile(
                    title: Text('绑定设备'),
                    value: netNode.bind_device,
                    onChanged: (value) {
                      setState(() {
                        netNode.bind_device = value;
                      });
                    },
                    secondary: Icon(
                      Icons.device_hub,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SwitchListTile(
                    title: Text('接受DNS'),
                    value: netNode.accept_dns,
                    onChanged: (value) {
                      setState(() {
                        netNode.accept_dns = value;
                      });
                    },
                    secondary: Icon(
                      Icons.dns,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SwitchListTile(
                    title: Text('私有模式'),
                    value: netNode.private_mode,
                    onChanged: (value) {
                      setState(() {
                        netNode.private_mode = value;
                      });
                    },
                    secondary: Icon(
                      Icons.privacy_tip,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
              child: Text(
                "性能与优化",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Card(
              child: Column(
                children: [
                  // 延迟优先
                  SwitchListTile(
                    title: Text('延迟优先'),
                    value: netNode.latency_first,
                    onChanged: (value) {
                      setState(() {
                        netNode.latency_first = value;
                      });
                    },
                    secondary: Icon(
                      Icons.speed,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SwitchListTile(
                    title: Text('多线程'),
                    value: netNode.multi_thread,
                    onChanged: (value) {
                      setState(() {
                        netNode.multi_thread = value;
                      });
                    },
                    secondary: Icon(
                      Icons.memory,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
              child: Text(
                "KCP/QUIC 代理",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Card(
              child: Column(
                children: [
                  // 启用KCP代理
                  SwitchListTile(
                    title: Text('启用KCP代理'),
                    value: netNode.enable_kcp_proxy,
                    onChanged: (value) {
                      setState(() {
                        netNode.enable_kcp_proxy = value;
                      });
                    },
                    secondary: Icon(
                      Icons.speed,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SwitchListTile(
                    title: Text('禁用KCP输入'),
                    value: netNode.disable_kcp_input,
                    onChanged: (value) {
                      setState(() {
                        netNode.disable_kcp_input = value;
                      });
                    },
                    secondary: Icon(
                      Icons.input,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SwitchListTile(
                    title: Text('禁用中继KCP'),
                    value: netNode.disable_relay_kcp,
                    onChanged: (value) {
                      setState(() {
                        netNode.disable_relay_kcp = value;
                      });
                    },
                    secondary: Icon(
                      Icons.sync_disabled_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SwitchListTile(
                    title: Text('启用QUIC代理'),
                    value: netNode.enable_quic_proxy,
                    onChanged: (value) {
                      setState(() {
                        netNode.enable_quic_proxy = value;
                      });
                    },
                    secondary: Icon(
                      Icons.speed,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SwitchListTile(
                    title: Text('禁用QUIC输入'),
                    value: netNode.disable_quic_input,
                    onChanged: (value) {
                      setState(() {
                        netNode.disable_quic_input = value;
                      });
                    },
                    secondary: Icon(
                      Icons.input,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ); // 闭合PopScope
  } // 闭合PopScope
}
