import 'dart:convert';
import 'package:astral/core/models/room.dart';
import 'dart:io' show gzip;
import 'package:flutter/foundation.dart';

const String encryptionSecret = '这就是密钥';

/// 简单的分享链接生成方式
/// 格式：base64url(gzip(json)) - 简洁且易于导入
String encryptRoomWithJWT(Room room, {bool includeNetworkConfig = false}) {
  try {
    if (room.name.isEmpty) {
      throw ArgumentError('房间名称不能为空');
    }

    // 创建精简的 JSON 对象，包含服务器列表和自定义参数
    final Map<String, dynamic> roomData = {
      'n': room.name,
      'r': room.roomName,
      'p': room.password,
      'm': room.messageKey,
      'e': room.encrypted ? 1 : 0,
      // 添加服务器列表和自定义参数
      if (room.servers.isNotEmpty) 's': room.servers,
      if (room.customParam.isNotEmpty) 'c': room.customParam,
      // 新增：携带网络配置
      if (includeNetworkConfig &&
          room.hasNetworkConfig &&
          room.networkConfigJson.isNotEmpty)
        'net': jsonDecode(room.networkConfigJson),
    };

    final String jsonString = jsonEncode(roomData);

    // Debug 打印 JSON 数据
    debugPrint('【房间分享】原始房间数据 JSON:');
    debugPrint(jsonEncode(roomData));
    debugPrint('【房间分享】服务器列表: ${room.servers}');
    debugPrint('【房间分享】自定义参数: ${room.customParam}');
    if (includeNetworkConfig && room.hasNetworkConfig) {
      debugPrint('【房间分享】携带网络配置: ${room.networkConfigJson}');
    }

    final List<int> compressed = gzip.encode(utf8.encode(jsonString));
    String encoded = base64Url.encode(compressed);
    encoded = encoded.replaceAll('=', '');

    return encoded;
  } catch (e) {
    throw Exception('房间加密失败: $e');
  }
}

/// 将分享码解密为房间对象
Room? decryptRoomFromJWT(String token) {
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

    // 解析网络配置（如果有）
    String networkConfigJson = '';
    bool hasNetworkConfig = false;
    if (roomData.containsKey('net') && roomData['net'] != null) {
      hasNetworkConfig = true;
      networkConfigJson = jsonEncode(roomData['net']);
      debugPrint('【房间导入】包含网络配置: $networkConfigJson');
    }

    return Room(
      name: roomData['n'] ?? '',
      roomName: roomData['r'] ?? '',
      password: roomData['p'] ?? '',
      messageKey: roomData['m'] ?? '',
      encrypted: (roomData['e'] ?? 0) == 1,
      tags: [],
      // 解析服务器列表和自定义参数
      servers: roomData['s'] != null ? List<String>.from(roomData['s']) : [],
      customParam: roomData['c'] ?? '',
      // 新增：网络配置字段
      hasNetworkConfig: hasNetworkConfig,
      networkConfigJson: networkConfigJson,
    );
  } catch (e) {
    print('解密房间信息失败: $e');
    return null;
  }
}

/// 将房间对象加密为密文
String encryptRoom(Room room) {
  final Map<String, dynamic> roomMap = {
    'n': room.name,
    'e': room.encrypted ? 1 : 0,
    'rn': room.roomName,
    'p': room.password,
    'mk': room.messageKey,
  };

  final String jsonString = jsonEncode(roomMap);
  final List<int> compressedData = gzip.encode(utf8.encode(jsonString));
  String encoded = base64Url.encode(compressedData);
  encoded = encoded.replaceAll('=', '');

  return encoded;
}

/// 将密文解密为房间对象
Room? decryptRoom(String encryptedString) {
  try {
    String paddedString = encryptedString;
    final int remainder = encryptedString.length % 4;
    if (remainder != 0) {
      paddedString = encryptedString + ('=' * (4 - remainder));
    }

    final List<int> compressedData = base64Url.decode(paddedString);
    final List<int> decompressedData = gzip.decode(compressedData);
    final String jsonString = utf8.decode(decompressedData);
    final Map<String, dynamic> roomMap = jsonDecode(jsonString);

    return Room(
      name: roomMap['n'] ?? '',
      encrypted: (roomMap['e'] as int?) == 1 ? true : false,
      roomName: roomMap['rn'] ?? '',
      password: roomMap['p'] ?? '',
      tags: [],
      messageKey: roomMap['mk'] ?? '',
    );
  } catch (e) {
    print('解密房间信息失败: $e');
    return null;
  }
}

/// 验证房间对象的有效性
(bool isValid, String? errorMessage) validateRoom(Room? room) {
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
Room cleanRoom(Room room) {
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
    hasNetworkConfig: room.hasNetworkConfig,
    networkConfigJson: room.networkConfigJson,
  );
}

/// 生成房间摘要信息
String generateRoomSummary(Room room) {
  final type = room.encrypted ? '🔒 加密房间' : '🔓 公开房间';
  final tags = room.tags.isNotEmpty ? '\n🏷️ ${room.tags.join(', ')}' : '';

  return '''
🏠 房间：${room.name}
$type$tags
'''.trim();
}

/// 检查分享码格式
bool isValidShareCode(String shareCode) {
  if (shareCode.isEmpty) return false;

  try {
    return decryptRoomFromJWT(shareCode) != null;
  } catch (e) {
    return false;
  }
}
