import 'package:flutter/material.dart';
import 'package:astral/models/room_config.dart';
import 'package:astral/models/net_node.dart';

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
  // 房间名称
  late TextEditingController _nameController;
  // 房间唯一标识
  late TextEditingController _uuidController;

  // 网络配置控制器
  late TextEditingController _hostnameController; // 主机名
  late TextEditingController _instanceNameController; // 实例名
  late TextEditingController _networkNameController; // 网络名称
  late TextEditingController _networkSecretController; // 网络密钥
  bool _roomProtect = true; // 是否启用房间保护

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

    _hostnameController = TextEditingController();
    _instanceNameController = TextEditingController(text: 'default');
    _networkNameController = TextEditingController();
    _networkSecretController = TextEditingController();
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

    // 网络配置
    final netNode = config.room_public;
    _hostnameController.text = netNode.hostname;
    _instanceNameController.text = netNode.instance_name;
    _networkNameController.text = netNode.network_name;
    _networkSecretController.text = netNode.network_secret;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _uuidController.dispose();

    _hostnameController.dispose();
    _instanceNameController.dispose();
    _networkNameController.dispose();
    _networkSecretController.dispose();
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
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                "基本信息",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _buildBasicInfoCard(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                "网络配置",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _buildNetworkConfigCard(),
          ],
        ),
      ),
    );
  }

  /// 构建基本信息卡片
  Widget _buildBasicInfoCard() {
    return Card(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '房间名称 *',

                border: OutlineInputBorder(),
                prefixIcon: Icon(
                  Icons.meeting_room,
                  color: Theme.of(context).colorScheme.primary,
                ),
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
          SwitchListTile(
            secondary: Icon(
              Icons.security,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('房间保护'),
            subtitle: const Text('启用后自动生成网络名称和网络密码'),
            value: _roomProtect,
            onChanged: (value) {
              setState(() {
                _roomProtect = value;
              });
            },
          ),
          if (!_roomProtect) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: _networkNameController,
                decoration: InputDecoration(
                  labelText: '网络名称',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.network_wifi,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: _networkSecretController,
                decoration: InputDecoration(
                  labelText: '网络密钥',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(
                    Icons.vpn_key,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  /// 构建网络配置卡片
  Widget _buildNetworkConfigCard() {
    return Column(
      children: [
        _buildSettingsCard(
          context,
          icon: Icons.hearing,
          title: "监听列表",
          subtitle: '管理房间监听地址',
          onTap: () => {},
        ),
        _buildSettingsCard(
          context,
          icon: Icons.dns,
          title: "服务器列表",
          subtitle: '管理房间服务器地址',
          onTap: () => {},
        ),
        _buildSettingsCard(
          context,
          icon: Icons.settings_ethernet,
          title: "基础网络配置",
          subtitle: '配置房间的网络参数',
          onTap: () => {},
        ),
        _buildSettingsCard(
          context,
          icon: Icons.tune,
          title: "高级网络配置",
          subtitle: '配置房间的高级网络参数',
          onTap: () => {},
        ),
      ],
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
      roomConfig.room_desc = "";
      roomConfig.version = 0;
      roomConfig.priority = 0;
      roomConfig.room_protect = _roomProtect;

      final netNode = NetNode();
      netNode.hostname = _hostnameController.text.trim();
      netNode.instance_name = _instanceNameController.text.trim();
      // netNode.ipv4 = _ipv4Controller.text.trim();
      netNode.network_name = _networkNameController.text.trim();
      netNode.network_secret = _networkSecretController.text.trim();
      // netNode.listeners = _listeners;
      // netNode.peer = _peer;
      // netNode.cidrproxy = _cidrproxy;
      // netNode.default_protocol = default_protocol;
      // netNode.dhcp = _dhcp;

      roomConfig.room_public = netNode;
      // roomConfig.server = _servers;
      roomConfig.create_time = widget.roomConfig?.create_time ?? DateTime.now();

      Navigator.of(context).pop(roomConfig);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存失败: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}

Widget _buildSettingsCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
