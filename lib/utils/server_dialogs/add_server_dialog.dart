import 'package:flutter/material.dart';
import 'package:astral/data/models/server_model.dart';

/// 添加/编辑服务器的弹窗
/// 可在任意页面通过 `showAddServerDialog(context)` 调用
Future<ServerModel?> showAddServerDialog(
  BuildContext context, {
  ServerModel? initial,
}) async {
  final formKey = GlobalKey<FormState>();

  String name = initial?.name ?? '';
  String url = initial?.url ?? '';
  String? description = initial?.description;
  ProtocolType protocol = initial?.protocol ?? ProtocolType.tcp;
  // 不在表单中展示"启用"和"排序"，保持初始值或默认值
  final bool enable = initial?.enable ?? true;
  final int sortOrder = initial?.sortOrder ?? 0;

  return showDialog<ServerModel?>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(initial == null ? '添加服务器' : '编辑服务器'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(
                    labelText: '名称',
                    prefixIcon: Icon(Icons.badge_outlined),
                    hintText: '请输入服务器名称',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入服务器名称';
                    }
                    return null;
                  },
                  onSaved: (v) => name = v!.trim(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: url,
                  decoration: const InputDecoration(
                    labelText: '地址（URL）',
                    prefixIcon: Icon(Icons.link_outlined),
                    hintText: '例如: https://example.com:8080',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入服务器地址';
                    }
                    return null;
                  },
                  onSaved: (v) => url = v!.trim(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: description,
                  decoration: const InputDecoration(
                    labelText: '描述（可选）',
                    prefixIcon: Icon(Icons.description_outlined),
                    hintText: '请输入服务器描述',
                  ),
                  maxLines: 2,
                  onSaved: (v) => description = v?.trim().isEmpty == true ? null : v?.trim(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ProtocolType>(
                  value: protocol,
                  decoration: const InputDecoration(
                    labelText: '协议',
                    prefixIcon: Icon(Icons.swap_calls_outlined),
                  ),
                  items: ProtocolType.values
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(_protocolLabel(p)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => protocol = v ?? ProtocolType.tcp,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final server = ServerModel(
                  id: initial?.id ?? DateTime.now().millisecondsSinceEpoch,
                  name: name,
                  url: url,
                  description: description,
                  enable: enable,
                  protocol: protocol,
                  sortOrder: sortOrder,
                  createdAt: initial?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                Navigator.of(context).pop(server);
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('保存'),
          ),
        ],
      );
    },
  );
}

String _protocolLabel(ProtocolType p) {
  switch (p) {
    case ProtocolType.tcp:
      return 'TCP';
    case ProtocolType.udp:
      return 'UDP';
    case ProtocolType.ws:
      return 'WS';
    case ProtocolType.wss:
      return 'WSS';
    case ProtocolType.quic:
      return 'QUIC';
    case ProtocolType.wg:
      return 'WireGuard';
    case ProtocolType.txt:
      return 'TXT';
    case ProtocolType.srv:
      return 'SRV';
    case ProtocolType.http:
      return 'HTTP';
    case ProtocolType.https:
      return 'HTTPS';
  }
}