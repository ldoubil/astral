import 'package:astral/features/rooms/widgets/network_topology_models.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';

/// Applies incremental node/connection diffs to a topology controller.
class NetworkTopologyDiff {
  NetworkTopologyDiff._();

  static void apply(
    NodeFlowController<TopologyNodeData, dynamic> controller,
    TopologyGraphModel model,
  ) {
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
            Node<TopologyNodeData>(
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
}
