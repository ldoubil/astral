import 'package:flutter/foundation.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';

class TopologyGraphModel {
  final Map<String, Node<TopologyNodeData>> nodes;
  final Map<String, Connection> connections;

  TopologyGraphModel(this.nodes, this.connections);
}

enum TopologyNodeType { local, server, player, relay }

class TopologyNodeData extends ChangeNotifier {
  String displayName;
  String? ip;
  TopologyNodeType type;
  String platform;
  int latency;

  TopologyNodeData({
    required this.displayName,
    this.ip,
    required this.type,
    required this.platform,
    required this.latency,
  });

  void updateFrom(TopologyNodeData other) {
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
