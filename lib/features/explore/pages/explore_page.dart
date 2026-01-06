import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:astral/src/rust/api/forward.dart';
import 'package:astral/src/rust/api/multicast.dart';
import 'package:astral/features/nat_test/pages/nat_test_page.dart';
import 'package:astral/features/magic_wall/pages/magic_wall_page.dart';
import 'package:astral/features/settings/pages/network/port_whitelist_page.dart';
import 'package:astral/core/database/app_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:astral/shared/widgets/cards/minecraft_server_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

/// 服务器配置
class ServerConfig {
  final String name;
  final String host;
  final int port;

  ServerConfig({required this.name, required this.host, required this.port});

  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      name: json['name'] as String,
      host: json['host'] as String,
      port: json['port'] as int,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'host': host, 'port': port};
}

/// 连接状态
class ServerConnection {
  final int localPort;
  final int forwardIndex;
  final int multicastIndex;

  ServerConnection({
    required this.localPort,
    required this.forwardIndex,
    required this.multicastIndex,
  });
}

/// 游戏服务器项目数据模型
class GameItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const GameItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

/// 探索页面 - 用于服务器分享
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  // 服务器配置列表
  List<ServerConfig> _servers = [];
  bool _isLoadingServers = true;

  // 连接状态管理（服务器host:port -> 连接信息）
  final Map<String, ServerConnection> _connections = {};

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  // 从远程 URL 加载服务器列表
  Future<void> _loadServers() async {
    try {
      final response = await http
          .get(Uri.parse('https://astral.fan/servers.json'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final serversList = jsonData['mcservers'] as List<dynamic>;

        if (mounted) {
          setState(() {
            _servers =
                serversList
                    .map(
                      (item) =>
                          ServerConfig.fromJson(item as Map<String, dynamic>),
                    )
                    .toList();
            _isLoadingServers = false;
          });
        }
        print('✅ 已加载 ${_servers.length} 个服务器配置');
      } else {
        throw '服务器返回错误: ${response.statusCode}';
      }
    } catch (e) {
      print('❌ 加载服务器配置失败: $e');
      if (mounted) {
        setState(() {
          _isLoadingServers = false;
        });
      }
    }
  }

  // 生成随机端口 (10000-60000)
  int _generateRandomPort() {
    final random = Random();
    return 10000 + random.nextInt(50000);
  }

  // 生成组播消息
  String _generateMotdMessage(String serverName, int localPort) {
    return "[MOTD]§k||§r §6§l[Astral]§r §k||§r §d§l$serverName[/MOTD][AD]$localPort[/AD]";
  }

  // 连接服务器
  Future<void> _connectServer(ServerConfig server) async {
    final serverKey = '${server.host}:${server.port}';

    try {
      // 生成随机端口
      final localPort = _generateRandomPort();
      final listenAddr = '0.0.0.0:$localPort';
      final forwardAddr = serverKey;

      // 创建转发服务器
      final forwardIndex = await createForwardServer(
        listenAddr: listenAddr,
        forwardAddr: forwardAddr,
      );

      // 生成组播消息
      final motdMessage = _generateMotdMessage(server.name, localPort);
      final messageData = Uint8List.fromList(utf8.encode(motdMessage));

      // 创建组播发送器
      final multicastIndex = await createMulticastSender(
        multicastAddr: "224.0.2.60",
        port: 4445,
        data: messageData,
        intervalMs: BigInt.from(1500),
      );

      // 保存连接信息
      if (mounted) {
        setState(() {
          _connections[serverKey] = ServerConnection(
            localPort: localPort,
            forwardIndex: forwardIndex.toInt(),
            multicastIndex: multicastIndex.toInt(),
          );
        });
      }

      print('✅ 已连接服务器: $serverKey -> 127.0.0.1:$localPort');
      print('✅ 已启动组播广播');

      // 显示连接成功弹窗
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text('连接成功'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '服务器已成功共享至局域网！',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '连接步骤：',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '1. 打开《Minecraft》游戏\n2. 点击“多人游戏”\n3. 在局域网服务器列表中找到并连接',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('知道了'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      print('❌ 连接失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('连接失败: $e')));
      }
    }
  }

  // 断开服务器
  Future<void> _disconnectServer(ServerConfig server) async {
    final serverKey = '${server.host}:${server.port}';
    final connection = _connections[serverKey];

    if (connection == null) return;

    try {
      // 停止转发服务器
      await stopForwardServer(index: BigInt.from(connection.forwardIndex));

      // 停止组播发送器
      await stopMulticastSender(index: BigInt.from(connection.multicastIndex));
      if (mounted) {
        setState(() {
          _connections.remove(serverKey);
        });
      }

      print('✅ 已断开服务器: $serverKey');
    } catch (e) {
      print('❌ 断开失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('断开失败: $e')));
      }
    }
  }

  // 切换连接状态
  Future<void> _toggleConnection(ServerConfig server) async {
    final serverKey = '${server.host}:${server.port}';
    final isConnected = _connections.containsKey(serverKey);

    if (isConnected) {
      await _disconnectServer(server);
    } else {
      await _connectServer(server);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle(context, '服务器推荐'),
                const SizedBox(height: 12),
                // 动态生成服务器卡片
                ..._servers.map((server) {
                  final serverKey = '${server.host}:${server.port}';
                  final isConnected = _connections.containsKey(serverKey);
                  final localPort = _connections[serverKey]?.localPort;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MinecraftServerCard(
                      host: server.host,
                      port: server.port,
                      isConnected: isConnected,
                      localPort: localPort,
                      onToggleConnection: (_) {
                        _toggleConnection(server);
                      },
                    ),
                  );
                }),
                const SizedBox(height: 32),

                _buildSectionTitle(context, '联机工具'),
                const SizedBox(height: 12),
                // 魔法墙功能（仅 Windows 平台显示）
                if (Platform.isWindows) ...[
                  _buildListTile(
                    context,
                    GameItem(
                      title: '魔法墙',
                      subtitle: '高级防火墙管理',
                      icon: Icons.security,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MagicWallPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                _buildListTile(
                  context,
                  GameItem(
                    title: '端口白名单',
                    subtitle: '配置TCP/UDP端口访问白名单',
                    icon: Icons.security_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PortWhitelistPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _buildListTile(
                  context,
                  GameItem(
                    title: 'NAT 类型测试',
                    subtitle: '检测您的网络 NAT 类型',
                    icon: Icons.network_check,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NatTestPage(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _buildListTile(
                  context,
                  GameItem(
                    title: 'Minecraft局域网修复',
                    subtitle: '..... 开发中 .....',
                    icon: Icons.group,
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 32),

                // 数据管理部分 - 临时禁用
                // _buildSectionTitle(context, '数据管理'),
                // const SizedBox(height: 12),
                // _buildListTile(
                //   context,
                //   GameItem(
                //     title: '导出配置',
                //     subtitle: '导出所有配置数据到文件',
                //     icon: Icons.upload_file,
                //     onTap: _exportDatabase,
                //   ),
                // ),
                // const SizedBox(height: 8),
                // _buildListTile(
                //   context,
                //   GameItem(
                //     title: '导入配置',
                //     subtitle: '从文件导入配置数据',
                //     icon: Icons.download,
                //     onTap: _importDatabase,
                //   ),
                // ),
                // const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  // 导出数据库
  Future<void> _exportDatabase() async {
    try {
      // 获取导出路径
      String? exportPath;

      if (Platform.isAndroid) {
        // Android 使用下载目录
        final directory = await getExternalStorageDirectory();
        exportPath = directory?.path;
      } else {
        // 其他平台使用文件选择器选择目录
        exportPath = await FilePicker.platform.getDirectoryPath(
          dialogTitle: '选择导出路径',
        );
      }

      if (exportPath == null) return;

      // 显示加载对话框
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );
      }

      // 执行导出
      final filePath = await AppDatabase().exportDatabase(exportPath);

      // 关闭加载对话框
      if (mounted) Navigator.of(context).pop();

      // 显示成功消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出成功: $filePath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // 关闭加载对话框
      if (mounted) Navigator.of(context).pop();

      // 显示错误消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 导入数据库
  Future<void> _importDatabase() async {
    try {
      // 选择导入文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['isar'],
        dialogTitle: '选择导入文件',
      );

      if (result == null || result.files.single.path == null) return;

      final filePath = result.files.single.path!;

      // 显示确认对话框
      if (mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('确认导入'),
                content: const Text('导入配置将替换当前所有数据，是否继续？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('确认'),
                  ),
                ],
              ),
        );

        if (confirmed != true) return;
      }

      // 显示加载对话框
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );
      }

      // 执行导入（会自动调用 ServiceManager.reload()）
      await AppDatabase().importDatabase(filePath);

      // 关闭加载对话框
      if (mounted) Navigator.of(context).pop();

      // 显示成功消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('导入成功，配置已刷新'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // 关闭加载对话框
      if (mounted) Navigator.of(context).pop();

      // 显示错误消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildListTile(BuildContext context, GameItem item) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Icon(
          item.icon,
          size: 24,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          item.title,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          item.subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: item.onTap,
      ),
    );
  }
}
