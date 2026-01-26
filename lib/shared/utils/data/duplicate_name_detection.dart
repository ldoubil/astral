/// 重复名称检测工具类
/// 用于检测并处理重复的房间名称，避免房间重名

import 'package:astral/core/models/room.dart';

/// 重复名称检测类
class DuplicateNameDetection {
  /// 检测并处理重复的房间名称
  ///
  /// [originalName] 原始房间名称
  /// [existingRooms] 现有的房间列表
  /// [excludedRoomId] 需要排除的房间ID（用于更新房间名称时避免检测自身）
  /// 返回处理后的不重复房间名称
  static String detectAndHandleDuplicateName(
    String originalName,
    List<Room> existingRooms,
    {int? excludedRoomId}
  ) {
    // 如果原始名称为空，返回默认名称
    if (originalName.isEmpty) {
      return _generateDefaultName(existingRooms, excludedRoomId);
    }

    // 过滤掉需要排除的房间
    final filteredRooms = existingRooms.where((room) {
      return excludedRoomId == null || room.id != excludedRoomId;
    }).toList();

    // 检查是否存在相同名称的房间
    final isDuplicate = filteredRooms.any((room) {
      return room.name == originalName;
    });

    // 如果没有重复，直接返回原始名称
    if (!isDuplicate) {
      return originalName;
    }

    // 解析原始名称，提取基础名称和现有数字
    final (baseName, existingIndex) = _parseRoomName(originalName);

    // 找到可用的索引
    final availableIndex = _findAvailableIndex(
      baseName,
      filteredRooms,
      existingIndex,
    );

    // 返回带数字的新名称
    return _formatRoomName(baseName, availableIndex);
  }

  /// 生成默认房间名称
  static String _generateDefaultName(List<Room> existingRooms, int? excludedRoomId) {
    const baseName = '新房间';
    
    // 过滤掉需要排除的房间
    final filteredRooms = existingRooms.where((room) {
      return excludedRoomId == null || room.id != excludedRoomId;
    }).toList();

    // 找到可用的索引
    final availableIndex = _findAvailableIndex(baseName, filteredRooms, 0);

    // 返回带数字的新名称
    return _formatRoomName(baseName, availableIndex);
  }

  /// 解析房间名称，提取基础名称和现有数字
  /// 返回 (baseName, existingIndex)
  static (String, int) _parseRoomName(String name) {
    // 匹配末尾的数字格式，如 "房间名(1)" 或 "房间名 (2)"
    final regex = RegExp(r'^(.+?)\s?\((\d+)\)$');
    final match = regex.firstMatch(name);

    if (match != null && match.groupCount >= 2) {
      final baseName = match.group(1)?.trim() ?? name;
      final index = int.tryParse(match.group(2) ?? '1') ?? 1;
      return (baseName, index);
    }

    // 如果没有数字，返回原始名称和0
    return (name, 0);
  }

  /// 查找可用的索引
  static int _findAvailableIndex(
    String baseName,
    List<Room> existingRooms,
    int startIndex,
  ) {
    int index = startIndex;
    
    // 如果起始索引是0，从1开始查找
    if (index == 0) {
      index = 1;
    }

    // 循环查找可用的索引
    while (true) {
      final testName = _formatRoomName(baseName, index);
      final isUsed = existingRooms.any((room) => room.name == testName);
      
      if (!isUsed) {
        return index;
      }
      
      index++;
    }
  }

  /// 格式化房间名称
  static String _formatRoomName(String baseName, int index) {
    if (index == 0) {
      return baseName;
    }
    return '$baseName ($index)';
  }
}
