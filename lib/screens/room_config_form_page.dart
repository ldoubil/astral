import 'package:astral/models/base.dart';
import 'package:flutter/material.dart';
import 'package:astral/models/room_config.dart';
import 'package:astral/models/net_node.dart';
import 'package:astral/models/server_node.dart';

/// 房间配置表单页面
class RoomConfigFormPage extends StatefulWidget {
  final RoomConfig? roomConfig;
  final bool isEditing;

  const RoomConfigFormPage({
    super.key,
    this.roomConfig,
    this.isEditing = false,
  });

  @override
  State<RoomConfigFormPage> createState() => _RoomConfigFormPageState();
}

class _RoomConfigFormPageState extends State<RoomConfigFormPage> {
  final _formKey = GlobalKey<FormState>();

  // 基本信息控制器
  late TextEditingController _nameController;
  late TextEditingController _uuidController;
  late TextEditingController _descController;
  late TextEditingController _versionController;
  late TextEditingController _priorityController;
  
  // 网络配置控制器
  late TextEditingController _hostnameController;
  late TextEditingController _instanceNameController;
  late TextEditingController _ipv4Controller;
  late TextEditingController _networkNameController;
  late TextEditingController _networkSecretController;
  late TextEditingController _listenersController;
  late TextEditingController _peerController;
  late TextEditingController _cidrproxyController;
  late TextEditingController _defaultProtocolController;

