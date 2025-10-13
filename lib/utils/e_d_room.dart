import 'dart:convert';
import 'package:astral/k/models/room.dart';
import 'dart:io';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

// 常量 密文
const String encryptedRoom = '这就是密钥';
// JWT密钥
const String jwtSecret = '这就是密钥';

/// 将房间对象加密为密文并用JWT保护
///
/// 接收一个 [Room] 对象，返回JWT保护的加密字符串
/// 加密过程：
/// 1. 验证房间对象完整性
/// 2. 将Room对象转换为JSON
/// 3. 压缩JSON数据
/// 4. 进行Base64编码
/// 5. 使用JWT进行保护
String encryptRoomWithJWT(Room room) {
  try {
    // 验证房间对象完整性
    if (room.name.isEmpty) {
      throw ArgumentError('房间名称不能为空');
    }

    // 创建一个包含 Room 对象所有属性的 Map
    final Map<String, dynamic> roomMap = {
      'name': room.name,
      'encrypted': room.encrypted,
      'roomName': room.roomName,
      'password': room.password,
      'tags': room.tags,
      'messageKey': room.messageKey, // 添加消息密钥
      'version': '1.0', // 添加版本信息用于兼容性检查
      'timestamp': DateTime.now().millisecondsSinceEpoch, // 添加时间戳
    };

    // 将 Map 转换为 JSON 字符串
    final String jsonString = jsonEncode(roomMap);

    // 压缩JSON数据
    final List<int> compressedData = gzip.encode(utf8.encode(jsonString));

    // 将压缩后的数据进行 Base64 编码
    final String encryptedString = base64Encode(compressedData);

    // 使用JWT保护加密数据，添加更多元数据
    final jwt = JWT({
      'data': encryptedString,
      'room_type': room.encrypted ? 'encrypted' : 'public',
      'app_version': '1.0',
    }, issuer: 'astral_app');

    // 使用密钥签名JWT，设置合理的过期时间
    final token = jwt.sign(SecretKey(jwtSecret), expiresIn: Duration(days: 30));

    return token;
  } catch (e) {
    throw Exception('房间加密失败: $e');
  }
}

/// 将JWT保护的密文解密为房间对象
///
/// 接收一个JWT保护的加密字符串，返回解密后的 [Room] 对象
/// 解密过程：
/// 1. 验证JWT并提取数据
/// 2. 对密文进行Base64解码
/// 3. 解压数据
/// 4. 验证数据完整性
/// 5. 转换为Room对象
Room? decryptRoomFromJWT(String token) {
  try {
    // 验证输入
    if (token.isEmpty) {
      throw ArgumentError('分享码不能为空');
    }

    // 验证JWT并提取数据
    final JWT jwt = JWT.verify(token, SecretKey(jwtSecret));

    // 检查JWT是否过期
    if ((jwt.payload as Map<String, dynamic>)['exp'] != null) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(
        (jwt.payload as Map<String, dynamic>)['exp'] * 1000,
      );
      if (DateTime.now().isAfter(expiry)) {
        throw Exception('分享码已过期');
      }
    }

    // 验证发行者
    if (jwt.issuer != 'astral_app') {
      throw Exception('无效的分享码来源');
    }

    final String encryptedString = (jwt.payload as Map<String, dynamic>)['data'] as String;
    if (encryptedString.isEmpty) {
      throw Exception('分享码数据为空');
    }

    // 对密文进行Base64解码
    final List<int> compressedData = base64Decode(encryptedString);

    // 解压数据
    final List<int> decompressedData = gzip.decode(compressedData);
    final String jsonString = utf8.decode(decompressedData);

    // 将JSON字符串转换为Map
    final Map<String, dynamic> roomMap = jsonDecode(jsonString);

    // 验证必要字段
    if (!roomMap.containsKey('name') || roomMap['name'] == null) {
      throw Exception('房间数据缺少名称字段');
    }

    // 检查版本兼容性
    final version = roomMap['version'] as String?;
    if (version != null && version != '1.0') {
      // 这里可以添加版本兼容性处理逻辑
      print('警告：分享码版本($version)与当前版本(1.0)不匹配，可能存在兼容性问题');
    }

    // 检查时间戳（可选）
    final timestamp = roomMap['timestamp'] as int?;
    if (timestamp != null) {
      final shareTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final daysDiff = DateTime.now().difference(shareTime).inDays;
      if (daysDiff > 30) {
        print('警告：分享码创建时间超过30天，建议重新获取最新分享码');
      }
    }

    // 从Map创建Room对象
    return Room(
      name: roomMap['name'] as String? ?? '',
      encrypted: roomMap['encrypted'] as bool? ?? true,
      roomName: roomMap['roomName'] as String? ?? '',
      password: roomMap['password'] as String? ?? '',
      tags: List<String>.from(roomMap['tags'] ?? []),
      messageKey: roomMap['messageKey'] as String? ?? '',
    );
  } catch (e) {
    print('解密房间信息失败: $e');
    return null;
  }
}

