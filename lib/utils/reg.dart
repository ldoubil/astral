import 'dart:io';
import 'package:flutter/foundation.dart';

/// 使用Windows计划任务设置开机自启动
/// [enable] true表示启用，false表示禁用
/// [runAsAdmin] 是否以管理员权限运行（默认false）
Future<void> handleStartupSetting(bool enable, {bool runAsAdmin = false}) async {
  if (!Platform.isWindows) {
    if (kDebugMode) {
      debugPrint('handleStartupSetting: 仅支持Windows平台');
    }
    return;
  }

  final executablePath = Platform.resolvedExecutable;
  final taskName = 'Astral';

  if (enable) {
    // 先删除可能存在的旧任务
    await _deleteTask(taskName);
    
    // 创建新的计划任务
    await _createTask(taskName, executablePath, runAsAdmin);
  } else {
    // 删除计划任务
    await _deleteTask(taskName);
  }
}

/// 创建计划任务
Future<void> _createTask(String taskName, String executablePath, bool runAsAdmin) async {
  try {
    // 使用 schtasks.exe 创建任务
    // /SC ONLOGON - 在用户登录时触发
    // /TN - 任务名称
    // /TR - 要运行的程序
    // /RL HIGHEST - 以最高权限运行（如果需要管理员权限）
    // /F - 强制创建（如果任务已存在则覆盖）
    // /NP - 不存储密码（使用当前用户凭据）
    
    // 构建命令参数
    // schtasks.exe 的 /TR 参数如果路径包含空格，需要用引号包裹
    // 但 Process.run 会将每个参数分开传递，所以直接传递路径即可
    // 如果路径包含空格，schtasks 会自动处理
    final args = <String>[
      '/Create',
      '/SC', 'ONLOGON',  // 用户登录时触发
      '/TN', taskName,
      '/TR', executablePath,  // 可执行文件路径
      '/F',  // 强制创建（如果任务已存在则覆盖）
      '/NP', // 不存储密码（使用当前用户凭据）
    ];
    
    if (runAsAdmin) {
      args.addAll(['/RL', 'HIGHEST']); // 以最高权限运行
    }
    
    final result = await Process.run('schtasks', args);
    
    if (result.exitCode != 0) {
      if (kDebugMode) {
        debugPrint('创建计划任务失败: ${result.stderr}');
      }
      throw Exception('创建计划任务失败: ${result.stderr}');
    }
    
    if (kDebugMode) {
      debugPrint('计划任务创建成功: $taskName');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('创建计划任务时出错: $e');
    }
    rethrow;
  }
}

/// 删除计划任务
Future<void> _deleteTask(String taskName) async {
  try {
    final args = [
      '/Delete',
      '/TN', taskName,
      '/F',  // 强制删除，不提示确认
    ];
    
    final result = await Process.run('schtasks', args);
    
    // 如果任务不存在，exitCode 可能不为0，但不一定是错误
    if (result.exitCode != 0) {
      final errorOutput = result.stderr.toString().toLowerCase();
      // 如果错误是"找不到任务"，这是正常的，不需要抛出异常
      if (!errorOutput.contains('找不到') && !errorOutput.contains('not found')) {
        if (kDebugMode) {
          debugPrint('删除计划任务时出错: ${result.stderr}');
        }
      } else {
        if (kDebugMode) {
          debugPrint('计划任务不存在，无需删除: $taskName');
        }
      }
    } else {
      if (kDebugMode) {
        debugPrint('计划任务删除成功: $taskName');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('删除计划任务时出错: $e');
    }
    // 删除失败不应该阻止后续操作，只记录错误
  }
}

/// 检查计划任务是否存在
Future<bool> isTaskExists(String taskName) async {
  if (!Platform.isWindows) {
    return false;
  }
  
  try {
    final args = [
      '/Query',
      '/TN', taskName,
    ];
    
    final result = await Process.run('schtasks', args);
    return result.exitCode == 0;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('检查计划任务时出错: $e');
    }
    return false;
  }
}

/// 获取计划任务中的可执行文件路径
/// 返回路径字符串，如果任务不存在或获取失败则返回null
Future<String?> getTaskExecutablePath(String taskName) async {
  if (!Platform.isWindows) {
    return null;
  }
  
  try {
    // 使用 /V /FO LIST 格式获取详细信息
    final args = [
      '/Query',
      '/TN', taskName,
      '/V',
      '/FO', 'LIST',
    ];
    
    final result = await Process.run('schtasks', args);
    
    if (result.exitCode != 0) {
      if (kDebugMode) {
        debugPrint('查询计划任务失败: ${result.stderr}');
      }
      return null;
    }
    
    // 解析输出，查找包含可执行文件路径的行
    // schtasks /V /FO LIST 输出格式示例：
    // 中文: "任务运行: C:\path\to\app.exe"
    // 英文: "Task To Run: C:\path\to\app.exe"
    final output = result.stdout.toString();
    final lines = output.split('\n');
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      // 查找包含可执行文件路径的行（支持中英文）
      if (trimmedLine.contains('任务运行:') || 
          trimmedLine.contains('Task To Run:') ||
          trimmedLine.toLowerCase().contains('task to run:')) {
        // 提取路径部分，使用冒号分割
        final colonIndex = trimmedLine.indexOf(':');
        if (colonIndex >= 0 && colonIndex < trimmedLine.length - 1) {
          var path = trimmedLine.substring(colonIndex + 1).trim();
          // 移除可能的引号
          path = path.replaceAll('"', '').replaceAll("'", '').trim();
          if (path.isNotEmpty) {
            return path;
          }
        }
      }
    }
    
    if (kDebugMode) {
      debugPrint('未找到计划任务中的可执行文件路径');
    }
    return null;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('获取计划任务路径时出错: $e');
    }
    return null;
  }
}

