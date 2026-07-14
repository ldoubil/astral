import 'package:astral/features/rooms/widgets/network_topology_build.dart';
import 'package:astral/features/rooms/widgets/network_topology_diff.dart';
import 'package:astral/features/rooms/widgets/network_topology_ids.dart';
import 'package:astral/features/rooms/widgets/network_topology_models.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:flutter/material.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';

/// Builds and diffs topology graphs for [NetworkTopologyView].
class NetworkTopologyGraphSync {
  NetworkTopologyGraphSync._();

  static const double localX = NetworkTopologyBuild.localX;
  static const double targetX = NetworkTopologyBuild.targetX;
  static const double baseY = NetworkTopologyBuild.baseY;
  static const double rowGap = NetworkTopologyBuild.rowGap;
  static const Duration reducedSyncInterval = Duration(seconds: 4);
  static const Duration metricsSyncInterval = Duration(seconds: 1);

  static bool isServerNode(KVNodeInfo nodeInfo) {
    return NetworkTopologyIds.isServerNode(nodeInfo);
  }

  static int calculateStructureSignature(List<KVNodeInfo> nodes, String localIp) {
    var hash = Object.hash(nodes.length, localIp);
    for (final node in nodes) {
      var nodeHash = Object.hash(
        node.peerId,
        node.hostname,
        node.ipv4,
        node.version,
        node.hops.length,
      );

      for (final hop in node.hops) {
        nodeHash = Object.hash(
          nodeHash,
          hop.peerId,
          hop.targetIp,
          hop.nodeName,
        );
      }

      hash = Object.hash(hash, nodeHash);
    }
    return hash;
  }

  static TopologyGraphModel buildGraphModel(
    List<KVNodeInfo> nodes, {
    required String localIp,
    required Map<String, Offset> existingPositions,
    required bool shouldAnimateConnections,
  }) {
    return NetworkTopologyBuild.buildGraphModel(
      nodes,
      localIp: localIp,
      existingPositions: existingPositions,
      shouldAnimateConnections: shouldAnimateConnections,
    );
  }

  static void applyGraphDiff(
    NodeFlowController<TopologyNodeData, dynamic> controller,
    TopologyGraphModel model,
  ) {
    NetworkTopologyDiff.apply(controller, model);
  }
}