  // 状态变量
  bool _roomProtect = false;
  bool _dhcp = true;
  List<ServerNode> _servers = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (widget.isEditing && widget.roomConfig != null) {
      _loadExistingData();
    }
  }

  /// 初始化控制器
  void _initializeControllers() {
    _nameController = TextEditingController();
    _uuidController = TextEditingController(text: _generateUUID());
    _descController = TextEditingController();
    _versionController = TextEditingController(text: '0');
    _priorityController = TextEditingController(text: '0');
    
    _hostnameController = TextEditingController();
    _instanceNameController = TextEditingController(text: 'default');
    _ipv4Controller = TextEditingController();
    _networkNameController = TextEditingController();
    _networkSecretController = TextEditingController();
    _listenersController = TextEditingController();
    _peerController = TextEditingController();
    _cidrproxyController = TextEditingController();
    _defaultProtocolController = TextEditingController(text: 'tcp');
  }

  /// 生成UUID
  String _generateUUID() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'room_${timestamp}_$random';
  }

  /// 加载现有数据
  void _loadExistingData() {
    final config = widget.roomConfig!;
    _nameController.text = config.room_name;
    _uuidController.text = config.room_uuid;
    _descController.text = config.room_desc;
    _versionController.text = config.version.toString();
    _priorityController.text = config.priority.toString();
    _roomProtect = config.room_protect;
    
    // 网络配置
    final netNode = config.room_public;
    _hostnameController.text = netNode.hostname;
    _instanceNameController.text = netNode.instance_name;
    _ipv4Controller.text = netNode.ipv4;
    _networkNameController.text = netNode.network_name;
    _networkSecretController.text = netNode.network_secret;
    _listenersController.text = netNode.listeners.join(', ');
    _peerController.text = netNode.peer.join(', ');
    _cidrproxyController.text = netNode.cidrproxy.join(', ');
    _defaultProtocolController.text = netNode.default_protocol;
    _dhcp = netNode.dhcp;
    
    _servers = List.from(config.server);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _uuidController.dispose();
    _descController.dispose();
    _versionController.dispose();
    _priorityController.dispose();
    _hostnameController.dispose();
    _instanceNameController.dispose();
    _ipv4Controller.dispose();
    _networkNameController.dispose();
    _networkSecretController.dispose();
    _listenersController.dispose();
    _peerController.dispose();
    _cidrproxyController.dispose();
    _defaultProtocolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? '编辑房间配置' : '添加房间配置'),
        actions: [
          IconButton(
            onPressed: _saveConfiguration,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildBasicInfoCard(),
            const SizedBox(height: 16),
            _buildNetworkConfigCard(),
            const SizedBox(height: 16),
            _buildServerConfigCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text("基本信息", style: Theme.of(context).textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '房间名称 *',
                helperText: '为您的房间起一个易于识别的名称',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '房间名称不能为空';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: '房间描述',
                helperText: '描述房间的用途或特点',
              ),
              maxLines: 3,
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('房间保护'),
            subtitle: const Text('启用后需要密码才能加入房间'),
            value: _roomProtect,
            onChanged: (value) {
              setState(() {
                _roomProtect = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkConfigCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text("网络配置", style: Theme.of(context).textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: _hostnameController,
              decoration: const InputDecoration(
                labelText: '主机名',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: _instanceNameController,
              decoration: const InputDecoration(
                labelText: '实例名称',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: _networkNameController,
              decoration: const InputDecoration(
                labelText: '网络名称',
                helperText: '虚拟网络的名称',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: _networkSecretController,
              decoration: const InputDecoration(
                labelText: '网络密钥',
                helperText: '用于网络加密的密钥',
              ),
              obscureText: true,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ipv4Controller,
                    decoration: const InputDecoration(
                      labelText: 'IPv4地址',
                      helperText: '静态IP地址（可选）',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    const Text("DHCP"),
                    Switch(
                      value: _dhcp,
                      onChanged: (value) {
                        setState(() {
                          _dhcp = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: _defaultProtocolController,
              decoration: const InputDecoration(
                labelText: '默认协议',
                helperText: '默认使用的网络协议',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: _listenersController,
              decoration: const InputDecoration(
                labelText: '监听端口',
                helperText: '多个端口用逗号分隔',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: _peerController,
              decoration: const InputDecoration(
                labelText: '对等节点',
                helperText: '多个用逗号分隔',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: TextFormField(
              controller: _cidrproxyController,
              decoration: const InputDecoration(
                labelText: 'CIDR代理',
                helperText: '多个用逗号分隔',
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildServerConfigCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text("服务器配置", style: Theme.of(context).textTheme.titleMedium),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addServer,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _servers.length,
            itemBuilder: (context, index) {
              final server = _servers[index];
              return ListTile(
                title: Text(server.name.isNotEmpty ? server.name : '服务器 ${index + 1}'),
                subtitle: Text('地址: ${server.host}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editServer(index);
                    } else if (value == 'delete') {
                      _deleteServer(index);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('编辑'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('删除'),
                    ),
                  ],
                ),
              );
            },
          ),
          if (_servers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: Text('暂无服务器配置')),
            ),
        ],
      ),
    );
  }

  /// 构建服务器卡片
  Widget _buildServerCard(ServerNode server, int index) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final colorScheme = theme.colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: CircleAvatar(
          backgroundColor: primaryColor,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          server.name.isNotEmpty ? server.name : '服务器 ${index + 1}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.language,
                  size: 12,
                  color: primaryColor.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  '地址: ${server.host}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.settings_ethernet,
                  size: 12,
                  color: primaryColor.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  '协议: ${server.protocolSwitch.name}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editServer(index);
                break;
              case 'delete':
                _deleteServer(index);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    '编辑',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: colorScheme.error),
                  const SizedBox(width: 8),
                  Text(
                    '删除',
                    style: TextStyle(color: colorScheme.error),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 添加服务器
  void _addServer() {
    _showServerDialog();
  }

  /// 编辑服务器
  void _editServer(int index) {
    _showServerDialog(server: _servers[index], index: index);
  }

  /// 删除服务器
  void _deleteServer(int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          '确认删除',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '确定要删除这个服务器配置吗？',
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurface.withOpacity(0.6),
            ),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _servers.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  /// 显示服务器配置对话框
  void _showServerDialog({ServerNode? server, int? index}) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final colorScheme = theme.colorScheme;
    
    final nameController = TextEditingController(text: server?.name ?? '');
    final addressController = TextEditingController(text: server?.host ?? '');
    final protocolController = TextEditingController(text: server?.protocolSwitch.name ?? 'tcp');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          server != null ? '编辑服务器' : '添加服务器',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '服务器名称',
                  prefixIcon: Icon(Icons.label, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: '服务器地址',
                  prefixIcon: Icon(Icons.language, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                  helperText: '例如：192.168.1.1:8080',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: protocolController,
                decoration: InputDecoration(
                  labelText: '协议',
                  prefixIcon: Icon(Icons.settings_ethernet, color: primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurface.withOpacity(0.6),
            ),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final newServer = ServerNode.create(
                name: nameController.text,
                host: addressController.text,
                port: 11010,
                protocolSwitch: ServerProtocolSwitch.tcp,
              );

              setState(() {
                if (index != null) {
                  _servers[index] = newServer;
                } else {
                  _servers.add(newServer);
                }
              });

              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(server != null ? '更新' : '添加'),
          ),
        ],
      ),
    );
  }

  /// 保存配置
  void _saveConfiguration() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final roomConfig = RoomConfig();
      roomConfig.room_name = _nameController.text.trim();
      roomConfig.room_uuid = _uuidController.text.trim();
      roomConfig.room_desc = _descController.text.trim();
      roomConfig.version = int.tryParse(_versionController.text) ?? 0;
      roomConfig.priority = int.tryParse(_priorityController.text) ?? 0;
      roomConfig.room_protect = _roomProtect;
      
      final netNode = NetNode();
      netNode.hostname = _hostnameController.text.trim();
      netNode.instance_name = _instanceNameController.text.trim();
      netNode.ipv4 = _ipv4Controller.text.trim();
      netNode.network_name = _networkNameController.text.trim();
      netNode.network_secret = _networkSecretController.text.trim();
      netNode.listeners = _parseListString(_listenersController.text);
      netNode.peer = _parseListString(_peerController.text);
      netNode.cidrproxy = _parseListString(_cidrproxyController.text);
      netNode.default_protocol = _defaultProtocolController.text.trim();
      netNode.dhcp = _dhcp;
      
      roomConfig.room_public = netNode;
      roomConfig.server = _servers;
      roomConfig.create_time = widget.roomConfig?.create_time ?? DateTime.now();

      Navigator.of(context).pop(roomConfig);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存失败: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  /// 解析逗号分隔的字符串为列表
  List<String> _parseListString(String input) {
    if (input.trim().isEmpty) return [];
    return input
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}