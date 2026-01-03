import 'package:astral/k/services/service_manager.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:astral/utils/platform_version_parser.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

class NetworkTopologyView extends StatefulWidget {
  const NetworkTopologyView({super.key});

  @override
  State<NetworkTopologyView> createState() => _NetworkTopologyViewState();
}

class _NetworkTopologyViewState extends State<NetworkTopologyView> {
  final Graph graph = Graph()..isTree = true;
  late BuchheimWalkerAlgorithm algorithm;

  // 用于存储节点ID和节点信息的映射
  final Map<String, Node> nodeMap = {};
  final Map<String, _NodeData> nodeDataMap = {};
  int _previousNodeCount = 0;

  @override
  void initState() {
    super.initState();
    algorithm = BuchheimWalkerAlgorithm(
      BuchheimWalkerConfiguration()
        ..siblingSeparation = 50
        ..levelSeparation = 100
        ..subtreeSeparation = 50
        ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM,
      TreeEdgeRenderer(BuchheimWalkerConfiguration()),
    );
  }

  void _buildGraph(List<KVNodeInfo> nodes) {
    graph.edges.clear();
    graph.nodes.clear();
    nodeMap.clear();
    nodeDataMap.clear();

    // 首先添加本机节点
    final localIp = ServiceManager().networkConfigState.ipv4.value;
    if (localIp != null && localIp.isNotEmpty) {
      final localNode = Node.Id("local");
      nodeMap["local"] = localNode;
      nodeDataMap["local"] = _NodeData(
        displayName: "本机",
        ip: localIp,
        type: _NodeType.local,
        platform: "本机",
        latency: 0,
      );
      graph.addNode(localNode);
    }

    // 添加所有节点
    for (var nodeInfo in nodes) {
      final displayName =
          nodeInfo.hostname.startsWith('PublicServer_')
              ? nodeInfo.hostname.substring('PublicServer_'.length)
              : nodeInfo.hostname;

      final nodeId =
          nodeInfo.ipv4 == "0.0.0.0"
              ? "server_$displayName"
              : "player_${nodeInfo.ipv4}";

      final node = Node.Id(nodeId);
      nodeMap[nodeId] = node;

      final isServer = nodeInfo.ipv4 == "0.0.0.0";
      nodeDataMap[nodeId] = _NodeData(
        displayName: displayName,
        ip: isServer ? null : nodeInfo.ipv4,
        type: isServer ? _NodeType.server : _NodeType.player,
        platform: PlatformVersionParser.getPlatformName(nodeInfo.version),
        latency: nodeInfo.latencyMs,
      );

      graph.addNode(node);

      // 建立连接关系
      if (nodeMap.containsKey("local")) {
        final latency = nodeInfo.latencyMs;
        final color = _getLatencyColor(latency);

        if (isServer || nodeInfo.cost == 1) {
          // 服务器或直连节点直接连到本机
          graph.addEdge(
            nodeMap["local"]!,
            node,
            paint:
                Paint()
                  ..color = color
                  ..strokeWidth = 3
                  ..style = PaintingStyle.stroke,
          );
        } else if (nodeInfo.cost >= 2) {
          // 中转节点，找服务器节点连接
          final serverNode = nodeMap.values.firstWhere(
            (n) => (n.key!.value as String).startsWith('server_'),
            orElse: () => nodeMap["local"]!,
          );
          graph.addEdge(
            serverNode,
            node,
            paint:
                Paint()
                  ..color = color
                  ..strokeWidth = 3
                  ..style = PaintingStyle.stroke,
          );
        }
      }
    }
  }

  Color _getLatencyColor(double latency) {
    if (latency < 50) {
      return const Color(0xFF4CAF50); // 绿色
    } else if (latency < 100) {
      return const Color(0xFFFFA726); // 橙色
    } else if (latency < 200) {
      return const Color(0xFFFF7043); // 深橙色
    } else {
      return const Color(0xFFE53935); // 红色
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final netStatus = ServiceManager().connectionState.netStatus.value;

    if (netStatus == null || netStatus.nodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hub_outlined,
              size: 64,
              color: colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无网络拓扑数据',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请先连接到房间',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
          ],
        ),
      );
    }

    // 仅在节点数量变化时重建图形
    if (_previousNodeCount != netStatus.nodes.length) {
      _buildGraph(netStatus.nodes);
      _previousNodeCount = netStatus.nodes.length;
    }

    return Stack(
      children: [
        InteractiveViewer(
          constrained: false,
          boundaryMargin: const EdgeInsets.all(500),
          minScale: 0.01,
          maxScale: 10.0,
          child: GraphView(
            graph: graph,
            algorithm: algorithm,
            paint:
                Paint()
                  ..color = colorScheme.outline
                  ..strokeWidth = 2
                  ..style = PaintingStyle.stroke,
            builder: (Node node) {
              final nodeId = node.key!.value as String;
              final nodeData = nodeDataMap[nodeId]!;

              return GestureDetector(
                onPanUpdate: (details) {
                  // 更新节点位置
                  setState(() {
                    final position = node.position;
                    node.position = Offset(
                      position.dx + details.delta.dx,
                      position.dy + details.delta.dy,
                    );
                  });
                },
                child: _buildNodeCard(nodeData, colorScheme),
              );
            },
          ),
        ),
        // 图例
        Positioned(top: 16, right: 16, child: _buildLegend(colorScheme)),
      ],
    );
  }

  Widget _buildNodeCard(_NodeData data, ColorScheme colorScheme) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String typeLabel;

    switch (data.type) {
      case _NodeType.local:
        bgColor = const Color(0xFF2196F3); // 蓝色
        textColor = Colors.white;
        icon = Icons.computer;
        typeLabel = "本机";
        break;
      case _NodeType.server:
        bgColor = const Color(0xFF9C27B0); // 紫色
        textColor = Colors.white;
        icon = Icons.dns;
        typeLabel = "服务器";
        break;
      case _NodeType.player:
        bgColor = const Color(0xFF4CAF50); // 绿色
        textColor = Colors.white;
        icon = Icons.person;
        typeLabel = "玩家";
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 类型标签
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              typeLabel,
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 图标和名称
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 6),
              Text(
                data.displayName,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          // IP地址（如果有）
          if (data.ip != null) ...[
            const SizedBox(height: 4),
            Text(
              data.ip!,
              style: TextStyle(color: textColor.withOpacity(0.9), fontSize: 11),
            ),
          ],
          // 平台信息
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PlatformVersionParser.getPlatformIcon(data.platform),
                color: textColor.withOpacity(0.9),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                data.platform,
                style: TextStyle(
                  color: textColor.withOpacity(0.9),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          // 延迟（非本机）
          if (data.type != _NodeType.local) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getLatencyColor(data.latency),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${data.latency.toStringAsFixed(0)}ms',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegend(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '图例',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          _buildLegendItem('< 50ms', const Color(0xFF4CAF50)),
          _buildLegendItem('50-100ms', const Color(0xFFFFA726)),
          _buildLegendItem('100-200ms', const Color(0xFFFF7043)),
          _buildLegendItem('> 200ms', const Color(0xFFE53935)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 24, height: 3, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

enum _NodeType { local, server, player }

class _NodeData {
  final String displayName;
  final String? ip;
  final _NodeType type;
  final String platform;
  final double latency;

  _NodeData({
    required this.displayName,
    this.ip,
    required this.type,
    required this.platform,
    required this.latency,
  });
}
