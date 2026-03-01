import 'dart:math' as math;

import 'package:astral/core/services/service_manager.dart';
import 'package:astral/shared/utils/helpers/platform_version_parser.dart';
import 'package:astral/src/rust/api/simple.dart';
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
  int? _lastGraphSignature;

  static const double _localX = 120;
  static const double _targetX = 760;
  static const double _baseY = 80;
  static const double _rowGap = 130;

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
    final graphSignature = _calculateGraphSignature(widget.nodes, localIp);
    if (_controller != null && _lastGraphSignature == graphSignature) {
      return;
    }

    final existingPositions = <String, Offset>{};
    if (_controller != null) {
      for (final nodeId in _controller!.nodeIds) {
        final node = _controller!.getNode(nodeId);
        if (node != null) {
          existingPositions[nodeId] = node.position.value;
        }
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
      _lastGraphSignature = graphSignature;
      return;
    }

    _applyGraphDiff(model);
    _lastGraphSignature = graphSignature;
  }

  int _calculateGraphSignature(List<KVNodeInfo> nodes, String localIp) {
    var hash = Object.hash(nodes.length, localIp);
    for (final node in nodes) {
      var nodeHash = Object.hash(
        node.peerId,
        node.hostname,
        node.ipv4,
        node.version,
        node.latencyMs.toStringAsFixed(1),
        node.hops.length,
      );

      for (final hop in node.hops) {
        nodeHash = Object.hash(
          nodeHash,
          hop.peerId,
          hop.targetIp,
          hop.nodeName,
          hop.latencyMs.toStringAsFixed(1),
        );
      }

      hash = Object.hash(hash, nodeHash);
    }
    return hash;
  }

  String _safeId(String raw) {
    return raw.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
  }

  String _normalizeNodeName(String hostname) {
    return hostname.startsWith('PublicServer_')
        ? hostname.substring('PublicServer_'.length)
        : hostname;
  }

  bool _isServerNode(KVNodeInfo nodeInfo) {
    return nodeInfo.hostname.startsWith('PublicServer_') ||
        nodeInfo.ipv4 == '0.0.0.0';
  }

  String _nodeFallbackKey(KVNodeInfo nodeInfo) {
    if (nodeInfo.ipv4.isNotEmpty) {
      return 'ip_${nodeInfo.ipv4}';
    }
    return 'name_${_normalizeNodeName(nodeInfo.hostname)}';
  }

  String _hopFallbackKey(NodeHopStats hop) {
    if (hop.targetIp.isNotEmpty) {
      return 'ip_${hop.targetIp}';
    }
    return 'name_${_normalizeNodeName(hop.nodeName)}';
  }

  String _nodeIdForPeerId(int peerId, String fallbackKey) {
    if (peerId > 0) {
      return 'peer_$peerId';
    }
    return _safeId(fallbackKey);
  }

  String _connectionId(String sourceId, String targetId) {
    return 'conn_${sourceId}_to_$targetId';
  }

  String _formatLatencyLabel(double latencyMs) {
    return '${latencyMs.round()}ms';
  }

  String? _resolveNodeId({
    required int peerId,
    required String fallbackKey,
    required Map<int, String> nodeIdsByPeerId,
    required Map<String, String> nodeIdsByFallbackKey,
  }) {
    if (peerId > 0) {
      return nodeIdsByPeerId[peerId];
    }
    return nodeIdsByFallbackKey[fallbackKey];
  }

  _GraphModel _buildGraphModel(
    List<KVNodeInfo> nodes, {
    required String localIp,
    required Map<String, Offset> existingPositions,
  }) {
    final newNodes = <String, Node<_NodeData>>{};
    final newConnections = <String, Connection>{};
    final nodeIdsByPeerId = <int, String>{};
    final nodeIdsByFallbackKey = <String, String>{};
    final nodeRowIndex = <String, int>{};

    KVNodeInfo? localNode;
    for (final node in nodes) {
      if (node.ipv4 == localIp && localIp.isNotEmpty) {
        localNode = node;
        break;
      }
    }

    final nonLocalServers = <KVNodeInfo>[];
    final nonLocalPlayers = <KVNodeInfo>[];

    for (final node in nodes) {
      if (localNode != null && node.peerId == localNode.peerId) {
        continue;
      }
      if (_isServerNode(node)) {
        nonLocalServers.add(node);
      } else {
        nonLocalPlayers.add(node);
      }
    }

    nonLocalServers.sort((a, b) => a.peerId.compareTo(b.peerId));
    nonLocalPlayers.sort((a, b) => a.peerId.compareTo(b.peerId));

    final hasLaneSpacer =
        nonLocalServers.isNotEmpty && nonLocalPlayers.isNotEmpty;
    final totalRows =
        nonLocalServers.length +
        nonLocalPlayers.length +
        (hasLaneSpacer ? 1 : 0);

    final nonLocalIndexByPeerId = <int, int>{};
    final nonLocalIndexByFallbackKey = <String, int>{};

    for (var i = 0; i < nonLocalServers.length; i++) {
      final server = nonLocalServers[i];
      if (server.peerId > 0) {
        nonLocalIndexByPeerId[server.peerId] = i;
      }
      nonLocalIndexByFallbackKey[_nodeFallbackKey(server)] = i;
    }

    for (var i = 0; i < nonLocalPlayers.length; i++) {
      final player = nonLocalPlayers[i];
      final row = i + nonLocalServers.length + (hasLaneSpacer ? 1 : 0);
      if (player.peerId > 0) {
        nonLocalIndexByPeerId[player.peerId] = row;
      }
      nonLocalIndexByFallbackKey[_nodeFallbackKey(player)] = row;
    }

    int rowIndex = 0;
    for (final nodeInfo in nodes) {
      final isLocal = localNode != null && nodeInfo.peerId == localNode.peerId;
      final isServer = _isServerNode(nodeInfo);
      final nodeId = _nodeIdForPeerId(
        nodeInfo.peerId,
        _nodeFallbackKey(nodeInfo),
      );

      if (nodeInfo.peerId > 0) {
        nodeIdsByPeerId[nodeInfo.peerId] = nodeId;
      }
      nodeIdsByFallbackKey[_nodeFallbackKey(nodeInfo)] = nodeId;

      final displayName = _normalizeNodeName(nodeInfo.hostname);
      late final Offset position;

      if (existingPositions.containsKey(nodeId)) {
        position = existingPositions[nodeId]!;
      } else if (isLocal) {
        final localY =
            totalRows <= 1 ? 250.0 : _baseY + ((totalRows - 1) * _rowGap / 2);
        position = Offset(_localX, localY);
      } else {
        final index =
            nonLocalIndexByPeerId[nodeInfo.peerId] ??
            nonLocalIndexByFallbackKey[_nodeFallbackKey(nodeInfo)] ??
            -1;
        final effectiveIndex = index >= 0 ? index : rowIndex;
        position = Offset(_targetX, _baseY + (effectiveIndex * _rowGap));
        nodeRowIndex[nodeId] = effectiveIndex;
        rowIndex = math.max(rowIndex, effectiveIndex + 1);
      }

      newNodes[nodeId] = Node<_NodeData>(
        id: nodeId,
        type: isLocal ? 'local' : (isServer ? 'server' : 'player'),
        position: position,
        data: _NodeData(
          displayName: displayName,
          ip: isServer && !isLocal ? null : nodeInfo.ipv4,
          type:
              isLocal
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
        localNode == null
            ? null
            : _resolveNodeId(
              peerId: localNode.peerId,
              fallbackKey: _nodeFallbackKey(localNode),
              nodeIdsByPeerId: nodeIdsByPeerId,
              nodeIdsByFallbackKey: nodeIdsByFallbackKey,
            );

    if (localNodeId == null) {
      return _GraphModel(newNodes, newConnections);
    }

    for (final nodeInfo in nodes) {
      if (localNode != null && nodeInfo.peerId == localNode.peerId) {
        continue;
      }

      final targetId =
          _resolveNodeId(
            peerId: nodeInfo.peerId,
            fallbackKey: _nodeFallbackKey(nodeInfo),
            nodeIdsByPeerId: nodeIdsByPeerId,
            nodeIdsByFallbackKey: nodeIdsByFallbackKey,
          ) ??
          _nodeIdForPeerId(nodeInfo.peerId, _nodeFallbackKey(nodeInfo));

      if (nodeInfo.hops.isNotEmpty) {
        String previousNodeId = localNodeId;
        final targetRow = nodeRowIndex[targetId] ?? 0;
        final hopCount = nodeInfo.hops.length;

        for (var hopIndex = 0; hopIndex < nodeInfo.hops.length; hopIndex++) {
          final hop = nodeInfo.hops[hopIndex];
          final hopId =
              _resolveNodeId(
                peerId: hop.peerId,
                fallbackKey: _hopFallbackKey(hop),
                nodeIdsByPeerId: nodeIdsByPeerId,
                nodeIdsByFallbackKey: nodeIdsByFallbackKey,
              ) ??
              _nodeIdForPeerId(hop.peerId, _hopFallbackKey(hop));

          if (!newNodes.containsKey(hopId)) {
            final displayName = _normalizeNodeName(
              hop.nodeName.isNotEmpty ? hop.nodeName : 'relay_${hop.targetIp}',
            );
            final hopX =
                _localX +
                ((_targetX - _localX) / (hopCount + 1)) * (hopIndex + 1);
            final position =
                existingPositions[hopId] ??
                Offset(hopX, _baseY + (targetRow * _rowGap));

            newNodes[hopId] = Node<_NodeData>(
              id: hopId,
              type: 'relay',
              position: position,
              data: _NodeData(
                displayName: displayName,
                ip: hop.targetIp,
                type: _NodeType.relay,
                platform: 'Relay',
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
              label: ConnectionLabel(text: _formatLatencyLabel(hop.latencyMs)),
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
              text: _formatLatencyLabel(nodeInfo.latencyMs),
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
              text: _formatLatencyLabel(nodeInfo.latencyMs),
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
        existingNode.data.updateFrom(desiredNode.data);

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

    for (final connectionId in currentConnectionIds.difference(
      desiredConnectionIds,
    )) {
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

        if (existingConnection.animationEffect !=
            desiredConnection.animationEffect) {
          existingConnection.animationEffect =
              desiredConnection.animationEffect;
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

  Color _getNodeHeaderColor(_NodeType type, ColorScheme colorScheme) {
    switch (type) {
      case _NodeType.local:
        return colorScheme.primaryContainer;
      case _NodeType.server:
        return colorScheme.tertiaryContainer;
      case _NodeType.player:
        return colorScheme.secondaryContainer;
      case _NodeType.relay:
        return colorScheme.surfaceContainerHighest;
    }
  }

  Color _getNodeHeaderOnColor(_NodeType type, ColorScheme colorScheme) {
    switch (type) {
      case _NodeType.local:
        return colorScheme.onPrimaryContainer;
      case _NodeType.server:
        return colorScheme.onTertiaryContainer;
      case _NodeType.player:
        return colorScheme.onSecondaryContainer;
      case _NodeType.relay:
        return colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final localIp = ServiceManager().networkConfigState.ipv4.value;
    var serverCount = 0;
    var playerCount = 0;

    for (final node in widget.nodes) {
      if (localIp.isNotEmpty && node.ipv4 == localIp) {
        continue;
      }
      if (_isServerNode(node)) {
        serverCount++;
      } else {
        playerCount++;
      }
    }

    return Stack(
      children: [
        NodeFlowEditor<_NodeData, dynamic>(
          key: const ValueKey('topology'),
          controller: _controller!,
          theme: _buildTheme(context),
          nodeBuilder: _buildNode,
          behavior: NodeFlowBehavior.preview,
        ),
        Positioned(
          top: 12,
          left: 12,
          child: _buildLegendCard(
            context,
            serverCount: serverCount,
            playerCount: playerCount,
          ),
        ),
      ],
    );
  }

  Widget _buildNode(BuildContext context, Node<_NodeData> node) {
    final data = node.data;

    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
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

        final colorScheme = Theme.of(context).colorScheme;
        final denseMode = widget.nodes.length >= 12;
        final nodeWidth = denseMode ? 186.0 : 220.0;

        final headerColor = _getNodeHeaderColor(data.type, colorScheme);
        final headerOnColor = _getNodeHeaderOnColor(data.type, colorScheme);

        return RepaintBoundary(
          child: SizedBox(
            width: nodeWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: headerColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 18, color: headerOnColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          data.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: headerOnColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border.all(color: colorScheme.outline),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child:
                      denseMode
                          ? _buildDenseNodeBody(context, data)
                          : _buildDefaultNodeBody(context, data),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultNodeBody(BuildContext context, _NodeData data) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (data.ip != null)
          Row(
            children: [
              Icon(Icons.language, size: 13, color: colorScheme.onSurface),
              const SizedBox(width: 4),
              Text(data.ip!, style: const TextStyle(fontSize: 11)),
            ],
          ),
        if (data.ip != null) const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.devices, size: 13, color: colorScheme.onSurface),
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
              Icon(Icons.speed, size: 13, color: colorScheme.onSurface),
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
    );
  }

  Widget _buildDenseNodeBody(BuildContext context, _NodeData data) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (data.latency > 0)
          Row(
            children: [
              Icon(Icons.speed, size: 13, color: colorScheme.onSurface),
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
        if (data.ip != null) ...[
          if (data.latency > 0) const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.language, size: 13, color: colorScheme.onSurface),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  data.ip!,
                  style: const TextStyle(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLegendCard(
    BuildContext context, {
    required int serverCount,
    required int playerCount,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface.withValues(alpha: 0.92),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Topology',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: [
                _legendItem(
                  context,
                  icon: Icons.computer,
                  label: 'Local',
                  color: _getNodeHeaderColor(_NodeType.local, colorScheme),
                ),
                _legendItem(
                  context,
                  icon: Icons.cloud,
                  label: 'Server $serverCount',
                  color: _getNodeHeaderColor(_NodeType.server, colorScheme),
                ),
                _legendItem(
                  context,
                  icon: Icons.person,
                  label: 'Player $playerCount',
                  color: _getNodeHeaderColor(_NodeType.player, colorScheme),
                ),
              ],
            ),
            if (serverCount > 0 && playerCount > 0) ...[
              const SizedBox(height: 6),
              Text(
                'Servers are above players.',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _legendItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final onColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
            ? Colors.white
            : Colors.black87;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 12, color: onColor),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  NodeFlowTheme _buildTheme(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return (isDark ? NodeFlowTheme.dark : NodeFlowTheme.light).copyWith(
      backgroundColor: colorScheme.surface,
      connectionTheme: ConnectionTheme.light.copyWith(
        style: ConnectionStyles.bezier,
        color: colorScheme.primary.withValues(alpha: 0.6),
        strokeWidth: 2.5,
        animationEffect: ConnectionEffects.particles,
      ),
      connectionAnimationDuration: const Duration(seconds: 3),
      gridTheme: GridTheme.light.copyWith(
        style: GridStyles.dots,
        size: 20,
        color: colorScheme.outlineVariant,
      ),
      portTheme: PortTheme.light.copyWith(
        size: const Size.square(8),
        color: colorScheme.primary,
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
