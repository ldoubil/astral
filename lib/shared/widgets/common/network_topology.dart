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
  NodeFlowController<_NodeData, dynamic>? _controller;
  List<String> _lastNodeIds = []; // 记录上次的节点ID列表

  @override
  void initState() {
    super.initState();
    _updateGraph();
  }

  @override
  void didUpdateWidget(NetworkTopologyView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 只在节点数量或ID列表发生变化时才更新
    final currentNodeIds = widget.nodes.map((n) => n.ipv4).toList();
    if (currentNodeIds.length != _lastNodeIds.length ||
        !_listEquals(currentNodeIds, _lastNodeIds)) {
      _updateGraph();
    }
  }

  // 比较两个列表是否相等
  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _updateGraph() {
    final nodes = widget.nodes;
    final newNodes = <Node<_NodeData>>[];
    final newConnections = <Connection>[];

    // 获取本机IP
    final localIp = ServiceManager().networkConfigState.ipv4.value;

    // 找到本机节点
    KVNodeInfo? localNode;
    int? localNodeIndex;
    for (var i = 0; i < nodes.length; i++) {
      if (nodes[i].ipv4 == localIp) {
        localNode = nodes[i];
        localNodeIndex = i;
        break;
      }
    }

    // 标准化节点名称（去掉 PublicServer_ 前缀）
    String _normalizeNodeName(String hostname) {
      return hostname.startsWith('PublicServer_')
          ? hostname.substring('PublicServer_'.length)
          : hostname;
    }

    // 用于跟踪所有节点 - key是标准化后的节点名称，value是节点ID
    final Map<String, String> nodeIdsByName = {};

    // 如果找到了本机节点，将其添加为中心节点
    String? localNodeId;
    if (localNode != null && localIp.isNotEmpty) {
      localNodeId = 'local';
      final displayName = _normalizeNodeName(localNode.hostname);
      nodeIdsByName[displayName] = localNodeId;

      newNodes.add(
        Node<_NodeData>(
          id: localNodeId,
          type: 'local',
          position: const Offset(100, 250),
          data: _NodeData(
            displayName: displayName,
            ip: localIp,
            type: _NodeType.local,
            platform: PlatformVersionParser.getPlatformName(localNode.version),
            latency: 0,
          ),
          inputPorts: [
            Port(
              id: 'in',
              name: '',
              position: PortPosition.left,
              offset: Offset(-2, 0),
            ),
          ],
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

    // 添加其他节点（排除本机）
    int playerIndex = 0;
    int serverIndex = 0;

    for (var i = 0; i < nodes.length; i++) {
      // 跳过本机节点
      if (i == localNodeIndex) continue;

      final nodeInfo = nodes[i];
      final displayName = _normalizeNodeName(nodeInfo.hostname);

      // 检查这个节点名称是否已经存在
      if (nodeIdsByName.containsKey(displayName)) {
        continue; // 跳过重复的节点
      }

      final isServer = nodeInfo.ipv4 == "0.0.0.0";
      final nodeId = isServer ? "server_$serverIndex" : "player_$playerIndex";

      nodeIdsByName[displayName] = nodeId;

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

      // 创建连接（包括中转路径）
      if (localNodeId != null && nodeInfo.hops.isNotEmpty) {
        // 如果有中转路径，创建完整的中转链
        String previousNodeId = localNodeId;
        String previousPortId = 'out';

        for (var hopIndex = 0; hopIndex < nodeInfo.hops.length; hopIndex++) {
          final hop = nodeInfo.hops[hopIndex];
          final hopDisplayName = _normalizeNodeName(
            hop.nodeName.isNotEmpty ? hop.nodeName : "中转_${hop.targetIp}",
          );

          // 检查这个中转节点是否是本机或目标节点
          String hopId;
          if (hopDisplayName == displayName) {
            // 如果中转节点就是目标节点，跳过这个hop，直接用目标节点
            hopId = nodeId;
          } else if (nodeIdsByName.containsKey(hopDisplayName)) {
            // 复用已存在的节点
            hopId = nodeIdsByName[hopDisplayName]!;
          } else {
            // 创建新的中转节点
            hopId =
                'hop_${hopDisplayName.replaceAll('.', '_').replaceAll(' ', '_')}';
            nodeIdsByName[hopDisplayName] = hopId;

            final hopX = 100.0 + (200.0 * (hopIndex + 1));
            final hopY = 50.0 + (i * 130.0);

            newNodes.add(
              Node<_NodeData>(
                id: hopId,
                type: 'relay',
                position: Offset(hopX, hopY),
                data: _NodeData(
                  displayName: hopDisplayName,
                  ip: hop.targetIp,
                  type: _NodeType.relay,
                  platform: "中转节点",
                  latency: hop.latencyMs.toInt(),
                ),
                inputPorts: [
                  Port(
                    id: 'in',
                    name: '',
                    position: PortPosition.left,
                    offset: Offset(-2, 0),
                  ),
                ],
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

          // 避免创建自己到自己的连接
          if (previousNodeId != hopId) {
            // 创建从上一个节点到这个中转节点的连接（避免重复连接）
            final connId = 'conn_${previousNodeId}_to_$hopId';
            if (!newConnections.any((c) => c.id == connId)) {
              newConnections.add(
                Connection(
                  id: connId,
                  sourceNodeId: previousNodeId,
                  sourcePortId: previousPortId,
                  targetNodeId: hopId,
                  targetPortId: 'in',
                  animationEffect: ConnectionEffects.particles,
                  label: ConnectionLabel(
                    text: '${hop.latencyMs.toStringAsFixed(1)}ms',
                  ),
                ),
              );
            }
          }

          previousNodeId = hopId;
          previousPortId = 'out';
        }

        // 最后从最后一个中转节点连接到目标节点（避免自己连接自己）
        if (previousNodeId != nodeId) {
          newConnections.add(
            Connection(
              id: 'conn_${previousNodeId}_to_$nodeId',
              sourceNodeId: previousNodeId,
              sourcePortId: previousPortId,
              targetNodeId: nodeId,
              targetPortId: 'in',
              animationEffect: ConnectionEffects.particles,
              label: ConnectionLabel(
                text: '${nodeInfo.latencyMs.toStringAsFixed(1)}ms',
              ),
            ),
          );
        }
      } else if (localNodeId != null) {
        // 如果没有中转路径，直接连接
        newConnections.add(
          Connection(
            id: 'conn_$nodeId',
            sourceNodeId: localNodeId,
            sourcePortId: 'out',
            targetNodeId: nodeId,
            targetPortId: 'in',
            animationEffect: ConnectionEffects.particles,
            label: ConnectionLabel(
              text: '${nodeInfo.latencyMs.toStringAsFixed(1)}ms',
            ),
          ),
        );
      }
    }

    // 更新节点ID列表记录
    _lastNodeIds = widget.nodes.map((n) => n.ipv4).toList();

    // 立即释放旧的controller
    _controller?.dispose();

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
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // 使用节点数量作为key，更稳定
    return NodeFlowEditor<_NodeData, dynamic>(
      key: ValueKey(
        'topology_${_lastNodeIds.length}_${_lastNodeIds.join('_')}',
      ),
      controller: _controller!,
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
      case _NodeType.relay:
        icon = Icons.router;
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
            mainAxisSize: MainAxisSize.min,
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

enum _NodeType { local, server, player, relay }

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
