import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Minecraft服务器信息
class MinecraftServerInfo {
  final String host;
  final int port;
  String? serverIcon; // Base64编码的图标
  String motd;
  int maxPlayers;
  int onlinePlayers;
  String version;
  String serverType;
  int protocol;
  bool isLoading = true;
  String? errorMessage;

  MinecraftServerInfo({
    required this.host,
    required this.port,
    this.serverIcon,
    this.motd = 'Minecraft Server',
    this.maxPlayers = 0,
    this.onlinePlayers = 0,
    this.version = '',
    this.serverType = 'Java',
    this.protocol = 0,
  });
}

/// Minecraft服务器卡片组件
class MinecraftServerCard extends StatefulWidget {
  final String host;
  final int port;
  final bool isConnected;
  final int? localPort;
  final Function(String serverMotd)? onToggleConnection;

  const MinecraftServerCard({
    super.key,
    required this.host,
    required this.port,
    this.isConnected = false,
    this.localPort,
    this.onToggleConnection,
  });

  @override
  State<MinecraftServerCard> createState() => _MinecraftServerCardState();
}

class _MinecraftServerCardState extends State<MinecraftServerCard> {
  late MinecraftServerInfo _serverInfo;
  String? _cachedPackPng;

  @override
  void initState() {
    super.initState();
    _serverInfo = MinecraftServerInfo(host: widget.host, port: widget.port);
    _fetchServerInfo();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    _cachedPackPng = await rootBundle.loadString('assets/packpng_base64');
    if (mounted) setState(() {});
  }

  // 创建一个忽略证书验证的HTTP客户端（仅用于特定API）
  http.Client _createHttpClient() {
    final ioClient =
        HttpClient()
          ..badCertificateCallback = (
            X509Certificate cert,
            String host,
            int port,
          ) {
            // 仅对 motd.minebbs.com 忽略证书验证
            return host == 'motd.minebbs.com';
          };
    return IOClient(ioClient);
  }

  Future<void> _fetchServerInfo() async {
    final client = _createHttpClient();
    try {
      print('🔍 正在查询服务器: ${_serverInfo.host}:${_serverInfo.port}');

      final response = await client
          .get(
            Uri.parse(
              'https://motd.minebbs.com/api/status?ip=${_serverInfo.host}&port=${_serverInfo.port}&stype=auto&srv=false',
            ),
          )
          .timeout(const Duration(seconds: 15));

      print('📡 API响应状态码: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        print('📦 API返回数据: ${jsonData['status']}');

        if (jsonData['status'] == 'online') {
          if (mounted) {
            setState(() {
              _serverInfo.isLoading = false;
              _serverInfo.motd = jsonData['pureMotd'] ?? 'Minecraft Server';
              _serverInfo.version = jsonData['version'] ?? '';
              _serverInfo.serverType = jsonData['type'] ?? 'Java';
              _serverInfo.protocol = jsonData['protocol'] ?? 0;

              // 获取玩家数据
              if (jsonData['players'] is Map) {
                final players = jsonData['players'] as Map<String, dynamic>;
                _serverInfo.onlinePlayers = players['online'] ?? 0;
                _serverInfo.maxPlayers = players['max'] ?? 0;
              }

              // 获取服务器图标
              if (jsonData.containsKey('icon') && jsonData['icon'] != null) {
                final iconData = jsonData['icon'] as String;
                if (iconData.startsWith('data:image/png;base64,')) {
                  _serverInfo.serverIcon = iconData;
                }
              }
              print('✅ 服务器信息获取成功: ${_serverInfo.motd}');
            });
          }
        } else {
          print('⚠️ 服务器状态: ${jsonData['status']}');
          throw '服务器离线或无法访问';
        }
      } else {
        print('❌ HTTP错误: ${response.statusCode}');
        throw 'HTTP ${response.statusCode}';
      }
    } on TimeoutException {
      print('⏱️ 请求超时');
      if (mounted) {
        setState(() {
          _serverInfo.isLoading = false;
          _serverInfo.errorMessage = '查询超时，请检查网络连接';
        });
      }
    } catch (e) {
      print('❌ 获取服务器信息失败: $e');
      if (mounted) {
        setState(() {
          _serverInfo.isLoading = false;
          _serverInfo.errorMessage = '无法获取服务器信息\n${e.toString()}';
        });
      }
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_serverInfo.isLoading) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      );
    }

    if (_serverInfo.errorMessage != null) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '连接失败',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _serverInfo.errorMessage ?? '未知错误',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // 点击卡片时的操作
        },
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // 背景装饰图标
            Positioned(
              right: -20,
              top: -10,
              bottom: -10,
              child: Opacity(
                opacity: 0.2,
                child: Transform.rotate(
                  angle: 0.15,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildServerIcon(),
                  ),
                ),
              ),
            ),
            // 前景内容
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // 服务器图标（小的）
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildServerIcon(),
                  ),
                  const SizedBox(width: 12),
                  // 服务器信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 第一行：状态 + 服务器类型
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '在线',
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _serverInfo.serverType,
                                style: Theme.of(
                                  context,
                                ).textTheme.labelSmall?.copyWith(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            if (_serverInfo.version.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  _serverInfo.version,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelSmall?.copyWith(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                    fontSize: 10,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        // 第二行：MOTD 或服务器名称
                        Text(
                          _serverInfo.motd.isNotEmpty
                              ? _serverInfo.motd.split('\n').first
                              : 'Minecraft Server',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // 第三行：玩家数
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 14,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${_serverInfo.onlinePlayers}/${_serverInfo.maxPlayers}',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 连接/断开按钮
                  widget.isConnected
                      ? FilledButton.tonalIcon(
                        onPressed: () {
                          print('尝试断开服务器: ${widget.host}:${widget.port}');
                          widget.onToggleConnection?.call(_serverInfo.motd);
                        },
                        icon: const Icon(Icons.stop, size: 20),
                        label: const Text('断开'),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.errorContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.onErrorContainer,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      )
                      : FilledButton.icon(
                        onPressed: () {
                          print('尝试连接到服务器: ${widget.host}:${widget.port}');
                          widget.onToggleConnection?.call(_serverInfo.motd);
                        },
                        icon: const Icon(Icons.play_arrow, size: 20),
                        label: const Text('连接'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerIcon() {
    if (_serverInfo.serverIcon != null) {
      try {
        return Image.memory(
          base64Decode(
            _serverInfo.serverIcon!.replaceFirst('data:image/png;base64,', ''),
          ),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildDefaultIcon(),
        );
      } catch (e) {
        return _buildDefaultIcon();
      }
    }
    return _buildDefaultIcon();
  }

  Widget _buildDefaultIcon() {
    if (_cachedPackPng != null) {
      try {
        return Image.memory(
          base64Decode(
            _cachedPackPng!.replaceFirst('data:image/png;base64,', ''),
          ),
          fit: BoxFit.cover,
        );
      } catch (e) {
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.games,
            size: 32,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
      }
    }
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.games,
        size: 32,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
