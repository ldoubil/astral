/// 简单的Connection模型，用于转发规则
class ForwardingConnection {
  final bool enabled;
  final List<ForwardingRule> connections;

  ForwardingConnection({required this.enabled, required this.connections});
}

class ForwardingRule {
  final String bindAddr;
  final String dstAddr;
  final String proto; // 'tcp', 'udp', 'all'

  ForwardingRule({
    required this.bindAddr,
    required this.dstAddr,
    required this.proto,
  });
}
