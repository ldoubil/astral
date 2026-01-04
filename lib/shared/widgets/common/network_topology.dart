import 'dart:math' as math;
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:astral/shared/utils/helpers/platform_version_parser.dart';
import 'package:flutter/material.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';

class NetworkTopologyView extends StatefulWidget {
  final List<KVNodeInfo> nodes;

  const NetworkTopologyView({super.key, required this.nodes});

  @override
  State<NetworkTopologyView> createState() => _NetworkTopologyViewState();
}

class _NetworkTopologyViewState extends State<NetworkTopologyView> {
  late NodeFlowController<_NodeData, dynamic> _controller;

  @override
  void initState() {
    super.initState();
    _updateGraph();
  }

  @override
  void didUpdateWidget(NetworkTopologyView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nodes.length != widget.nodes.length) {
      _updateGraph();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateGraph() {
    final nodes = widget.nodes;
    final newNodes = <Node<_NodeData>>[];
    final newConnections = <Connection>[];

    // 添加本机节点（左侧）
    final localIp = ServiceManager().networkConfigState.ipv4.value;
    if (localIp.isNotEmpty) {
      newNodes.add(
        Node<_NodeData>(
          id: 'local',
          type: 'local',
          position: const Offset(100, 250),
          size: const Size(200, 100),
          data: _NodeData(
            displayName: "本机",
            ip: localIp,
            type: _NodeType.local,
            platform: "本机",
            latency: 0,
          ),
          outputPorts: [
            Port(
              id: 'out',
              name: '',
              position: PortPosition.right,
              offset: Offset(2, 0),
            ),
          ],
        ),
      );
    }

    // 添加其他节点
    int playerIndex = 0;
    int serverIndex = 0;

    for (var i = 0; i < nodes.length; i++) {
      final nodeInfo = nodes[i];
      final displayName =
          nodeInfo.hostname.startsWith('PublicServer_')
              ? nodeInfo.hostname.substring('PublicServer_'.length)
              : nodeInfo.hostname;

      final isServer = nodeInfo.ipv4 == "0.0.0.0";
      final nodeId = isServer ? "server_$serverIndex" : "player_$playerIndex";

      if (isServer) {
        serverIndex++;
      } else {
        playerIndex++;
      }

      // 计算节点位置（右侧垂直分布）
      final x = 600.0;
      final y = 50.0 + (i * 130.0);

      newNodes.add(
        Node<_NodeData>(
          id: nodeId,
          type: isServer ? 'server' : 'player',
          position: Offset(x, y),
          size: const Size(200, 100),
          data: _NodeData(
            displayName: displayName,
            ip: isServer ? null : nodeInfo.ipv4,
            type: isServer ? _NodeType.server : _NodeType.player,
            platform: PlatformVersionParser.getPlatformName(nodeInfo.version),
            latency: nodeInfo.latencyMs.toInt(),
          ),
          inputPorts: [
            Port(
              id: 'in',
              name: '',
              position: PortPosition.left,
              offset: Offset(-2, 0),
            ),
          ],
        ),
      );

      // 创建从本机到该节点的连接
      if (localIp.isNotEmpty) {
        final latency = nodeInfo.latencyMs;
        newConnections.add(
          Connection(
            id: 'conn_$nodeId',
            sourceNodeId: 'local',
            sourcePortId: 'out',
            targetNodeId: nodeId,
            targetPortId: 'in',
            animationEffect: ConnectionEffects.particles,
            label: ConnectionLabel(text: '${latency}ms'),
          ),
        );
      }
    }

    // 创建新的controller
    _controller = NodeFlowController<_NodeData, dynamic>(
      nodes: newNodes,
      connections: newConnections,
      config: NodeFlowConfig(snapToGrid: false, minZoom: 0.3, maxZoom: 2.0),
    );
  }

  Color _getLatencyColor(double latency) {
    if (latency < 50) return Colors.green;
    if (latency < 100) return Colors.yellow;
    if (latency < 200) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return NodeFlowEditor<_NodeData, dynamic>(
      controller: _controller,
      theme: _buildTheme(context),
      nodeBuilder: _buildNode,
      behavior: NodeFlowBehavior.preview,
    );
  }

  Widget _buildNode(BuildContext context, Node<_NodeData> node) {
    final data = node.data;

    // 获取节点图标
    IconData icon;
    switch (data.type) {
      case _NodeType.local:
        icon = Icons.computer;
        break;
      case _NodeType.server:
        icon = Icons.cloud;
        break;
      case _NodeType.player:
        icon = Icons.person;
        break;
    }

    // 使用Card样式带标题头
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标题头
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // 内容体
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Theme.of(context).colorScheme.outline),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.ip != null)
                Row(
                  children: [
                    Icon(
                      Icons.language,
                      size: 13,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 4),
                    Text(data.ip!, style: const TextStyle(fontSize: 11)),
                  ],
                ),
              if (data.ip != null) const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.devices,
                    size: 13,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      data.platform,
                      style: const TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (data.latency > 0) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.speed,
                      size: 13,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${data.latency}ms',
                      style: TextStyle(
                        fontSize: 11,
                        color: _getLatencyColor(data.latency.toDouble()),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  NodeFlowTheme _buildTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return (isDark ? NodeFlowTheme.dark : NodeFlowTheme.light).copyWith(
      backgroundColor: Theme.of(context).colorScheme.surface,
      connectionTheme: ConnectionTheme.light.copyWith(
        style: ConnectionStyles.bezier,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
        strokeWidth: 2.5,
        animationEffect: ConnectionEffects.particles,
      ),
      connectionAnimationDuration: const Duration(seconds: 3),
      gridTheme: GridTheme.light.copyWith(
        style: GridStyles.dots,
        size: 20.0,
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
      portTheme: PortTheme.light.copyWith(
        size: const Size.square(8.0),
        color: Theme.of(context).colorScheme.primary,
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
  final int latency;

  _NodeData({
    required this.displayName,
    this.ip,
    required this.type,
    required this.platform,
    required this.latency,
  });
}
