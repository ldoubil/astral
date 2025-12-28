import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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
  final VoidCallback? onConnect;

  const MinecraftServerCard({
    super.key,
    required this.host,
    required this.port,
    this.onConnect,
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

  Future<void> _fetchServerInfo() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              'https://motd.minebbs.com/api/status?ip=${_serverInfo.host}&port=${_serverInfo.port}&stype=auto&srv=false',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;

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
            });
          }
        } else {
          throw '服务器离线';
        }
      } else {
        throw 'HTTP ${response.statusCode}';
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _serverInfo.isLoading = false;
          _serverInfo.errorMessage = '无法获取服务器信息';
        });
      }
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
                  // 连接按钮
                  FilledButton.icon(
                    onPressed: widget.onConnect,
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
