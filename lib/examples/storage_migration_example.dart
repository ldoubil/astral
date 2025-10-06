import 'package:flutter/material.dart';
import '../data/storage/typed_storage.dart';
import '../state/typed_persistent_signal.dart';
import '../data/models/server_model.dart';

/// 存储系统迁移示例
/// 
/// 展示如何从旧的存储系统迁移到新的类型化存储系统
class StorageMigrationExample {
  
  /// 示例1: 从SharedPreferences迁移到TypedStorage
  static Future<void> migrateFromSharedPreferences() async {
    print('=== 从SharedPreferences迁移 ===');
    
    // 旧的方式 (假设的SharedPreferences代码)
    // final prefs = await SharedPreferences.getInstance();
    // final userName = prefs.getString('user_name') ?? 'Guest';
    // final userAge = prefs.getInt('user_age') ?? 18;
    // final isDarkMode = prefs.getBool('dark_mode') ?? false;
    
    // 新的方式 - 直接使用类型化存储
    final storage = TypedStorage();
    await storage.ensureInitialized();
    
    // 迁移数据 (如果需要)
    final userName = await storage.getValue('user', 'name', 'Guest');
    final userAge = await storage.getValue('user', 'age', 18);
    final isDarkMode = await storage.getValue('settings', 'dark_mode', false);
    
    print('用户名: $userName');
    print('用户年龄: $userAge');
    print('暗黑模式: $isDarkMode');
    
    // 使用持久化信号进行响应式管理
    final userNameSignal = typedPersistentString(key: 'user_name', initialValue: userName);
    final userAgeSignal = typedPersistentInt(key: 'user_age', initialValue: userAge);
    final darkModeSignal = typedPersistentBool(key: 'dark_mode', initialValue: isDarkMode);
    
    print('迁移完成！现在使用响应式存储。');
  }
  