/// 将房间对象加密为密文
///
/// 接收一个 [Room] 对象，返回加密后的密文字符串
/// 加密过程：将 Room 对象转换为 JSON，然后进行 Base64 编码
String encryptRoom(Room room) {
  // 创建一个包含 Room 对象所有属性的 Map
  final Map<String, dynamic> roomMap = {
    'name': room.name,
    'encrypted': room.encrypted, // 加密后的房间标记为已加密
    'roomName': room.roomName,
    'password': room.password,
    'tags': room.tags,
  };

  // 将 Map 转换为 JSON 字符串
  final String jsonString = jsonEncode(roomMap);

  // 将 JSON 字符串进行 Base64 编码
  final String encryptedString = base64Encode(utf8.encode(jsonString));

  return encryptedString;
}

/// 将密文解密为房间对象
///
/// 接收一个加密的密文字符串，返回解密后的 [Room] 对象
/// 解密过程：对密文进行 Base64 解码，然后转换为 Room 对象
Room? decryptRoom(String encryptedString) {
  try {
    // 对密文进行 Base64 解码
    final List<int> bytes = base64Decode(encryptedString);
    final String jsonString = utf8.decode(bytes);

    // 将 JSON 字符串转换为 Map
    final Map<String, dynamic> roomMap = jsonDecode(jsonString);

    // 从 Map 创建 Room 对象
    return Room(
      name: roomMap['name'] ?? '',
      encrypted: roomMap['encrypted'] ?? true,
      roomName: roomMap['roomName'] ?? '',
      password: roomMap['password'] ?? '',
      tags: List<String>.from(roomMap['tags'] ?? []),
    );
  } catch (e) {
    // 解密失败时返回null
    return null;
  }
}

/// 验证房间对象的有效性
///
/// 检查房间对象的各个字段是否符合要求
/// 返回验证结果和错误信息
(bool isValid, String? errorMessage) validateRoom(Room? room) {
  if (room == null) {
    return (false, '房间对象为空');
  }

  // 验证房间名称
  if (room.name.isEmpty || room.name.trim().isEmpty) {
    return (false, '房间名称不能为空');
  }

  if (room.name.length > 50) {
    return (false, '房间名称过长，不能超过50个字符');
  }

  // 验证房间名称字符
  if (room.name.contains(RegExp(r'[<>:"/\\|?*]'))) {
    return (false, '房间名称包含非法字符');
  }

  // 对于非加密房间，验证房间号和密码
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

  // 验证标签
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
///
/// 去除多余的空白字符，标准化数据格式
Room cleanRoom(Room room) {
  return Room(
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
  );
}

/// 生成房间摘要信息
///
/// 用于分享时显示房间的基本信息
String generateRoomSummary(Room room) {
  final type = room.encrypted ? '🔒 加密房间' : '🔓 公开房间';
  final tags = room.tags.isNotEmpty ? '\n🏷️ ${room.tags.join(', ')}' : '';

  return '''
🏠 房间：${room.name}
$type$tags
'''.trim();
}

/// 检查分享码格式
///
/// 验证分享码是否符合预期格式
bool isValidShareCode(String shareCode) {
  if (shareCode.isEmpty) return false;

  // JWT格式验证：应该包含三个部分，用点分隔
  final parts = shareCode.split('.');
  if (parts.length != 3) return false;

  // 检查每个部分是否为有效的Base64字符串
  try {
    for (String part in parts) {
      // 添加必要的填充字符
      String paddedPart = part;
      while (paddedPart.length % 4 != 0) {
        paddedPart += '=';
      }
      base64Decode(paddedPart);
    }
    return true;
  } catch (e) {
    return false;
  }
}
