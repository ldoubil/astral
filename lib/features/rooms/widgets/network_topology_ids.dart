import 'package:astral/src/rust/api/simple.dart';

/// Node / connection id helpers for topology graphs.
class NetworkTopologyIds {
  NetworkTopologyIds._();

  static bool isServerNode(KVNodeInfo nodeInfo) {
    return nodeInfo.hostname.startsWith('PublicServer_') ||
        nodeInfo.ipv4 == '0.0.0.0';
  }

  static String safeId(String raw) {
    return raw.replaceAll(RegExp(r'[^A-Za-z0-9_]'), '_');
  }

  static String normalizeNodeName(String hostname) {
    return hostname.startsWith('PublicServer_')
        ? hostname.substring('PublicServer_'.length)
        : hostname;
  }

  static String nodeFallbackKey(KVNodeInfo nodeInfo) {
    if (nodeInfo.ipv4.isNotEmpty) {
      return 'ip_${nodeInfo.ipv4}';
    }
    return 'name_${normalizeNodeName(nodeInfo.hostname)}';
  }

  static String hopFallbackKey(NodeHopStats hop) {
    if (hop.targetIp.isNotEmpty) {
      return 'ip_${hop.targetIp}';
    }
    return 'name_${normalizeNodeName(hop.nodeName)}';
  }

  static String nodeIdForPeerId(int peerId, String fallbackKey) {
    if (peerId > 0) {
      return 'peer_$peerId';
    }
    return safeId(fallbackKey);
  }

  static String connectionId(String sourceId, String targetId) {
    return 'conn_${sourceId}_to_$targetId';
  }

  static String formatLatencyLabel(double latencyMs) {
    return '${latencyMs.round()}ms';
  }

  static String? resolveNodeId({
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
}
