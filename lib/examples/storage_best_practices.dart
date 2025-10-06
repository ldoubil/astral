import 'package:flutter/material.dart';
import '../data/storage/typed_storage.dart';
import '../state/typed_persistent_signal.dart';
import '../data/models/server_model.dart';

/// 存储系统最佳实践示例
/// 
/// 展示如何正确、高效地使用新的类型化存储系统
class StorageBestPractices {
  
  /// 最佳实践1: 合理的键命名约定
  static void keyNamingConventions() {
    print('=== 键命名约定 ===');
    
    // ✅ 好的命名方式 - 使用层次结构
    final userProfile = typedPersistentString(key: 'user_profile_name', initialValue: '');
    final userSettings = typedPersistentBool(key: 'user_settings_dark_mode', initialValue: false);
    final appConfig = typedPersistentInt(key: 'app_config_version', initialValue: 1);
    
    // ✅ 使用常量管理键名
    class StorageKeys {
      static const String userProfileName = 'user_profile_name';
      static const String userSettingsDarkMode = 'user_settings_dark_mode';
      static const String appConfigVersion = 'app_config_version';
    }
    
    final userName = typedPersistentString(key: StorageKeys.userProfileName, initialValue: '');
    
    // ❌ 避免的命名方式
    // final data = typedPersistentString(key: 'data', initialValue: ''); // 太模糊
    // final x = typedPersistentInt(key: 'x', initialValue: 0); // 无意义
    // final user-name = typedPersistentString(key: 'user-name', initialValue: ''); // 使用连字符
    
    print('键命名约定示例完成');
  }
  
