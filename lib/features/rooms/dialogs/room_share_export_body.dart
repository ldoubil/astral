import 'package:flutter/material.dart';
import 'package:astral/core/models/room.dart';
import 'package:astral/core/models/network_config_share.dart';
import 'package:astral/features/rooms/dialogs/room_share_advanced_options.dart';
import 'package:astral/features/rooms/dialogs/room_share_copy_link.dart';

/// 房间分享导出对话框主体（标题 / 信息区 / 高级选项 / 操作栏）
Widget buildRoomShareExportDialogBody({
  required BuildContext context,
  required Room room,
  required Room roomToShare,
  required List<String> selectedServers,
  required Map<String, bool> networkConfigOptions,
  required List<String> enabledServerUrls,
  required bool hasServers,
  required bool hasNetworkConfig,
  required StateSetter setState,
  required ColorScheme colorScheme,
}) {
  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    child: SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, room, colorScheme),
            Divider(height: 1, color: colorScheme.outlineVariant),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfoCard(context, room, colorScheme),
                  const SizedBox(height: 24),
                  if (enabledServerUrls.isNotEmpty ||
                      networkConfigOptions.isNotEmpty)
                    buildAdvancedShareOptions(
                      context,
                      selectedServers,
                      networkConfigOptions,
                      enabledServerUrls,
                      setState,
                      colorScheme,
                    ),
                  if (hasServers || hasNetworkConfig) ...[
                    const SizedBox(height: 16),
                    _buildShareSummary(
                      context,
                      selectedServers,
                      networkConfigOptions,
                      hasServers,
                      hasNetworkConfig,
                      colorScheme,
                    ),
                  ],
                ],
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant),
            _buildActions(context, roomToShare),
          ],
        ),
      ),
    ),
  );
}

/// 根据勾选选项构造待分享的房间与网络配置
({Room roomToShare, bool hasServers, bool hasNetworkConfig})
buildRoomToShare({
  required Room room,
  required List<String> selectedServers,
  required Map<String, bool> networkConfigOptions,
}) {
  final hasServers = selectedServers.isNotEmpty;
  final hasNetworkConfig = networkConfigOptions.values.any((v) => v);

  NetworkConfigShare? networkConfig;
  if (hasNetworkConfig) {
    final currentConfig = NetworkConfigShare.fromCurrentConfig();
    networkConfig = NetworkConfigShare(
      dhcp: networkConfigOptions['dhcp']! ? currentConfig.dhcp : null,
      defaultProtocol:
          networkConfigOptions['defaultProtocol']!
              ? currentConfig.defaultProtocol
              : null,
      enableEncryption:
          networkConfigOptions['enableEncryption']!
              ? currentConfig.enableEncryption
              : null,
      latencyFirst:
          networkConfigOptions['latencyFirst']!
              ? currentConfig.latencyFirst
              : null,
      disableP2p:
          networkConfigOptions['disableP2p']! ? currentConfig.disableP2p : null,
      disableUdpHolePunching:
          networkConfigOptions['disableUdpHolePunching']!
              ? currentConfig.disableUdpHolePunching
              : null,
      disableTcpHolePunching:
          networkConfigOptions['disableTcpHolePunching']!
              ? currentConfig.disableTcpHolePunching
              : null,
      disableSymHolePunching:
          networkConfigOptions['disableSymHolePunching']!
              ? currentConfig.disableSymHolePunching
              : null,
      dataCompressAlgo:
          networkConfigOptions['dataCompressAlgo']!
              ? currentConfig.dataCompressAlgo
              : null,
      enableKcpProxy:
          networkConfigOptions['enableKcpProxy']!
              ? currentConfig.enableKcpProxy
              : null,
      bindDevice:
          networkConfigOptions['bindDevice']! ? currentConfig.bindDevice : null,
      noTun: networkConfigOptions['noTun']! ? currentConfig.noTun : null,
    );
  }

  final roomToShare = Room(
    id: room.id,
    name: room.name,
    encrypted: room.encrypted,
    roomName: room.roomName,
    messageKey: room.messageKey,
    password: room.password,
    tags: room.tags,
    sortOrder: room.sortOrder,
    servers: hasServers ? selectedServers : [],
    customParam:
        hasServers ? DateTime.now().millisecondsSinceEpoch.toString() : '',
    networkConfigJson: hasNetworkConfig ? networkConfig!.toJsonString() : '',
  );

  return (
    roomToShare: roomToShare,
    hasServers: hasServers,
    hasNetworkConfig: hasNetworkConfig,
  );
}

Widget _buildHeader(BuildContext context, Room room, ColorScheme colorScheme) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.share,
            color: colorScheme.onPrimaryContainer,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '分享房间',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                room.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildBasicInfoCard(
  BuildContext context,
  Room room,
  ColorScheme colorScheme,
) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              '房间基本信息',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.tag, size: 16, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '房间名称',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.name,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildShareSummary(
  BuildContext context,
  List<String> selectedServers,
  Map<String, bool> networkConfigOptions,
  bool hasServers,
  bool hasNetworkConfig,
  ColorScheme colorScheme,
) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: colorScheme.outline),
    ),
    child: Row(
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 18,
          color: colorScheme.secondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            hasServers && hasNetworkConfig
                ? '将分享 ${selectedServers.length} 个服务器 + ${networkConfigOptions.values.where((v) => v).length} 项配置'
                : hasServers
                ? '将分享 ${selectedServers.length} 个服务器'
                : '将分享 ${networkConfigOptions.values.where((v) => v).length} 项配置',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colorScheme.secondary),
            maxLines: 2,
          ),
        ),
      ],
    ),
  );
}

Widget _buildActions(BuildContext context, Room roomToShare) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
            copyRoomShareLink(context, roomToShare, linkOnly: true);
          },
          icon: const Icon(Icons.copy_outlined),
          label: const Text('复制链接'),
        ),
      ],
    ),
  );
}
