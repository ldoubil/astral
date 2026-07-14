import 'package:flutter/material.dart';

/// 房间分享对话框中的「高级选项」（服务器列表 + 网络配置勾选）
Widget buildAdvancedShareOptions(
  BuildContext context,
  List<String> selectedServers,
  Map<String, bool> networkConfigOptions,
  List<String> enabledServerUrls,
  StateSetter setState,
  ColorScheme colorScheme,
) {
  return ExpansionTile(
    initiallyExpanded: false,
    title: Row(
      children: [
        Icon(Icons.tune_outlined, size: 20, color: colorScheme.secondary),
        const SizedBox(width: 8),
        Text(
          '高级选项',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.secondary,
          ),
        ),
      ],
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: colorScheme.outlineVariant),
    ),
    collapsedShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: colorScheme.outlineVariant),
    ),
    backgroundColor: colorScheme.surface,
    collapsedBackgroundColor:
        colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (enabledServerUrls.isNotEmpty) ...[
              Text(
                '🔗 服务器列表',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children:
                      enabledServerUrls.map((serverUrl) {
                        final isSelected = selectedServers.contains(serverUrl);
                        return CheckboxListTile(
                          dense: true,
                          title: Text(
                            serverUrl,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontFamily: 'monospace'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedServers.add(serverUrl);
                              } else {
                                selectedServers.remove(serverUrl);
                              }
                            });
                          },
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (networkConfigOptions.isNotEmpty)
              Text(
                '⚙️ 网络配置',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  buildConfigCheckbox(
                    context,
                    'DHCP',
                    'dhcp',
                    networkConfigOptions,
                    setState,
                  ),
                  buildConfigCheckbox(
                    context,
                    '默认协议',
                    'defaultProtocol',
                    networkConfigOptions,
                    setState,
                  ),
                  buildConfigCheckbox(
                    context,
                    '加密',
                    'enableEncryption',
                    networkConfigOptions,
                    setState,
                  ),
                  buildConfigCheckbox(
                    context,
                    '延迟优先',
                    'latencyFirst',
                    networkConfigOptions,
                    setState,
                  ),
                  buildConfigCheckbox(
                    context,
                    '禁用P2P',
                    'disableP2p',
                    networkConfigOptions,
                    setState,
                  ),
                  buildConfigCheckbox(
                    context,
                    '禁用UDP打洞',
                    'disableUdpHolePunching',
                    networkConfigOptions,
                    setState,
                  ),
                  buildConfigCheckbox(
                    context,
                    '禁用TCP打洞',
                    'disableTcpHolePunching',
                    networkConfigOptions,
                    setState,
                  ),
                  buildConfigCheckbox(
                    context,
                    '禁用对称打洞',
                    'disableSymHolePunching',
                    networkConfigOptions,
                    setState,
                  ),
                  buildConfigCheckbox(
                    context,
                    '数据压缩',
                    'dataCompressAlgo',
                    networkConfigOptions,
                    setState,
                  ),
                  buildConfigCheckbox(
                    context,
                    'KCP代理',
                    'enableKcpProxy',
                    networkConfigOptions,
                    setState,
                  ),
                  buildConfigCheckbox(
                    context,
                    '绑定设备',
                    'bindDevice',
                    networkConfigOptions,
                    setState,
                  ),
                  buildConfigCheckbox(
                    context,
                    '禁用TUN',
                    'noTun',
                    networkConfigOptions,
                    setState,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget buildConfigCheckbox(
  BuildContext context,
  String label,
  String key,
  Map<String, bool> options,
  StateSetter setState, {
  bool isLast = false,
}) {
  return Column(
    children: [
      CheckboxListTile(
        dense: true,
        title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        value: options[key],
        onChanged: (value) {
          setState(() {
            options[key] = value ?? false;
          });
        },
      ),
      if (!isLast)
        Divider(
          height: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
    ],
  );
}
