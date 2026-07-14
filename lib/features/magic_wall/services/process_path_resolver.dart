import 'dart:io';

import 'package:astral/core/database/dao/magic_wall_dao.dart';
import 'package:astral/core/models/magic_wall_model.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/features/magic_wall/models/magic_wall_group_bundle.dart';
import 'package:flutter/foundation.dart';

/// Resolves executable paths for Magic Wall process-based auto-manage.
class ProcessPathResolver {
  final Map<String, String> processExecutablePaths = {};

  void prune(Set<String> validGroupIds) {
    processExecutablePaths.removeWhere(
      (key, value) => !validGroupIds.contains(key),
    );
  }

  void clear() {
    processExecutablePaths.clear();
  }

  /// 修复数据库中不完整的应用路径（仅进程名而非完整路径）
  Future<void> fixIncompleteAppPaths({
    required List<MagicWallGroupBundle> Function() getGroups,
    required Future<void> Function() reloadData,
  }) async {
    if (!Platform.isWindows) {
      return;
    }

    try {
      final repo = ServiceManager().magicWall;
      bool anyUpdated = false;
      final groups = getGroups();

      for (final bundle in groups) {
        if (bundle.group.processName.trim().isEmpty) {
          continue;
        }

        // 检查组内规则是否需要修复
        bool needsFix = false;
        for (final rule in bundle.rules) {
          final path = rule.appPath;
          if (path == null ||
              path.isEmpty ||
              (!path.contains('\\') && !path.contains('/'))) {
            needsFix = true;
            break;
          }
        }

        if (!needsFix) {
          continue;
        }

        // 尝试解析完整路径
        final executablePath = await getProcessExecutablePath(
          bundle.group.processName,
        );
        if (executablePath == null || executablePath.isEmpty) {
          continue;
        }

        // 更新所有不完整的规则
        for (final rule in bundle.rules) {
          final path = rule.appPath;
          if (path == null ||
              path.isEmpty ||
              (!path.contains('\\') && !path.contains('/'))) {
            final updated =
                MagicWallRuleModel()
                  ..id = rule.id
                  ..ruleId = rule.ruleId
                  ..groupId = rule.groupId
                  ..name = rule.name
                  ..enabled = rule.enabled
                  ..action = rule.action
                  ..protocol = rule.protocol
                  ..direction = rule.direction
                  ..appPath = executablePath
                  ..remoteIp = rule.remoteIp
                  ..localIp = rule.localIp
                  ..remotePort = rule.remotePort
                  ..localPort = rule.localPort
                  ..description = rule.description
                  ..createdAt = rule.createdAt
                  ..updatedAt = DateTime.now().millisecondsSinceEpoch;
            await repo.updateRule(updated);
            anyUpdated = true;
          }
        }
      }

      if (anyUpdated) {
        await reloadData();
      }
    } catch (e) {
      debugPrint('修复应用路径失败: $e');
    }
  }

  /// 更新单个规则的应用路径为完整路径（如果需要）
  Future<MagicWallRuleModel> ensureRuleHasCompletePath(
    MagicWallRuleModel rule,
    String? groupAppPath, {
    required List<MagicWallGroupBundle> Function() getGroups,
  }) async {
    // 如果已经有完整路径，不需要更新
    final currentPath = rule.appPath;
    if (currentPath != null &&
        currentPath.isNotEmpty &&
        (currentPath.contains('\\') || currentPath.contains('/'))) {
      return rule;
    }

    // 如果没有提供 groupAppPath，尝试从组中解析
    String? resolvedPath = groupAppPath;
    if (resolvedPath == null || resolvedPath.isEmpty) {
      for (final bundle in getGroups()) {
        if (bundle.group.groupId == rule.groupId) {
          resolvedPath = await resolveGroupAppPath(bundle.group, getGroups);
          break;
        }
      }
    }

    // 如果仍然没有路径，返回原规则
    if (resolvedPath == null || resolvedPath.isEmpty) {
      return rule;
    }

    // 更新规则的路径
    final updated =
        MagicWallRuleModel()
          ..id = rule.id
          ..ruleId = rule.ruleId
          ..groupId = rule.groupId
          ..name = rule.name
          ..enabled = rule.enabled
          ..action = rule.action
          ..protocol = rule.protocol
          ..direction = rule.direction
          ..appPath = resolvedPath
          ..remoteIp = rule.remoteIp
          ..localIp = rule.localIp
          ..remotePort = rule.remotePort
          ..localPort = rule.localPort
          ..description = rule.description
          ..createdAt = rule.createdAt
          ..updatedAt = DateTime.now().millisecondsSinceEpoch;

    await ServiceManager().magicWall.updateRule(updated);
    return updated;
  }

  Future<String?> resolveGroupAppPath(
    MagicWallGroupModel group,
    List<MagicWallGroupBundle> Function() getGroups,
  ) async {
    if (group.processName.trim().isEmpty) {
      return null;
    }

    final cached = processExecutablePaths[group.groupId];
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    for (final bundle in getGroups()) {
      if (bundle.group.groupId == group.groupId) {
        for (final rule in bundle.rules) {
          final candidate = rule.appPath;
          if (candidate != null && candidate.isNotEmpty) {
            processExecutablePaths[group.groupId] = candidate;
            return candidate;
          }
        }
        break;
      }
    }

    final path = await getProcessExecutablePath(group.processName);
    if (path != null && path.isNotEmpty) {
      processExecutablePaths[group.groupId] = path;
      return path;
    }
    return null;
  }

  Future<String?> getProcessExecutablePath(String processName) async {
    final trimmed = processName.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    if (trimmed.contains('\\') || trimmed.contains('/')) {
      final file = File(trimmed);
      if (await file.exists()) {
        return file.path;
      }
    }

    final sanitized = trimmed.replaceAll(
      RegExp(r'\.exe$', caseSensitive: false),
      '',
    );
    if (sanitized.isEmpty) {
      return null;
    }

    final escaped = sanitized.replaceAll("'", "''");
    final command =
        "Get-Process -Name '$escaped' -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Path";

    try {
      final result = await Process.run('powershell', [
        '-NoProfile',
        '-Command',
        command,
      ]);
      if (result.exitCode != 0) {
        return null;
      }
      final output = (result.stdout as String?)?.trim() ?? '';
      if (output.isEmpty) {
        return null;
      }
      return output;
    } catch (e) {
      debugPrint('解析进程路径失败: $e');
      return null;
    }
  }
}
