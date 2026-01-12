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

  @override
  void initState() {
    super.initState();
    _syncGraph();
  }

  @override
  void didUpdateWidget(NetworkTopologyView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncGraph();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _syncGraph() {
    final localIp = ServiceManager().networkConfigState.ipv4.value;
    final existingPositions = <String, Offset>{};
    if (_controller != null) {
      for (final nodeId in _controller!.nodeIds) {
        final node = _controller!.getNode(nodeId);
        if (node != null) existingPositions[nodeId] = node.position.value;
      }
    }

    final model = _buildGraphModel(
      widget.nodes,
      localIp: localIp,
      existingPositions: existingPositions,
    );

    if (_controller == null) {
      _controller = NodeFlowController<_NodeData, dynamic>(
        nodes: model.nodes.values.toList(),
        connections: model.connections.values.toList(),
        config: NodeFlowConfig(snapToGrid: false, minZoom: 0.3, maxZoom: 2.0),
      );
      return;
    }

    _applyGraphDiff(model);
  }

  String _safeId(String raw) {
    return raw.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
  }

  String _normalizeNodeName(String hostname) {
    return hostname.startsWith('PublicServer_')
        ? hostname.substring('PublicServer_'.length)
        : hostname;
  }

  String _nodeFallbackKey(KVNodeInfo nodeInfo) {
    if (nodeInfo.ipv4.isNotEmpty) return 'ip_${nodeInfo.ipv4}';
    return 'name_${_normalizeNodeName(nodeInfo.hostname)}';
  }

  String _hopFallbackKey(NodeHopStats hop) {
    if (hop.targetIp.isNotEmpty) return 'ip_${hop.targetIp}';
    return 'name_${_normalizeNodeName(hop.nodeName)}';
  }

  String _nodeIdForPeerId(int peerId, String fallbackKey) {
    if (peerId > 0) return 'peer_$peerId';
    return _safeId(fallbackKey);
  }

  String _connectionId(String sourceId, String targetId) {
    return 'conn_${sourceId}_to_$targetId';
  }

  _GraphModel _buildGraphModel(
    List<KVNodeInfo> nodes, {
    required String localIp,
    required Map<String, Offset> existingPositions,
  }) {
    final newNodes = <String, Node<_NodeData>>{};
    final newConnections = <String, Connection>{};
    final nodeIdsByPeerId = <int, String>{};
    final nodeRowIndex = <String, int>{};

    KVNodeInfo? localNode;
    for (final node in nodes) {
      if (node.ipv4 == localIp && localIp.isNotEmpty) {
        localNode = node;
        break;
      }
    }

    final nonLocalNodes = <KVNodeInfo>[];
    for (final node in nodes) {
      if (localNode != null && node.peerId == localNode.peerId) continue;
      nonLocalNodes.add(node);
    }
    nonLocalNodes.sort((a, b) => a.peerId.compareTo(b.peerId));

    int rowIndex = 0;
    for (final nodeInfo in nodes) {
      final isLocal =
          localNode != null && nodeInfo.peerId == localNode.peerId;
      final isServer =
          nodeInfo.hostname.startsWith('PublicServer_') ||
          nodeInfo.ipv4 == "0.0.0.0";
      final nodeId = _nodeIdForPeerId(
        nodeInfo.peerId,
        _nodeFallbackKey(nodeInfo),
      );
      nodeIdsByPeerId[nodeInfo.peerId] = nodeId;

      final displayName = _normalizeNodeName(nodeInfo.hostname);
      Offset position;
      if (existingPositions.containsKey(nodeId)) {
        position = existingPositions[nodeId]!;
      } else if (isLocal) {
        position = const Offset(100, 250);
      } else {
        final index = nonLocalNodes.indexWhere(
          (n) => n.peerId == nodeInfo.peerId,
        );
        final effectiveIndex = index >= 0 ? index : rowIndex;
        position = Offset(600.0, 50.0 + (effectiveIndex * 130.0));
        nodeRowIndex[nodeId] = effectiveIndex;
        rowIndex = math.max(rowIndex, effectiveIndex + 1);
      }

      newNodes[nodeId] = Node<_NodeData>(
        id: nodeId,
        type: isLocal
            ? 'local'
            : (isServer ? 'server' : 'player'),
        position: position,
        data: _NodeData(
          displayName: displayName,
          ip: isServer && !isLocal ? null : nodeInfo.ipv4,
          type: isLocal
              ? _NodeType.local
              : (isServer ? _NodeType.server : _NodeType.player),
          platform: PlatformVersionParser.getPlatformName(nodeInfo.version),
          latency: isLocal ? 0 : nodeInfo.latencyMs.toInt(),
        ),
        inputPorts: [
          Port(
            id: 'in',
            name: '',
            position: PortPosition.left,
            offset: const Offset(-2, 0),
          ),
        ],
        outputPorts: [
          Port(
            id: 'out',
            name: '',
            position: PortPosition.right,
            offset: const Offset(2, 0),
          ),
        ],
      );
    }

    final localNodeId =
        localNode != null ? nodeIdsByPeerId[localNode.peerId] : null;

    if (localNodeId == null) {
      return _GraphModel(newNodes, newConnections);
    }

    for (final nodeInfo in nodes) {
      if (localNode != null && nodeInfo.peerId == localNode.peerId) continue;
      final targetId = nodeIdsByPeerId[nodeInfo.peerId] ??
          _nodeIdForPeerId(nodeInfo.peerId, _nodeFallbackKey(nodeInfo));

      if (nodeInfo.hops.isNotEmpty) {
        String previousNodeId = localNodeId;
        for (var hopIndex = 0; hopIndex < nodeInfo.hops.length; hopIndex++) {
          final hop = nodeInfo.hops[hopIndex];
          final hopId = nodeIdsByPeerId[hop.peerId] ??
              _nodeIdForPeerId(hop.peerId, _hopFallbackKey(hop));

          if (!newNodes.containsKey(hopId)) {
            final displayName = _normalizeNodeName(
              hop.nodeName.isNotEmpty ? hop.nodeName : "中转_${hop.targetIp}",
            );
            final row = nodeRowIndex[targetId] ?? 0;
            final position = existingPositions[hopId] ??
                Offset(100.0 + (200.0 * (hopIndex + 1)), 50.0 + (row * 130.0));
            newNodes[hopId] = Node<_NodeData>(
              id: hopId,
              type: 'relay',
              position: position,
              data: _NodeData(
                displayName: displayName,
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
                  offset: const Offset(-2, 0),
                ),
              ],
              outputPorts: [
                Port(
                  id: 'out',
                  name: '',
                  position: PortPosition.right,
                  offset: const Offset(2, 0),
                ),
              ],
            );
          }

          if (previousNodeId != hopId) {
            final connId = _connectionId(previousNodeId, hopId);
            newConnections[connId] = Connection(
              id: connId,
              sourceNodeId: previousNodeId,
              sourcePortId: 'out',
              targetNodeId: hopId,
              targetPortId: 'in',
              animationEffect: ConnectionEffects.particles,
              label: ConnectionLabel(
                text: '${hop.latencyMs.toStringAsFixed(1)}ms',
              ),
            );
          }

          previousNodeId = hopId;
        }

        if (previousNodeId != targetId) {
          final connId = _connectionId(previousNodeId, targetId);
          newConnections[connId] = Connection(
            id: connId,
            sourceNodeId: previousNodeId,
            sourcePortId: 'out',
            targetNodeId: targetId,
            targetPortId: 'in',
            animationEffect: ConnectionEffects.particles,
            label: ConnectionLabel(
              text: '${nodeInfo.latencyMs.toStringAsFixed(1)}ms',
            ),
          );
        }
      } else {
        if (localNodeId != targetId) {
          final connId = _connectionId(localNodeId, targetId);
          newConnections[connId] = Connection(
            id: connId,
            sourceNodeId: localNodeId,
            sourcePortId: 'out',
            targetNodeId: targetId,
            targetPortId: 'in',
            animationEffect: ConnectionEffects.particles,
            label: ConnectionLabel(
              text: '${nodeInfo.latencyMs.toStringAsFixed(1)}ms',
            ),
          );
        }
      }
    }

    return _GraphModel(newNodes, newConnections);
  }

  void _applyGraphDiff(_GraphModel model) {
    final controller = _controller!;
    final desiredNodeIds = model.nodes.keys.toSet();
    final currentNodeIds = controller.nodeIds.toSet();

    for (final nodeId in currentNodeIds.difference(desiredNodeIds)) {
      controller.removeNode(nodeId);
    }

    for (final entry in model.nodes.entries) {
      final desiredNode = entry.value;
      final existingNode = controller.getNode(entry.key);
      if (existingNode == null) {
        controller.addNode(desiredNode);
      } else {
        final data = existingNode.data;
        data.updateFrom(desiredNode.data);
        if (existingNode.type != desiredNode.type) {
          final position = existingNode.position.value;
          controller.removeNode(entry.key);
          controller.addNode(
            Node<_NodeData>(
              id: desiredNode.id,
              type: desiredNode.type,
              position: position,
              data: desiredNode.data,
              inputPorts: desiredNode.inputPorts,
              outputPorts: desiredNode.outputPorts,
            ),
          );
        }
      }
    }

    final desiredConnectionIds = model.connections.keys.toSet();
    final currentConnectionIds = controller.connectionIds.toSet();

    for (final connectionId in currentConnectionIds.difference(desiredConnectionIds)) {
      controller.removeConnection(connectionId);
    }

    for (final entry in model.connections.entries) {
      final desiredConnection = entry.value;
      final existingConnection = controller.getConnection(entry.key);
      if (existingConnection == null) {
        controller.addConnection(desiredConnection);
      } else {
        final desiredLabel = desiredConnection.label?.text;
        final existingLabel = existingConnection.label?.text;
        if (desiredLabel != existingLabel) {
          existingConnection.label = desiredConnection.label;
        }
        if (existingConnection.animationEffect != desiredConnection.animationEffect) {
          existingConnection.animationEffect = desiredConnection.animationEffect;
        }
      }
    }
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
      key: const ValueKey('topology'),
      controller: _controller!,
      theme: _buildTheme(context),
      nodeBuilder: _buildNode,
      behavior: NodeFlowBehavior.preview,
    );
  }

  Widget _buildNode(BuildContext context, Node<_NodeData> node) {
    final data = node.data;

    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
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
      },
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

class _GraphModel {
  final Map<String, Node<_NodeData>> nodes;
  final Map<String, Connection> connections;

  _GraphModel(this.nodes, this.connections);
}

enum _NodeType { local, server, player, relay }

class _NodeData extends ChangeNotifier {
  String displayName;
  String? ip;
  _NodeType type;
  String platform;
  int latency;

  _NodeData({
    required this.displayName,
    this.ip,
    required this.type,
    required this.platform,
    required this.latency,
  });

  void updateFrom(_NodeData other) {
    var changed = false;
    if (displayName != other.displayName) {
      displayName = other.displayName;
      changed = true;
    }
    if (ip != other.ip) {
      ip = other.ip;
      changed = true;
    }
    if (type != other.type) {
      type = other.type;
      changed = true;
    }
    if (platform != other.platform) {
      platform = other.platform;
      changed = true;
    }
    if (latency != other.latency) {
      latency = other.latency;
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }
}
