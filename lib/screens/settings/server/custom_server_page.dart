import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CustomServerPage extends StatefulWidget {
  const CustomServerPage({super.key});

  @override
  State<CustomServerPage> createState() => _CustomServerPageState();
}

class _CustomServerPageState extends State<CustomServerPage> {
  final _formKey = GlobalKey<FormState>();
  final _serverNameController = TextEditingController();
  final _serverUrlController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _useSSL = true;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _serverNameController.dispose();
    _serverUrlController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义服务器'),
        actions: [
          TextButton(
            onPressed: _saveServer,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '服务器信息',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _serverNameController,
                      decoration: const InputDecoration(
                        labelText: '服务器名称',
                        hintText: '输入服务器名称',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入服务器名称';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _serverUrlController,
                      decoration: const InputDecoration(
                        labelText: '服务器地址',
                        hintText: '例如: example.com',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入服务器地址';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _portController,
                      decoration: const InputDecoration(
                        labelText: '端口',
                        hintText: '例如: 443',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入端口号';
                        }
                        final port = int.tryParse(value);
                        if (port == null || port < 1 || port > 65535) {
                          return '请输入有效的端口号 (1-65535)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('使用 SSL/TLS'),
                      subtitle: const Text('启用安全连接'),
                      value: _useSSL,
                      onChanged: (value) {
                        setState(() {
                          _useSSL = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '认证信息',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: '用户名',
                        hintText: '输入用户名',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: '密码',
                        hintText: '输入密码',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _testConnection,
                    child: const Text('测试连接'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveServer,
                    child: const Text('保存配置'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _testConnection() {
    if (_formKey.currentState!.validate()) {
      // TODO: 实现连接测试逻辑
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('正在测试连接...'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _saveServer() {
    if (_formKey.currentState!.validate()) {
      // TODO: 实现保存服务器配置逻辑
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('服务器配置已保存'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }
  }
}