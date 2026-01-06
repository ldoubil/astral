import 'package:flutter/material.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/ui/base_settings_page.dart';
import 'package:signals_flutter/signals_flutter.dart';

class PortWhitelistPage extends BaseSettingsPage {
  const PortWhitelistPage({super.key});

  @override
  String get title => '端口白名单';

  @override
  Widget buildContent(BuildContext context) {
    return Watch((context) {
      final tcpWhitelist = ServiceManager().networkConfigState.tcpWhitelist
          .watch(context);
      final udpWhitelist = ServiceManager().networkConfigState.udpWhitelist
          .watch(context);

      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          buildSettingsCard(
            context: context,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('白名单说明'),
                subtitle: const Text(
                  '配置允许通过的TCP/UDP端口。\n'
                  '支持单个端口(80)和范围(8000-9000)。\n'
                  '多个端口用逗号分隔，如: 80,443,8000-9000',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          buildSettingsCard(
            context: context,
            children: [
              ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('TCP 端口白名单'),
                subtitle: Text(
                  tcpWhitelist.isEmpty ? '未设置' : tcpWhitelist,
                  style: TextStyle(
                    color:
                        tcpWhitelist.isEmpty
                            ? Theme.of(context).textTheme.bodySmall?.color
                            : Theme.of(context).colorScheme.primary,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: '编辑',
                      onPressed:
                          () => _editWhitelist(
                            context,
                            'TCP',
                            tcpWhitelist,
                            (value) => ServiceManager().networkConfig
                                .updateTcpWhitelist(value),
                          ),
                    ),
                    if (tcpWhitelist.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: '清空',
                        onPressed:
                            () => _clearWhitelist(
                              context,
                              'TCP',
                              () => ServiceManager().networkConfig
                                  .updateTcpWhitelist(''),
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          buildSettingsCard(
            context: context,
            children: [
              ListTile(
                leading: const Icon(Icons.wifi),
                title: const Text('UDP 端口白名单'),
                subtitle: Text(
                  udpWhitelist.isEmpty ? '未设置' : udpWhitelist,
                  style: TextStyle(
                    color:
                        udpWhitelist.isEmpty
                            ? Theme.of(context).textTheme.bodySmall?.color
                            : Theme.of(context).colorScheme.primary,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: '编辑',
                      onPressed:
                          () => _editWhitelist(
                            context,
                            'UDP',
                            udpWhitelist,
                            (value) => ServiceManager().networkConfig
                                .updateUdpWhitelist(value),
                          ),
                    ),
                    if (udpWhitelist.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: '清空',
                        onPressed:
                            () => _clearWhitelist(
                              context,
                              'UDP',
                              () => ServiceManager().networkConfig
                                  .updateUdpWhitelist(''),
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Future<void> _editWhitelist(
    BuildContext context,
    String type,
    String currentValue,
    Future<void> Function(String) onSave,
  ) async {
    final controller = TextEditingController(text: currentValue);
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('编辑 $type 端口白名单'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '格式说明：',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('• 单个端口: 80'),
                const Text('• 端口范围: 8000-9000'),
                const Text('• 多个端口: 80,443,8000-9000'),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: '$type 端口',
                    hintText: '例如: 80,443,8000-9000',
                    border: const OutlineInputBorder(),
                    helperText: '留空表示不限制',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('保存'),
              ),
            ],
          ),
    );

    if (result != null) {
      await onSave(result.trim());
    }
  }

  Future<void> _clearWhitelist(
    BuildContext context,
    String type,
    Future<void> Function() onClear,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('确认清空'),
            content: Text('确定要清空 $type 端口白名单吗？\n清空后将不限制端口访问。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('清空'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await onClear();
    }
  }
}