  /// 最佳实践2: 性能优化
  static void performanceOptimization() {
    print('=== 性能优化 ===');
    
    // ✅ 复用信号实例，避免重复创建
    class AppState {
      static final _userNameSignal = typedPersistentString(
        key: 'user_name', 
        initialValue: 'Guest'
      );
      
      static TypedPersistentSignal<String> get userName => _userNameSignal;
    }
    
    // ✅ 使用适当的盒子名称进行数据分组
    final userSettings = TypedPersistentMapSignal<String, dynamic>(
      boxName: 'user_settings',
      key: 'preferences',
      initialValue: {},
    );
    
    final serverConfigs = TypedPersistentListSignal<ServerModel>(
      boxName: 'servers',
      key: 'config_list',
      initialValue: [],
    );
    
    // ✅ 批量操作而不是单个操作
    final servers = [
      ServerModel(
        id: 1, name: 'Server 1', url: 'https://server1.com',
        enable: true, sortOrder: 0, protocol: ProtocolType.https,
        description: '', isDefault: false,
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
      ServerModel(
        id: 2, name: 'Server 2', url: 'https://server2.com',
        enable: true, sortOrder: 1, protocol: ProtocolType.https,
        description: '', isDefault: false,
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
    ];
    
    // 一次性设置整个列表，而不是逐个添加
    serverConfigs.value = servers;
    
    print('性能优化示例完成');
  }
  
  /// 最佳实践3: 错误处理和数据验证
  static Future<void> errorHandlingAndValidation() async {
    print('=== 错误处理和数据验证 ===');
    
    final storage = TypedStorage();
    await storage.ensureInitialized();
    
    // ✅ 使用try-catch处理可能的错误
    try {
      final servers = await storage.getList('servers', 'server_list', ServerModel.fromJson);
      
      // ✅ 验证数据完整性
      final validServers = servers.where((server) {
        return server.url.isNotEmpty && 
               server.name.isNotEmpty &&
               server.url.startsWith('http');
      }).toList();
      
      if (validServers.length != servers.length) {
        print('发现 ${servers.length - validServers.length} 个无效服务器配置');
        // 保存清理后的数据
        await storage.saveList('servers', 'server_list', validServers);
      }
      
    } catch (e) {
      print('加载服务器配置失败: $e');
      // 使用默认配置
      final defaultServers = <ServerModel>[];
      await storage.saveList('servers', 'server_list', defaultServers);
    }
    
    // ✅ 使用默认值处理空数据
    final userName = await storage.getValue('user', 'name', 'Anonymous');
    final userAge = await storage.getValue('user', 'age', 18);
    
    print('错误处理和数据验证示例完成');
  }
  
  /// 最佳实践4: 内存管理
  static void memoryManagement() {
    print('=== 内存管理 ===');
    
    // ✅ 使用单例模式管理全局状态
    class GlobalSettings {
      static final _instance = GlobalSettings._internal();
      factory GlobalSettings() => _instance;
      GlobalSettings._internal();
      
      final darkMode = typedPersistentBool(key: 'global_dark_mode', initialValue: false);
      final language = typedPersistentString(key: 'global_language', initialValue: 'zh-CN');
      final fontSize = typedPersistentDouble(key: 'global_font_size', initialValue: 14.0);
    }
    
    // ✅ 在不需要时释放监听器
    class TemporaryWidget extends StatefulWidget {
      @override
      _TemporaryWidgetState createState() => _TemporaryWidgetState();
    }
    
    class _TemporaryWidgetState extends State<TemporaryWidget> {
      late final TypedPersistentSignal<String> _tempData;
      
      @override
      void initState() {
        super.initState();
        _tempData = typedPersistentString(key: 'temp_data', initialValue: '');
      }
      
      @override
      void dispose() {
        // 如果是临时数据，可以考虑清理
        // _tempData.dispose(); // 如果有dispose方法
        super.dispose();
      }
      
      @override
      Widget build(BuildContext context) {
        return Container();
      }
    }
    
    print('内存管理示例完成');
  }
  
  /// 最佳实践5: 数据同步和一致性
  static void dataSyncAndConsistency() {
    print('=== 数据同步和一致性 ===');
    
    // ✅ 使用相同的键确保数据一致性
    class UserManager {
      static const String _userNameKey = 'current_user_name';
      static const String _userIdKey = 'current_user_id';
      
      static final userName = typedPersistentString(key: _userNameKey, initialValue: '');
      static final userId = typedPersistentInt(key: _userIdKey, initialValue: 0);
      
      // ✅ 提供原子操作
      static void setUser(String name, int id) {
        userName.value = name;
        userId.value = id;
      }
      
      static void clearUser() {
        userName.value = '';
        userId.value = 0;
      }
    }
    
    // ✅ 监听数据变化保持UI同步
    class UserProfileWidget extends StatelessWidget {
      @override
      Widget build(BuildContext context) {
        return Column(
          children: [
            ListenableBuilder(
              listenable: UserManager.userName,
              builder: (context, child) {
                return Text('用户名: ${UserManager.userName.value}');
              },
            ),
            ListenableBuilder(
              listenable: UserManager.userId,
              builder: (context, child) {
                return Text('用户ID: ${UserManager.userId.value}');
              },
            ),
          ],
        );
      }
    }
    
    print('数据同步和一致性示例完成');
  }
  
  /// 最佳实践6: 测试友好的设计
  static void testFriendlyDesign() {
    print('=== 测试友好的设计 ===');
    
    // ✅ 使用依赖注入便于测试
    abstract class StorageService {
      Future<String> getUserName();
      Future<void> setUserName(String name);
    }
    
    class TypedStorageService implements StorageService {
      final _userNameSignal = typedPersistentString(key: 'user_name', initialValue: '');
      
      @override
      Future<String> getUserName() async {
        return _userNameSignal.value;
      }
      
      @override
      Future<void> setUserName(String name) async {
        _userNameSignal.value = name;
      }
    }
    
    // 测试时可以使用Mock实现
    class MockStorageService implements StorageService {
      String _userName = '';
      
      @override
      Future<String> getUserName() async => _userName;
      
      @override
      Future<void> setUserName(String name) async {
        _userName = name;
      }
    }
    
    // ✅ 提供清理方法便于测试
    class TestHelper {
      static Future<void> clearAllTestData() async {
        final storage = TypedStorage();
        await storage.ensureInitialized();
        
        // 清理测试数据
        await storage.saveValue('test', 'user_name', '');
        await storage.saveValue('test', 'user_id', 0);
        await storage.saveList('test', 'servers', <ServerModel>[]);
      }
    }
    
    print('测试友好的设计示例完成');
  }
  
  /// 最佳实践7: 安全性考虑
  static void securityConsiderations() {
    print('=== 安全性考虑 ===');
    
    // ✅ 敏感数据使用专门的盒子
    final sensitiveData = TypedPersistentSignal<String>(
      'sensitive_token', // 可以考虑加密存储
      '',
    );
    
    // ✅ 避免在日志中输出敏感信息
    class SecureLogger {
      static void logUserAction(String action, {Map<String, dynamic>? data}) {
        final sanitizedData = data?.map((key, value) {
          if (key.toLowerCase().contains('password') || 
              key.toLowerCase().contains('token') ||
              key.toLowerCase().contains('secret')) {
            return MapEntry(key, '***');
          }
          return MapEntry(key, value);
        });
        
        print('用户操作: $action, 数据: $sanitizedData');
      }
    }
    
    // ✅ 数据验证防止注入
    class DataValidator {
      static bool isValidServerUrl(String url) {
        try {
          final uri = Uri.parse(url);
          return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
        } catch (e) {
          return false;
        }
      }
      
      static String sanitizeUserInput(String input) {
        return input.trim().replaceAll(RegExp(r'[<>\"\'&]'), '');
      }
    }
    
    print('安全性考虑示例完成');
  }
  
  /// 运行所有最佳实践示例
  static Future<void> runAllBestPractices() async {
    print('开始展示存储系统最佳实践...\n');
    
    keyNamingConventions();
    print('');
    
    performanceOptimization();
    print('');
    
    await errorHandlingAndValidation();
    print('');
    
    memoryManagement();
    print('');
    
    dataSyncAndConsistency();
    print('');
    
    testFriendlyDesign();
    print('');
    
    securityConsiderations();
    print('');
    
    print('所有最佳实践示例完成！');
  }
}

/// 常用工具类
class StorageUtils {
  
  /// 数据导出
  static Future<Map<String, dynamic>> exportData() async {
    final storage = TypedStorage();
    await storage.ensureInitialized();
    
    // 这里可以实现数据导出逻辑
    return {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'data': {
        // 导出的数据
      }
    };
  }
  
  /// 数据导入
  static Future<void> importData(Map<String, dynamic> data) async {
    final storage = TypedStorage();
    await storage.ensureInitialized();
    
    // 验证数据格式
    if (data['version'] != '1.0') {
      throw Exception('不支持的数据版本');
    }
    
    // 导入数据
    final importData = data['data'] as Map<String, dynamic>;
    // 实现导入逻辑
  }
  
  /// 数据统计
  static Future<Map<String, int>> getDataStatistics() async {
    final storage = TypedStorage();
    await storage.ensureInitialized();
    
    // 统计各类数据的数量
    final servers = await storage.getList('servers', 'server_list', ServerModel.fromJson, []);
    
    return {
      'servers': servers.length,
      'settings': 1, // 假设有一个设置对象
    };
  }
}