/// 验证并修复计划任务路径
/// 如果计划任务存在但路径不匹配当前程序，则更新计划任务
Future<void> verifyAndFixStartupTask() async {
  if (!Platform.isWindows) {
    return;
  }
  
  try {
    const taskName = 'Astral';
    final currentPath = Platform.resolvedExecutable;
    
    // 检查计划任务是否存在
    final exists = await isTaskExists(taskName);
    if (!exists) {
      if (kDebugMode) {
        debugPrint('计划任务不存在，无需验证');
      }
      return;
    }
    
    // 获取计划任务中的路径
    final taskPath = await getTaskExecutablePath(taskName);
    if (taskPath == null) {
      if (kDebugMode) {
        debugPrint('无法获取计划任务路径，跳过验证');
      }
      return;
    }
    
    // 规范化路径进行比较（转换为小写并统一路径分隔符）
    final normalizedCurrentPath = currentPath.toLowerCase().replaceAll('/', '\\');
    final normalizedTaskPath = taskPath.toLowerCase().replaceAll('/', '\\');
    
    // 比较路径是否一致
    if (normalizedCurrentPath != normalizedTaskPath) {
      if (kDebugMode) {
        debugPrint('计划任务路径不匹配:');
        debugPrint('  当前程序: $currentPath');
        debugPrint('  计划任务: $taskPath');
        debugPrint('正在更新计划任务...');
      }
      
      // 删除旧任务并创建新任务
      await _deleteTask(taskName);
      await _createTask(taskName, currentPath, false);
      
      if (kDebugMode) {
        debugPrint('计划任务已更新');
      }
    } else {
      if (kDebugMode) {
        debugPrint('计划任务路径验证通过');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('验证计划任务时出错: $e');
    }
    // 验证失败不应该阻止程序启动
  }
}

class UrlSchemeRegistrar {
  /// 注册URL scheme到Windows注册表
  static Future<bool> registerUrlScheme() async {
    if (!Platform.isWindows) return true;
    
    try {
      final executablePath = Platform.resolvedExecutable;
      
      // 使用用户级别的注册表，避免权限问题
      final commands = [
        // 注册主键
        ['add', 'HKEY_CURRENT_USER\\Software\\Classes\\astral', '/ve', '/d', 'URL:Astral Protocol', '/f'],
        ['add', 'HKEY_CURRENT_USER\\Software\\Classes\\astral', '/v', 'URL Protocol', '/d', '', '/f'],
        
        // 注册图标
        ['add', 'HKEY_CURRENT_USER\\Software\\Classes\\astral\\DefaultIcon', '/ve', '/d', '"$executablePath",1', '/f'],
        
        // 注册命令
        ['add', 'HKEY_CURRENT_USER\\Software\\Classes\\astral\\shell\\open\\command', '/ve', '/d', '"$executablePath" "%1"', '/f'],
      ];
      
      // 执行所有注册表命令
      for (final command in commands) {
        final result = await Process.run('reg', command);
        if (result.exitCode != 0) {
          if (kDebugMode) {
           debugPrint('Failed to execute reg command: ${command.join(' ')}');
           debugPrint('Error: ${result.stderr}');
          }
          return false;
        }
      }
      
      if (kDebugMode) {
       debugPrint('URL scheme registered successfully');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
       debugPrint('Error registering URL scheme: $e');
      }
      return false;
    }
  }
  
  /// 检查URL scheme是否已注册
  static Future<bool> isUrlSchemeRegistered() async {
    if (!Platform.isWindows) return true;
    
    try {
      final result = await Process.run('reg', [
        'query',
        'HKEY_CURRENT_USER\\Software\\Classes\\astral',
        '/ve'
      ]);
      
      return result.exitCode == 0 && 
             result.stdout.toString().contains('URL:Astral Protocol');
    } catch (e) {
      if (kDebugMode) {
       debugPrint('Error checking URL scheme registration: $e');
      }
      return false;
    }
  }
  
  /// 卸载URL scheme注册
  static Future<bool> unregisterUrlScheme() async {
    if (!Platform.isWindows) return true;
    
    try {
      final result = await Process.run('reg', [
        'delete',
        'HKEY_CLASSES_ROOT\\astral',
        '/f'
      ]);
      
      if (result.exitCode == 0) {
        if (kDebugMode) {
         debugPrint('URL scheme unregistered successfully');
        }
        return true;
      } else {
        if (kDebugMode) {
         debugPrint('Failed to unregister URL scheme: ${result.stderr}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
       debugPrint('Error unregistering URL scheme: $e');
      }
      return false;
    }
  }
  
  /// 更新URL scheme注册（当exe路径改变时）
  static Future<bool> updateUrlSchemeRegistration() async {
    if (!Platform.isWindows) return true;
    
    try {
      // 检查是否已注册
      final isRegistered = await isUrlSchemeRegistered();
      
      if (isRegistered) {
        // 如果已注册，重新注册以更新路径
        return await registerUrlScheme();
      } else {
        // 如果未注册，直接注册
        return await registerUrlScheme();
      }
    } catch (e) {
      if (kDebugMode) {
       debugPrint('Error updating URL scheme registration: $e');
      }
      return false;
    }
  }
}
