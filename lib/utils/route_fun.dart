import 'package:astral/k/services/service_manager.dart';
import 'package:astral/k/models/net_config.dart';
import 'package:flutter/material.dart';

Future<void> addConnectionManager(BuildContext context) async {
  final nameController = TextEditingController();
  final result = await showDialog<ConnectionManager>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('新增转发分组'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '分组名称',
                  hintText: '请输入分组名称',
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
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final manager =
                      ConnectionManager()
                        ..name = nameController.text.trim()
                        ..connections = []
                        ..enabled = false;
                  Navigator.pop(context, manager);
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
  );

  if (result != null) {
    await ServiceManager().connection.addConnection(result);
  }
}

Future<void> editConnectionManager(
  BuildContext context,
  int index,
  ConnectionManager manager,
) async {
  final nameController = TextEditingController(text: manager.name);
  final connectionControllers =
      manager.connections
          .map(
            (conn) => {
              'bindAddr': TextEditingController(text: conn.bindAddr),
              'dstAddr': TextEditingController(text: conn.dstAddr),
              // 确保协议值在有效选项中，否则默认为tcp
              'proto': ['tcp', 'udp', 'all'].contains(conn.proto.toLowerCase()) 
                  ? conn.proto.toLowerCase() 
                  : 'tcp',
            },
          )
          .toList();

  final result = await showDialog<ConnectionManager>(
    context: context,
    builder:
        (context) => StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                title: const Text('编辑转发分组'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: '分组名称'),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '连接配置:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(connectionControllers.length, (
                          connIndex,
                        ) {
                          final controllers = connectionControllers[connIndex];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  // 绑定地址
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller:
                                          controllers['bindAddr']!
                                              as TextEditingController,
                                      decoration: const InputDecoration(
                                        labelText: '绑定地址',
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  // 箭头
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Icon(Icons.arrow_forward, size: 20),
                                  ),
                                  // 目标地址
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller:
                                          controllers['dstAddr']!
                                              as TextEditingController,
                                      decoration: const InputDecoration(
                                        labelText: '目标地址',
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // 协议下拉选择
                                  SizedBox(
                                    width: 80,
                                    child: DropdownButtonFormField<String>(
                                      value: controllers['proto'] as String,
                                      decoration: const InputDecoration(
                                        labelText: '协议',
                                        isDense: true,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'tcp',
                                          child: Text('TCP'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'udp',
                                          child: Text('UDP'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'all',
                                          child: Text('ALL'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          controllers['proto'] = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  // 删除按钮
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        connectionControllers.removeAt(
                                          connIndex,
                                        );
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        ListTile(
                          leading: const Icon(Icons.add),
                          title: const Text('添加连接'),
                          onTap: () {
                            setState(() {
                              connectionControllers.add({
                                'bindAddr': TextEditingController(),
                                'dstAddr': TextEditingController(),
                                'proto': 'tcp', // 默认协议为tcp
                              });
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () {
                      final updatedManager =
                          ConnectionManager()
                            ..name = nameController.text.trim()
                            ..enabled = manager.enabled
                            ..connections =
                                connectionControllers
                                    .map((controllers) {
                                      final conn =
                                          ConnectionInfo()
                                            ..bindAddr =
                                                (controllers['bindAddr']!
                                                        as TextEditingController)
                                                    .text
                                                    .trim()
                                            ..dstAddr =
                                                (controllers['dstAddr']!
                                                        as TextEditingController)
                                                    .text
                                                    .trim()
                                            ..proto =
                                                controllers['proto']! as String;
                                      return conn;
                                    })
                                    .where(
                                      (conn) =>
                                          conn.bindAddr.isNotEmpty ||
                                          conn.dstAddr.isNotEmpty,
                                    )
                                    .toList();
                      Navigator.pop(context, updatedManager);
                    },
                    child: const Text('保存'),
                  ),
                ],
              ),
        ),
  );

  if (result != null) {
    await ServiceManager().connection.updateConnection(index, result);
  }
}

Future<void> deleteConnectionManager(
  BuildContext context,
  int index,
  String name,
) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('确认删除'),
          content: Text('确定要删除转发分组 "${name.isEmpty ? '未命名分组' : name}" 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('删除'),
            ),
          ],
        ),
  );

  if (confirm == true) {
    await ServiceManager().connection.removeConnection(index);
  }
}