  /// 示例2: 从JSON文件迁移复杂对象
  static Future<void> migrateComplexObjects() async {
    print('=== 迁移复杂对象 ===');
    
    final storage = TypedStorage();
    await storage.ensureInitialized();
    
    // 假设我们有一些旧的JSON数据需要迁移
    final oldServerData = {
      'id': 1,
      'name': 'Legacy Server',
      'url': 'https://legacy.example.com',
      'enabled': true,
      'type': 'http',
    };
    
    // 转换为新的ServerModel格式
    final server = ServerModel(
      id: oldServerData['id'] as int,
      name: oldServerData['name'] as String,
      url: oldServerData['url'] as String,
      enable: oldServerData['enabled'] as bool,
      sortOrder: 0,
      protocol: ProtocolType.http,
      description: 'Migrated from legacy system',
      isDefault: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // 使用新的存储系统保存
    await storage.saveObject('servers', 'legacy_server', server);
    
    // 验证迁移结果
    final loadedServer = await storage.getObject('servers', 'legacy_server', ServerModel.fromJson);
    print('迁移的服务器: ${loadedServer?.name}');
    
    // 创建响应式信号
    final currentServer = TypedPersistentSignal<ServerModel?>(
      'current_server',
      server,
    );
    
    print('复杂对象迁移完成！');
  }
  
  /// 示例3: 批量迁移数据
  static Future<void> batchMigration() async {
    print('=== 批量数据迁移 ===');
    
    final storage = TypedStorage();
    await storage.ensureInitialized();
    
    // 模拟旧的服务器列表数据
    final oldServers = [
      {'id': 1, 'name': 'Server 1', 'url': 'https://server1.com'},
      {'id': 2, 'name': 'Server 2', 'url': 'https://server2.com'},
      {'id': 3, 'name': 'Server 3', 'url': 'https://server3.com'},
    ];
    
    // 批量转换并保存
    final servers = <ServerModel>[];
    for (final oldServer in oldServers) {
      final server = ServerModel(
        id: oldServer['id'] as int,
        name: oldServer['name'] as String,
        url: oldServer['url'] as String,
        enable: true,
        sortOrder: servers.length,
        protocol: ProtocolType.https,
        description: 'Migrated server',
        isDefault: servers.isEmpty,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      servers.add(server);
    }
    
    // 保存服务器列表
    await storage.saveList('servers', 'server_list', servers);
    
    // 验证迁移结果
    final loadedServers = await storage.getList('servers', 'server_list', ServerModel.fromJson);
    print('迁移的服务器数量: ${loadedServers.length}');
    
    // 创建响应式列表信号
    final serverListSignal = TypedPersistentListSignal<ServerModel>(
      boxName: 'servers',
      key: 'server_list',
      initialValue: servers,
    );
    
    print('批量迁移完成！');
  }
  
  /// 示例4: 迁移用户设置
  static Future<void> migrateUserSettings() async {
    print('=== 迁移用户设置 ===');
    
    final storage = TypedStorage();
    await storage.ensureInitialized();
    
    // 模拟旧的设置数据
    final oldSettings = {
      'theme': 'dark',
      'language': 'zh-CN',
      'fontSize': 14.0,
      'autoSave': true,
      'notifications': {
        'enabled': true,
        'sound': false,
        'categories': ['updates', 'messages']
      }
    };
    
    // 迁移基本设置
    final themeSignal = typedPersistentString(
      key: 'theme', 
      initialValue: oldSettings['theme'] as String
    );
    final languageSignal = typedPersistentString(
      key: 'language', 
      initialValue: oldSettings['language'] as String
    );
    final fontSizeSignal = typedPersistentDouble(
      key: 'font_size', 
      initialValue: oldSettings['fontSize'] as double
    );
    final autoSaveSignal = typedPersistentBool(
      key: 'auto_save', 
      initialValue: oldSettings['autoSave'] as bool
    );
    
    // 迁移复杂设置
    final notificationSettings = TypedPersistentSignal<Map<String, dynamic>>(
      'notification_settings',
      oldSettings['notifications'] as Map<String, dynamic>,
    );
    
    print('主题: ${themeSignal.value}');
    print('语言: ${languageSignal.value}');
    print('字体大小: ${fontSizeSignal.value}');
    print('自动保存: ${autoSaveSignal.value}');
    print('通知设置: ${notificationSettings.value}');
    
    print('用户设置迁移完成！');
  }
  
  /// 示例5: 数据验证和清理
  static Future<void> validateAndCleanup() async {
    print('=== 数据验证和清理 ===');
    
    final storage = TypedStorage();
    await storage.ensureInitialized();
    
    // 验证迁移的数据
    try {
      final servers = await storage.getList('servers', 'server_list', ServerModel.fromJson);
      print('验证服务器列表: ${servers.length} 个服务器');
      
      for (final server in servers) {
        if (server.url.isEmpty || !server.url.startsWith('http')) {
          print('警告: 服务器 ${server.name} 的URL格式不正确');
        }
      }
      
      // 清理无效数据
      final validServers = servers.where((server) => 
        server.url.isNotEmpty && server.url.startsWith('http')
      ).toList();
      
      if (validServers.length != servers.length) {
        await storage.saveList('servers', 'server_list', validServers);
        print('已清理 ${servers.length - validServers.length} 个无效服务器');
      }
      
    } catch (e) {
      print('数据验证失败: $e');
    }
    
    print('数据验证和清理完成！');
  }
  
  /// 运行所有迁移示例
  static Future<void> runAllMigrations() async {
    print('开始存储系统迁移...\n');
    
    await migrateFromSharedPreferences();
    print('');
    
    await migrateComplexObjects();
    print('');
    
    await batchMigration();
    print('');
    
    await migrateUserSettings();
    print('');
    
    await validateAndCleanup();
    print('');
    
    print('所有迁移完成！');
  }
}

/// 迁移工具类
class MigrationHelper {
  
  /// 检查是否需要迁移
  static Future<bool> needsMigration() async {
    final storage = TypedStorage();
    await storage.ensureInitialized();
    
    // 检查是否存在迁移标记
    final migrationVersion = await storage.getValue('system', 'migration_version', 0);
    const currentVersion = 1;
    
    return migrationVersion < currentVersion;
  }
  
  /// 标记迁移完成
  static Future<void> markMigrationComplete() async {
    final storage = TypedStorage();
    await storage.ensureInitialized();
    
    await storage.saveValue('system', 'migration_version', 1);
    await storage.saveValue('system', 'migration_date', DateTime.now().toIso8601String());
  }
  
  /// 创建备份
  static Future<void> createBackup() async {
    print('创建数据备份...');
    // 这里可以实现备份逻辑
    print('备份创建完成');
  }
}