import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Minecraft服务器信�?
class MinecraftServerInfo {
  final String host;
  final int port;
  String? serverIcon; // Base64编码的图�?
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

/// Minecraft服务器卡片组�?
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

  Future<void> _fetchServerInfo() async {
    print('Fetching server info ${_serverInfo.host}:${_serverInfo.port}');

    try {
      final status = await _queryServerStatus(
        host: _serverInfo.host,
        port: _serverInfo.port,
      );

      if (!mounted) return;
      setState(() {
        _serverInfo.isLoading = false;
        _serverInfo.motd = status.motd.isNotEmpty
            ? status.motd
            : 'Minecraft Server';
        _serverInfo.version = status.version;
        _serverInfo.serverType = status.serverType;
        _serverInfo.protocol = status.protocol;
        _serverInfo.onlinePlayers = status.onlinePlayers;
        _serverInfo.maxPlayers = status.maxPlayers;
        _serverInfo.serverIcon = status.serverIcon;
        _serverInfo.errorMessage = null;
        print('Server info loaded ${_serverInfo.motd}');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _serverInfo.isLoading = false;
        _serverInfo.errorMessage = e.toString();
      });
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
                  // 服务器图标（小的�?
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
                  // 服务器信�?
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 第一行：状�?+ 服务器类�?
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
                        // 第三行：玩家�?
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
                          print('尝试断开服务�? ${widget.host}:${widget.port}');
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


class _McStatusResult {
  final String motd;
  final int maxPlayers;
  final int onlinePlayers;
  final String version;
  final String serverType;
  final int protocol;
  final String? serverIcon;

  const _McStatusResult({
    required this.motd,
    required this.maxPlayers,
    required this.onlinePlayers,
    required this.version,
    required this.serverType,
    required this.protocol,
    required this.serverIcon,
  });
}

class _SocketReader {
  final Socket _socket;
  final List<int> _buffer = [];
  final StreamSubscription<List<int>> _subscription;
  Completer<void>? _dataWaiter;
  Object? _error;
  StackTrace? _stackTrace;
  bool _isDone = false;

  _SocketReader(this._socket)
      : _subscription = _socket.listen(
          null,
          onError: null,
          onDone: null,
          cancelOnError: false,
        ) {
    _subscription.onData((data) {
      _buffer.addAll(data);
      _dataWaiter?.complete();
      _dataWaiter = null;
    });
    _subscription.onError((error, stackTrace) {
      _error = error;
      _stackTrace = stackTrace;
      _dataWaiter?.complete();
      _dataWaiter = null;
    });
    _subscription.onDone(() {
      _isDone = true;
      _dataWaiter?.complete();
      _dataWaiter = null;
    });
  }

  Future<int> readByte() async {
    await _ensureAvailable(1);
    return _buffer.removeAt(0);
  }

  Future<Uint8List> readBytes(int length) async {
    await _ensureAvailable(length);
    final data = Uint8List.fromList(_buffer.sublist(0, length));
    _buffer.removeRange(0, length);
    return data;
  }

  Future<void> _ensureAvailable(int length) async {
    while (_buffer.length < length) {
      if (_error != null) {
        throw _error!;
      }
      if (_isDone) {
        break;
      }
      _dataWaiter ??= Completer<void>();
      await _dataWaiter!.future;
    }
    if (_buffer.length < length) {
      throw const SocketException('Connection closed before response completed');
    }
  }

  Future<void> close() async {
    await _subscription.cancel();
  }
}

Future<_McStatusResult> _queryServerStatus({
  required String host,
  required int port,
}) async {
  final socket = await Socket.connect(
    host,
    port,
    timeout: const Duration(seconds: 5),
  );
  final reader = _SocketReader(socket);

  try {
    final handshake = BytesBuilder();
    handshake.add(_packVarint(0)); // Packet ID
    handshake.add(_packVarint(0)); // Protocol version (auto)
    handshake.add(_packString(host));
    handshake.add(_packPort(port));
    handshake.add(_packVarint(1)); // Next state: status

    socket.add(_packData(handshake.toBytes()));
    socket.add(_packData(Uint8List.fromList([0x00]))); // Status request

    final packetLength = await _readVarint(reader);
    if (packetLength <= 0) {
      throw const SocketException('Empty response');
    }

    final packetId = await _readVarint(reader);
    if (packetId != 0x00) {
      throw SocketException('Unexpected packet id: $packetId');
    }

    final stringLength = await _readVarint(reader);
    final payload = await reader.readBytes(stringLength);
    final jsonData = jsonDecode(utf8.decode(payload)) as Map<String, dynamic>;

    final players = jsonData['players'] as Map<String, dynamic>?;
    final version = jsonData['version'] as Map<String, dynamic>?;

    return _McStatusResult(
      motd: _extractMotd(jsonData['description']),
      maxPlayers: players?['max'] as int? ?? 0,
      onlinePlayers: players?['online'] as int? ?? 0,
      version: version?['name'] as String? ?? '',
      serverType: 'Java',
      protocol: version?['protocol'] as int? ?? 0,
      serverIcon: jsonData['favicon'] as String?,
    );
  } finally {
    await reader.close();
    socket.destroy();
  }
}

Uint8List _packVarint(int value) {
  final bytes = <int>[];
  var current = value;
  while (true) {
    var temp = current & 0x7F;
    current >>= 7;
    if (current != 0) {
      temp |= 0x80;
    }
    bytes.add(temp);
    if (current == 0) break;
  }
  return Uint8List.fromList(bytes);
}

Uint8List _packData(Uint8List data) {
  final builder = BytesBuilder();
  builder.add(_packVarint(data.length));
  builder.add(data);
  return builder.toBytes();
}

Uint8List _packString(String value) {
  final encoded = utf8.encode(value);
  final builder = BytesBuilder();
  builder.add(_packVarint(encoded.length));
  builder.add(encoded);
  return builder.toBytes();
}

Uint8List _packPort(int port) {
  final data = ByteData(2)..setUint16(0, port, Endian.big);
  return data.buffer.asUint8List();
}

Future<int> _readVarint(_SocketReader reader) async {
  var numRead = 0;
  var result = 0;
  int read;
  do {
    read = await reader.readByte();
    final value = read & 0x7F;
    result |= value << (7 * numRead);
    numRead++;
    if (numRead > 5) {
      throw const FormatException('Varint is too big');
    }
  } while ((read & 0x80) != 0);
  return result;
}

String _extractMotd(dynamic description) {
  if (description == null) {
    return '';
  }
  final buffer = StringBuffer();

  void visit(dynamic node) {
    if (node == null) {
      return;
    }
    if (node is String) {
      buffer.write(node);
      return;
    }
    if (node is Map<String, dynamic>) {
      final text = node['text'];
      if (text is String) {
        buffer.write(text);
      }
      final extra = node['extra'];
      if (extra is List) {
        for (final item in extra) {
          visit(item);
        }
      }
      return;
    }
    if (node is List) {
      for (final item in node) {
        visit(item);
      }
    }
  }

  visit(description);
  return buffer.toString();
}