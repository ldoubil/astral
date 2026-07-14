import 'package:astral/features/rooms/widgets/network_topology_models.dart';
import 'package:astral/features/rooms/widgets/peer_connection_style.dart';
import 'package:flutter/material.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';

/// Node card and legend builders for [NetworkTopologyView].
class NetworkTopologyNodes {
  const NetworkTopologyNodes._();

  static Color headerColor(TopologyNodeType type, ColorScheme colorScheme) {
    switch (type) {
      case TopologyNodeType.local:
        return colorScheme.primaryContainer;
      case TopologyNodeType.server:
        return colorScheme.tertiaryContainer;
      case TopologyNodeType.player:
        return colorScheme.secondaryContainer;
      case TopologyNodeType.relay:
        return colorScheme.surfaceContainerHighest;
    }
  }

  static Color headerOnColor(TopologyNodeType type, ColorScheme colorScheme) {
    switch (type) {
      case TopologyNodeType.local:
        return colorScheme.onPrimaryContainer;
      case TopologyNodeType.server:
        return colorScheme.onTertiaryContainer;
      case TopologyNodeType.player:
        return colorScheme.onSecondaryContainer;
      case TopologyNodeType.relay:
        return colorScheme.onSurfaceVariant;
    }
  }

  static Widget buildNode(
    BuildContext context,
    Node<TopologyNodeData> node, {
    required bool denseMode,
  }) {
    final data = node.data;

    return AnimatedBuilder(
      animation: data,
      builder: (context, _) {
        IconData icon;
        switch (data.type) {
          case TopologyNodeType.local:
            icon = Icons.computer;
            break;
          case TopologyNodeType.server:
            icon = Icons.cloud;
            break;
          case TopologyNodeType.player:
            icon = Icons.person;
            break;
          case TopologyNodeType.relay:
            icon = Icons.router;
            break;
        }

        final colorScheme = Theme.of(context).colorScheme;
        final nodeWidth = denseMode ? 186.0 : 220.0;

        final nodeHeaderColor = headerColor(data.type, colorScheme);
        final nodeHeaderOnColor = headerOnColor(data.type, colorScheme);

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
                    color: nodeHeaderColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 18, color: nodeHeaderOnColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          data.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: nodeHeaderOnColor,
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
                          ? buildDenseNodeBody(context, data)
                          : buildDefaultNodeBody(context, data),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget buildDefaultNodeBody(
    BuildContext context,
    TopologyNodeData data,
  ) {
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
                  color: PeerConnectionStyle.getLatencyColor(
                    data.latency.toDouble(),
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  static Widget buildDenseNodeBody(
    BuildContext context,
    TopologyNodeData data,
  ) {
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
                  color: PeerConnectionStyle.getLatencyColor(
                    data.latency.toDouble(),
                  ),
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

  static Widget buildLegendCard(
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
                legendItem(
                  context,
                  icon: Icons.computer,
                  label: 'Local',
                  color: headerColor(TopologyNodeType.local, colorScheme),
                ),
                legendItem(
                  context,
                  icon: Icons.cloud,
                  label: 'Server $serverCount',
                  color: headerColor(TopologyNodeType.server, colorScheme),
                ),
                legendItem(
                  context,
                  icon: Icons.person,
                  label: 'Player $playerCount',
                  color: headerColor(TopologyNodeType.player, colorScheme),
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

  static Widget legendItem(
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
}
