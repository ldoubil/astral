import 'dart:convert';
import 'dart:io' show gzip;

import 'package:astral/core/bootstrap/file_logger.dart';
import 'package:astral/core/models/room.dart';

/// 房间分享编解码（纯逻辑，不含 Flutter UI）
///
/// 分享码格式：base64url(gzip(json))
class RoomShareCodec {
  static const String appScheme = 'astral';
  static const String roomPath = 'room';

  /// 生成房间分享链接
  ///
  /// [includeDeepLink] 为 true 时返回 `astral://room?code=...`，否则仅返回分享码
  static String generateShareLink(Room room, {bool includeDeepLink = true}) {
    try {
      final (isValid, errorMessage) = validateRoom(room);
      if (!isValid) {
        throw Exception('房间数据无效: $errorMessage');
      }

      final cleanedRoom = cleanRoom(room);
      final shareCode = encryptRoom(
        cleanedRoom,
        includeNetworkConfig: cleanedRoom.networkConfigJson.isNotEmpty,
      );

      if (includeDeepLink) {
        return '$appScheme://$roomPath?code=$shareCode';
      }
      return shareCode;
    } catch (e) {
      throw Exception('生成分享链接失败: $e');
    }
  }

  /// 生成分享文本（含房间摘要与可选使用说明）
  static String generateShareText(
    Room room, {
    bool includeInstructions = true,
  }) {
    final link = generateShareLink(room);
    final roomSummary = generateRoomSummary(room);

    String shareOptions = '';
    final hasServers = room.servers.isNotEmpty;
    final hasNetworkConfig = room.networkConfigJson.isNotEmpty;
    if (hasServers || hasNetworkConfig) {
      shareOptions = '\n📦 分享选项：\n';
      if (hasServers) {
        shareOptions += '  ✓ 携带服务器列表\n';
      }
      if (hasNetworkConfig) {
        shareOptions += '  ✓ 携带网络配置\n';
      }
    }

    String shareText = '''
🎮 Astral 房间分享

$roomSummary$shareOptions
🔗 分享链接：$link
''';

    if (includeInstructions) {
      shareText += '''

📖 使用说明：
1. 确保已安装 Astral 应用
2. 点击上方链接自动导入房间
3. 或复制分享码在应用内手动导入

⏰ 分享链接有效期：30天
''';
    }

    return shareText;
  }

  /// 从分享文本或深度链接中提取分享码；无效则返回 null
  static String? extractShareCode(String shareText) {
    String shareCode = shareText.trim();

    if (shareCode.startsWith('$appScheme://')) {
      final uri = Uri.tryParse(shareCode);
      if (uri == null || uri.host != roomPath) {
        return null;
      }
      shareCode = uri.queryParameters['code'] ?? '';
    }

    shareCode = shareCode.replaceAll(RegExp(r'\s+'), '');
    if (shareCode.isEmpty) return null;
    return shareCode;
  }

  /// 加密房间为分享码
  static String encryptRoom(Room room, {bool includeNetworkConfig = false}) {
    try {
      if (room.name.isEmpty) {
        throw ArgumentError('房间名称不能为空');
      }

      final Map<String, dynamic> roomData = {
        'n': room.name,
        'r': room.roomName,
        'p': room.password,
        'm': room.messageKey,
        'e': room.encrypted ? 1 : 0,
        if (room.servers.isNotEmpty) 's': room.servers,
        if (room.customParam.isNotEmpty) 'c': room.customParam,
        if (includeNetworkConfig && room.networkConfigJson.isNotEmpty)
          'net': jsonDecode(room.networkConfigJson),
      };

      final String jsonString = jsonEncode(roomData);
      final List<int> compressed = gzip.encode(utf8.encode(jsonString));
      String encoded = base64Url.encode(compressed);
      encoded = encoded.replaceAll('=', '');

      return encoded;
    } catch (e) {
      throw Exception('房间加密失败: $e');
    }
  }

  /// 将分享码解密为房间对象
  static Room? decryptRoom(String token) {
    try {
      if (token.isEmpty) {
        throw ArgumentError('分享码不能为空');
      }

      String paddedToken = token;
      final int remainder = token.length % 4;
      if (remainder != 0) {
        paddedToken = token + ('=' * (4 - remainder));
      }

      final List<int> compressed = base64Url.decode(paddedToken);
      final List<int> decompressed = gzip.decode(compressed);
      final String jsonString = utf8.decode(decompressed);
      final Map<String, dynamic> roomData = jsonDecode(jsonString);

      String networkConfigJson = '';
      if (roomData.containsKey('net') && roomData['net'] != null) {
        networkConfigJson = jsonEncode(roomData['net']);
      }

      return Room(
        name: roomData['n'] ?? '',
        roomName: roomData['r'] ?? '',
        password: roomData['p'] ?? '',
        messageKey: roomData['m'] ?? '',
        encrypted: (roomData['e'] ?? 0) == 1,
        tags: [],
        servers: roomData['s'] != null ? List<String>.from(roomData['s']) : [],
        customParam: roomData['c'] ?? '',
        networkConfigJson: networkConfigJson,
      );
    } catch (e) {
      FileLogger().warning('解密房间信息失败: $e');
      return null;
    }
  }

  /// 验证房间对象的有效性
  static (bool isValid, String? errorMessage) validateRoom(Room? room) {
    if (room == null) {
      return (false, '房间对象为空');
    }

    if (room.name.isEmpty || room.name.trim().isEmpty) {
      return (false, '房间名称不能为空');
    }

    if (room.name.length > 50) {
      return (false, '房间名称过长，不能超过50个字符');
    }

    if (room.name.contains(RegExp(r'[<>:"/\\|?*]'))) {
      return (false, '房间名称包含非法字符');
    }

    if (!room.encrypted) {
      if (room.roomName.isEmpty) {
        return (false, '公开房间必须有房间号');
      }

      if (room.roomName.length > 100) {
        return (false, '房间号过长，不能超过100个字符');
      }

      if (room.password.length > 100) {
        return (false, '房间密码过长，不能超过100个字符');
      }
    }

    if (room.tags.length > 10) {
      return (false, '标签数量不能超过10个');
    }

    for (String tag in room.tags) {
      if (tag.length > 20) {
        return (false, '标签长度不能超过20个字符');
      }
      if (tag.contains(RegExp(r'[<>:"/\\|?*]'))) {
        return (false, '标签包含非法字符');
      }
    }

    return (true, null);
  }

  /// 清理房间对象数据
  static Room cleanRoom(Room room) {
    return Room(
      id: room.id,
      name: room.name.trim(),
      encrypted: room.encrypted,
      roomName: room.roomName.trim(),
      password: room.password.trim(),
      messageKey: room.messageKey.trim(),
      tags:
          room.tags
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toList(),
      sortOrder: room.sortOrder,
      servers: room.servers,
      customParam: room.customParam.trim(),
      networkConfigJson: room.networkConfigJson,
    );
  }

  /// 生成房间摘要信息
  static String generateRoomSummary(Room room) {
    final type = room.encrypted ? '🔒 加密房间' : '🔓 公开房间';
    final tags = room.tags.isNotEmpty ? '\n🏷️ ${room.tags.join(', ')}' : '';

    return '''
🏠 房间：${room.name}
$type$tags
'''.trim();
  }

  /// 检查分享码格式是否可解密
  static bool isValidShareCode(String shareCode) {
    if (shareCode.isEmpty) return false;

    try {
      return decryptRoom(shareCode) != null;
    } catch (e) {
      return false;
    }
  }
}
