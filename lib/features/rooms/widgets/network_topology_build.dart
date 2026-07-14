import 'dart:math' as math;

import 'package:astral/features/rooms/widgets/network_topology_ids.dart';
import 'package:astral/features/rooms/widgets/network_topology_models.dart';
import 'package:astral/shared/utils/platform_version_parser.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:flutter/material.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';

/// Builds topology node/connection models from peer list data.
class NetworkTopologyBuild {
  NetworkTopologyBuild._();

  static const double localX = 120;
  static const double targetX = 760;
  static const double baseY = 80;
  static const double rowGap = 130;

  static TopologyGraphModel buildGraphModel(
    List<KVNodeInfo> nodes, {
    required String localIp,
    required Map<String, Offset> existingPositions,
    required bool shouldAnimateConnections,
  }) {
    final newNodes = <String, Node<TopologyNodeData>>{};
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
      if (NetworkTopologyIds.isServerNode(node)) {
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
      nonLocalIndexByFallbackKey[NetworkTopologyIds.nodeFallbackKey(server)] =
          i;
    }

    for (var i = 0; i < nonLocalPlayers.length; i++) {
      final player = nonLocalPlayers[i];
      final row = i + nonLocalServers.length + (hasLaneSpacer ? 1 : 0);
      if (player.peerId > 0) {
        nonLocalIndexByPeerId[player.peerId] = row;
      }
      nonLocalIndexByFallbackKey[NetworkTopologyIds.nodeFallbackKey(player)] =
          row;
    }

    int rowIndex = 0;
    for (final nodeInfo in nodes) {
      final isLocal = localNode != null && nodeInfo.peerId == localNode.peerId;
      final isServer = NetworkTopologyIds.isServerNode(nodeInfo);
      final nodeId = NetworkTopologyIds.nodeIdForPeerId(
        nodeInfo.peerId,
        NetworkTopologyIds.nodeFallbackKey(nodeInfo),
      );

      if (nodeInfo.peerId > 0) {
        nodeIdsByPeerId[nodeInfo.peerId] = nodeId;
      }
      nodeIdsByFallbackKey[NetworkTopologyIds.nodeFallbackKey(nodeInfo)] =
          nodeId;

      final displayName = NetworkTopologyIds.normalizeNodeName(
        nodeInfo.hostname,
      );
      late final Offset position;

      if (existingPositions.containsKey(nodeId)) {
        position = existingPositions[nodeId]!;
      } else if (isLocal) {
        final localY =
            totalRows <= 1 ? 250.0 : baseY + ((totalRows - 1) * rowGap / 2);
        position = Offset(localX, localY);
      } else {
        final index =
            nonLocalIndexByPeerId[nodeInfo.peerId] ??
            nonLocalIndexByFallbackKey[NetworkTopologyIds.nodeFallbackKey(
              nodeInfo,
            )] ??
            -1;
        final effectiveIndex = index >= 0 ? index : rowIndex;
        position = Offset(targetX, baseY + (effectiveIndex * rowGap));
        nodeRowIndex[nodeId] = effectiveIndex;
        rowIndex = math.max(rowIndex, effectiveIndex + 1);
      }

      newNodes[nodeId] = Node<TopologyNodeData>(
        id: nodeId,
        type: isLocal ? 'local' : (isServer ? 'server' : 'player'),
        position: position,
        data: TopologyNodeData(
          displayName: displayName,
          ip: isServer && !isLocal ? null : nodeInfo.ipv4,
          type:
              isLocal
                  ? TopologyNodeType.local
                  : (isServer
                      ? TopologyNodeType.server
                      : TopologyNodeType.player),
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
            : NetworkTopologyIds.resolveNodeId(
              peerId: localNode.peerId,
              fallbackKey: NetworkTopologyIds.nodeFallbackKey(localNode),
              nodeIdsByPeerId: nodeIdsByPeerId,
              nodeIdsByFallbackKey: nodeIdsByFallbackKey,
            );

    if (localNodeId == null) {
      return TopologyGraphModel(newNodes, newConnections);
    }

    for (final nodeInfo in nodes) {
      if (localNode != null && nodeInfo.peerId == localNode.peerId) {
        continue;
      }

      final targetId =
          NetworkTopologyIds.resolveNodeId(
            peerId: nodeInfo.peerId,
            fallbackKey: NetworkTopologyIds.nodeFallbackKey(nodeInfo),
            nodeIdsByPeerId: nodeIdsByPeerId,
            nodeIdsByFallbackKey: nodeIdsByFallbackKey,
          ) ??
          NetworkTopologyIds.nodeIdForPeerId(
            nodeInfo.peerId,
            NetworkTopologyIds.nodeFallbackKey(nodeInfo),
          );

      if (nodeInfo.hops.isNotEmpty) {
        String previousNodeId = localNodeId;
        final targetRow = nodeRowIndex[targetId] ?? 0;
        final hopCount = nodeInfo.hops.length;

        for (var hopIndex = 0; hopIndex < nodeInfo.hops.length; hopIndex++) {
          final hop = nodeInfo.hops[hopIndex];
          final hopId =
              NetworkTopologyIds.resolveNodeId(
                peerId: hop.peerId,
                fallbackKey: NetworkTopologyIds.hopFallbackKey(hop),
                nodeIdsByPeerId: nodeIdsByPeerId,
                nodeIdsByFallbackKey: nodeIdsByFallbackKey,
              ) ??
              NetworkTopologyIds.nodeIdForPeerId(
                hop.peerId,
                NetworkTopologyIds.hopFallbackKey(hop),
              );

          if (!newNodes.containsKey(hopId)) {
            final displayName = NetworkTopologyIds.normalizeNodeName(
              hop.nodeName.isNotEmpty ? hop.nodeName : 'relay_${hop.targetIp}',
            );
            final hopX =
                localX +
                ((targetX - localX) / (hopCount + 1)) * (hopIndex + 1);
            final position =
                existingPositions[hopId] ??
                Offset(hopX, baseY + (targetRow * rowGap));

            newNodes[hopId] = Node<TopologyNodeData>(
              id: hopId,
              type: 'relay',
              position: position,
              data: TopologyNodeData(
                displayName: displayName,
                ip: hop.targetIp,
                type: TopologyNodeType.relay,
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
            final connId = NetworkTopologyIds.connectionId(
              previousNodeId,
              hopId,
            );
            newConnections[connId] = Connection(
              id: connId,
              sourceNodeId: previousNodeId,
              sourcePortId: 'out',
              targetNodeId: hopId,
              targetPortId: 'in',
              animationEffect:
                  shouldAnimateConnections ? ConnectionEffects.particles : null,
              label: ConnectionLabel(
                text: NetworkTopologyIds.formatLatencyLabel(hop.latencyMs),
              ),
            );
          }

          previousNodeId = hopId;
        }

        if (previousNodeId != targetId) {
          final connId = NetworkTopologyIds.connectionId(
            previousNodeId,
            targetId,
          );
          newConnections[connId] = Connection(
            id: connId,
            sourceNodeId: previousNodeId,
            sourcePortId: 'out',
            targetNodeId: targetId,
            targetPortId: 'in',
            animationEffect:
                shouldAnimateConnections ? ConnectionEffects.particles : null,
            label: ConnectionLabel(
              text: NetworkTopologyIds.formatLatencyLabel(nodeInfo.latencyMs),
            ),
          );
        }
      } else {
        if (localNodeId != targetId) {
          final connId = NetworkTopologyIds.connectionId(localNodeId, targetId);
          newConnections[connId] = Connection(
            id: connId,
            sourceNodeId: localNodeId,
            sourcePortId: 'out',
            targetNodeId: targetId,
            targetPortId: 'in',
            animationEffect:
                shouldAnimateConnections ? ConnectionEffects.particles : null,
            label: ConnectionLabel(
              text: NetworkTopologyIds.formatLatencyLabel(nodeInfo.latencyMs),
            ),
          );
        }
      }
    }

    return TopologyGraphModel(newNodes, newConnections);
  }
}
