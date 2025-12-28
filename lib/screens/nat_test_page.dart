import 'package:astral/src/rust/api/nat_test.dart';
import 'package:flutter/material.dart';

/// NAT 类型检测页面（RFC 5780）
class NatTestPage extends StatefulWidget {
  const NatTestPage({super.key});

  @override
  State<NatTestPage> createState() => _NatTestPageState();
}

class _NatTestPageState extends State<NatTestPage> {
  NetworkTestResult? _testResult;
  bool _isTestingNat = false;
  String _stunServer = 'stun.hot-chilli.net';
  
  final List<String> _stunServers = [
    'stun.hot-chilli.net',
    'stun.miwifi.com',
    'stun.l.google.com',
  ];

  @override
  void initState() {
    super.initState();
    // 进入页面后自动开始测试
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _testNetwork();
    });
  }

  Future<void> _testNetwork() async {
    if (_isTestingNat) return;

    setState(() {
      _isTestingNat = true;
      _testResult = null;
    });

    try {
      // 调用 Rust 的 NAT 检测函数（RFC 5780）
      final result = await testNetworkConnectivity(
        stunServer: _stunServer,
      );

      if (mounted) {
        setState(() {
          _testResult = result;
          _isTestingNat = false;
        });
      }
    } catch (e) {
      print('❌ NAT 检测失败: $e');
      if (mounted) {
        setState(() {
          _isTestingNat = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('NAT 检测失败: $e'),
            action: SnackBarAction(label: '重试', onPressed: _testNetwork),
          ),
        );
      }
    }
  }

  String _getNatTypeDescription(String natType) {
    if (natType.contains('完全锥形') || natType.contains('Full Cone')) {
      return '最佳连接。任何主机都可发送数据。';
    } else if (natType.contains('受限锥形') || natType.contains('Restricted Cone')) {
      return '良好连接。只有联系过的主机可发送。';
    } else if (natType.contains('端口受限') || natType.contains('Port Restricted')) {
      return '较好连接。常见类型，部分联机可用。';
    } else if (natType.contains('对称型') && !natType.contains('防火墙')) {
      return '可能影响P2P连接，需要中继服务器。';
    } else if (natType.contains('防火墙') || natType.contains('Firewall')) {
      return 'UDP流量受限。请检查防火墙。';
    } else if (natType.contains('被阻止') || natType.contains('Blocked')) {
      return 'UDP被阻止。请检查路由器设置。';
    } else if (natType.contains('开放互联网') || natType.contains('Open Internet')) {
      return '理想状态！无NAT，直连互联网。';
    } else {
      return '无法确定。尝试更换STUN服务器。';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NAT 类型检测'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 测试状态
            if (_isTestingNat)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('正在检测中...', style: Theme.of(context).textTheme.titleSmall),
                            Text(
                              '使用 RFC 5780 STUN 协议',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_testResult != null)
              // 检测结果
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // IPv4 结果
                      _buildCompactResult(
                        'IPv4',
                        _testResult!.natTypeV4,
                        _testResult!.ipv4Latency,
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      // IPv6 结果
                      _buildCompactResult(
                        'IPv6',
                        _testResult!.natTypeV6,
                        _testResult!.ipv6Latency,
                      ),
                    ],
                  ),
                ),
              )
            else
              // 错误状态
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 16),
                      Text('检测失败', style: Theme.of(context).textTheme.titleSmall),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // STUN 服务器选择和重新测试按钮
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _stunServer,
                    decoration: InputDecoration(
                      labelText: 'STUN 服务器',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _stunServers.map((server) {
                      return DropdownMenuItem(value: server, child: Text(server));
                    }).toList(),
                    onChanged: _isTestingNat
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _stunServer = value);
                            }
                          },
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _isTestingNat ? null : _testNetwork,
                  icon: const Icon(Icons.refresh),
                  label: const Text('检测'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactResult(String protocol, String natType, int latency) {
    final color = _getNatTypeColor(natType);
    final icon = _getNatTypeIcon(natType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 协议和延迟行
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                protocol,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            ),
            const Spacer(),
            Icon(Icons.speed, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              latency >= 0 ? '${latency}ms' : '-',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // NAT 类型行
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                natType,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // 描述
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(
            _getNatTypeDescription(natType),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }

  IconData _getNatTypeIcon(String natType) {
    if (natType.contains('完全锥形') ||
        natType.contains('Full Cone') ||
        natType.contains('开放互联网') ||
        natType.contains('Open Internet')) {
      return Icons.check_circle;
    } else if (natType.contains('受限锥形') ||
        natType.contains('Restricted Cone') ||
        natType.contains('端口受限') ||
        natType.contains('Port Restricted')) {
      return Icons.info;
    } else if (natType.contains('对称型') || natType.contains('Symmetric')) {
      return Icons.warning;
    } else {
      return Icons.error;
    }
  }

  Color _getNatTypeColor(String natType) {
    if (natType.contains('完全锥形') ||
        natType.contains('Full Cone') ||
        natType.contains('开放互联网') ||
        natType.contains('Open Internet')) {
      return Colors.green;
    } else if (natType.contains('受限锥形') ||
        natType.contains('Restricted Cone') ||
        natType.contains('端口受限') ||
        natType.contains('Port Restricted')) {
      return Colors.blue;
    } else if (natType.contains('对称型') || natType.contains('Symmetric')) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
