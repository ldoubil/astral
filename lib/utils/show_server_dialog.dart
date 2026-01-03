import 'package:astral/k/services/service_manager.dart';
import 'package:astral/k/models/server_mod.dart';
import 'package:astral/utils/blocked_servers.dart';
import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';

// 显示添加服务器对话框
Future<void> showAddServerDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) => ServerDialog(title: '添加服务器', confirmText: '添加'),
  );
}

// 显示编辑服务器对话框
Future<void> showEditServerDialog(
  BuildContext context, {
  required ServerMod server,
}) async {
  return showDialog(
    context: context,
    builder:
        (context) =>
            ServerDialog(title: '编辑服务器', confirmText: '保存', server: server),
  );
}

class ServerDialog extends StatefulWidget {
  final String title;
  final String confirmText;
  final ServerMod? server;

  const ServerDialog({
    super.key,
    required this.title,
    required this.confirmText,
    this.server,
  });

  @override
  State<ServerDialog> createState() => _ServerDialogState();
}

class _ServerDialogState extends State<ServerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();

  bool _tcp = true;
  bool _udp = true;
  bool _ws = false;
  bool _wss = false;
  bool _quic = false;
  bool _wg = false;
  bool _txt = false;
  bool _srv = false;
  bool _http = false; // <-- 新增 HTTP 状态
  bool _https = false; // <-- 新增 HTTPS 状态

  @override
  void initState() {
    super.initState();

    // 如果是编辑模式，填充现有数据
    if (widget.server != null) {
      _nameController.text = widget.server!.name;
      _urlController.text = widget.server!.url;

      _tcp = widget.server!.tcp;
      _udp = widget.server!.udp;
      _ws = widget.server!.ws;
      _wss = widget.server!.wss;
      _quic = widget.server!.quic;
      _wg = widget.server!.wg;
      _txt = widget.server!.txt;
      _srv = widget.server!.srv;
      _http = widget.server!.http;
      _https = widget.server!.https;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _saveServer() {
    if (_formKey.currentState!.validate()) {
      final server = ServerMod(
        id: widget.server?.id ?? Isar.autoIncrement,
        enable: widget.server?.enable ?? false,
        name: _nameController.text,
        url: _urlController.text,
        tcp: _tcp,
        udp: _udp,
        ws: _ws,
        wss: _wss,
        quic: _quic,
        wg: _wg,
        txt: _txt,
        srv: _srv,
        http: _http, // <-- 保存 HTTP 状态
        https: _https, // <-- 保存 HTTPS 状态
      );

      if (widget.server == null) {
        // 添加新服务器
        ServiceManager().server.addServer(server);
      } else {
        // 更新现有服务器
        ServiceManager().server.updateServer(server);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 服务器名称
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '服务器名称',
                  hintText: '输入服务器名称',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入服务器名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 服务器地址
              TextFormField(
                controller: _urlController,
                enabled:
                    widget.server == null ||
                    !BlockedServers.isBlocked(widget.server!.url),
                decoration: InputDecoration(
                  labelText: '服务器地址',
                  hintText: '输入服务器地址',
                  helperText:
                      widget.server != null &&
                              BlockedServers.isBlocked(widget.server!.url)
                          ? '此服务器地址不可修改'
                          : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入服务器地址';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 协议支持
              const Text(
                '支持的协议:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildProtocolSwitch(
                    'TCP',
                    _tcp,
                    (value) => setState(() => _tcp = value!),
                  ),
                  _buildProtocolSwitch(
                    'UDP',
                    _udp,
                    (value) => setState(() => _udp = value!),
                  ),
                  _buildProtocolSwitch(
                    'WS',
                    _ws,
                    (value) => setState(() => _ws = value!),
                  ),
                  _buildProtocolSwitch(
                    'WSS',
                    _wss,
                    (value) => setState(() => _wss = value!),
                  ),
                  _buildProtocolSwitch(
                    'QUIC',
                    _quic,
                    (value) => setState(() => _quic = value!),
                  ),
                  _buildProtocolSwitch(
                    'WG',
                    _wg,
                    (value) => setState(() => _wg = value!),
                  ),
                  _buildProtocolSwitch(
                    'TXT',
                    _txt,
                    (value) => setState(() => _txt = value!),
                  ),
                  _buildProtocolSwitch(
                    'SRV',
                    _srv,
                    (value) => setState(() => _srv = value!),
                  ),
                  _buildProtocolSwitch(
                    // <-- 新增 HTTP 开关
                    'HTTP',
                    _http,
                    (value) => setState(() => _http = value!),
                  ),
                  _buildProtocolSwitch(
                    // <-- 新增 HTTPS 开关
                    'HTTPS',
                    _https,
                    (value) => setState(() => _https = value!),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _saveServer,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          child: Text(widget.confirmText),
        ),
      ],
    );
  }

  Widget _buildProtocolSwitch(
    String label,
    bool value,
    Function(bool?) onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Switch(value: value, onChanged: onChanged), Text(label)],
    );
  }
}
