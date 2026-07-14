import 'package:astral/core/services/service_manager.dart';
import 'package:astral/features/rooms/widgets/network_topology_graph.dart';
import 'package:astral/features/rooms/widgets/network_topology_models.dart';
import 'package:astral/features/rooms/widgets/network_topology_nodes.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:flutter/material.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';

class NetworkTopologyView extends StatefulWidget {
  final List<KVNodeInfo> nodes;
  final bool reduceUpdates;
  final bool isInBackground;

  const NetworkTopologyView({
    super.key,
    required this.nodes,
    this.reduceUpdates = false,
    this.isInBackground = false,
  });

  @override
  State<NetworkTopologyView> createState() => _NetworkTopologyViewState();
}

class _NetworkTopologyViewState extends State<NetworkTopologyView> {
  NodeFlowController<TopologyNodeData, dynamic>? _controller;
  int? _lastStructureSignature;
  bool? _lastShouldAnimateConnections;
  DateTime? _lastGraphSyncAt;
  DateTime? _lastMetricsSyncAt;

  @override
  void initState() {
    super.initState();
    _syncGraph();
    _syncMetrics(force: true);
  }

  @override
  void didUpdateWidget(NetworkTopologyView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final resumedFromBackground =
        oldWidget.isInBackground && !widget.isInBackground;
    _syncMetrics(force: resumedFromBackground);
    _syncGraph(force: resumedFromBackground);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  bool get _shouldAnimateConnections {
    return !widget.reduceUpdates && !widget.isInBackground;
  }

  void _syncGraph({bool force = false}) {
    if (!force && widget.isInBackground) {
      return;
    }

    if (!force &&
        widget.reduceUpdates &&
        _lastGraphSyncAt != null &&
        DateTime.now().difference(_lastGraphSyncAt!) <
            NetworkTopologyGraphSync.reducedSyncInterval) {
      return;
    }

    final localIp = ServiceManager().networkConfigState.ipv4.value;
    final structureSignature =
        NetworkTopologyGraphSync.calculateStructureSignature(
          widget.nodes,
          localIp,
        );
    final shouldAnimate = _shouldAnimateConnections;
    if (_controller != null &&
        _lastStructureSignature == structureSignature &&
        _lastShouldAnimateConnections == shouldAnimate) {
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

    final model = NetworkTopologyGraphSync.buildGraphModel(
      widget.nodes,
      localIp: localIp,
      existingPositions: existingPositions,
      shouldAnimateConnections: shouldAnimate,
    );

    if (_controller == null) {
      _controller = NodeFlowController<TopologyNodeData, dynamic>(
        nodes: model.nodes.values.toList(),
        connections: model.connections.values.toList(),
        config: NodeFlowConfig(snapToGrid: false, minZoom: 0.3, maxZoom: 2.0),
      );
      _lastStructureSignature = structureSignature;
      _lastShouldAnimateConnections = shouldAnimate;
      _lastGraphSyncAt = DateTime.now();
      return;
    }

    NetworkTopologyGraphSync.applyGraphDiff(_controller!, model);
    _lastStructureSignature = structureSignature;
    _lastShouldAnimateConnections = shouldAnimate;
    _lastGraphSyncAt = DateTime.now();
  }

  void _syncMetrics({bool force = false}) {
    if (_controller == null) return;
    if (!force &&
        widget.reduceUpdates &&
        _lastMetricsSyncAt != null &&
        DateTime.now().difference(_lastMetricsSyncAt!) <
            NetworkTopologyGraphSync.metricsSyncInterval) {
      return;
    }

    final localIp = ServiceManager().networkConfigState.ipv4.value;
    final model = NetworkTopologyGraphSync.buildGraphModel(
      widget.nodes,
      localIp: localIp,
      existingPositions: {},
      shouldAnimateConnections: _shouldAnimateConnections,
    );

    final controller = _controller!;
    for (final entry in model.nodes.entries) {
      final existing = controller.getNode(entry.key);
      if (existing != null) {
        existing.data.updateFrom(entry.value.data);
      }
    }

    for (final entry in model.connections.entries) {
      final existing = controller.getConnection(entry.key);
      if (existing != null) {
        final desiredLabel = entry.value.label?.text;
        final existingLabel = existing.label?.text;
        if (desiredLabel != existingLabel) {
          existing.label = entry.value.label;
        }
      }
    }

    _lastMetricsSyncAt = DateTime.now();
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
      if (NetworkTopologyGraphSync.isServerNode(node)) {
        serverCount++;
      } else {
        playerCount++;
      }
    }

    final denseMode = widget.nodes.length >= 12;

    return Stack(
      children: [
        NodeFlowEditor<TopologyNodeData, dynamic>(
          key: const ValueKey('topology'),
          controller: _controller!,
          theme: _buildTheme(context),
          nodeBuilder:
              (context, node) => NetworkTopologyNodes.buildNode(
                context,
                node,
                denseMode: denseMode,
              ),
          behavior: NodeFlowBehavior.preview,
        ),
        Positioned(
          top: 12,
          left: 12,
          child: NetworkTopologyNodes.buildLegendCard(
            context,
            serverCount: serverCount,
            playerCount: playerCount,
          ),
        ),
      ],
    );
  }

  NodeFlowTheme _buildTheme(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shouldAnimate = _shouldAnimateConnections;

    return (isDark ? NodeFlowTheme.dark : NodeFlowTheme.light).copyWith(
      backgroundColor: colorScheme.surface,
      connectionTheme: ConnectionTheme.light.copyWith(
        style: ConnectionStyles.bezier,
        color: colorScheme.primary.withValues(alpha: 0.6),
        strokeWidth: 2.5,
        animationEffect: shouldAnimate ? ConnectionEffects.particles : null,
      ),
      connectionAnimationDuration:
          shouldAnimate ? const Duration(seconds: 4) : const Duration(seconds: 1),
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
