import 'dart:convert';
import 'package:flutter/material.dart';
import '../data/models/server_model.dart';
import '../data/storage/typed_storage.dart';
import '../state/typed_persistent_signal.dart';

/// 新的类型化存储系统使用示例
/// 
/// 这个文件展示了如何使用新的类型化存储系统来直接存储和管理复杂类型，
/// 无需手动序列化和反序列化。
class TypedStorageExample {
  
  /// 示例1: 基本类型的持久化存储
  static void basicTypesExample() {
    // 字符串类型
    final userName = typedPersistentString(key: 'user_name', initialValue: 'Guest');
    userName.value = 'John Doe';
    print('用户名: ${userName.value}'); // 自动保存到存储
    
    // 整数类型
    final userAge = typedPersistentInt(key: 'user_age', initialValue: 18);
    userAge.value = 25;
    print('用户年龄: ${userAge.value}');
    
    // 布尔类型
    final isDarkMode = typedPersistentBool(key: 'dark_mode', initialValue: false);
    isDarkMode.value = true;
    print('暗黑模式: ${isDarkMode.value}');
    
    // 浮点数类型
    final fontSize = typedPersistentDouble(key: 'font_size', initialValue: 14.0);
    fontSize.value = 16.5;
    print('字体大小: ${fontSize.value}');
  }
  
  /// 示例2: 复杂对象的持久化存储
  static void complexObjectExample() {
    // 直接存储 ServerModel 对象
    final currentServer = TypedPersistentSignal<ServerModel?>(
      'current_server',
      null,
    );
    
    // 创建一个服务器对象
    final server = ServerModel(
      id: 1,
      name: 'My Server',
      url: 'https://example.com',
      enable: true,
      sortOrder: 0,
      protocol: ProtocolType.http,
      description: 'Example server',
      isDefault: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // 直接赋值，自动序列化并保存
    currentServer.value = server;
    print('当前服务器: ${currentServer.value?.name}');
    
    // 修改服务器属性
    currentServer.value = server.copyWith(name: 'Updated Server');
    print('更新后的服务器: ${currentServer.value?.name}');
  }
  
  /// 示例3: 列表类型的持久化存储
  static void listExample() {
    // 字符串列表
    final favoriteColors = typedPersistentList<String>(key: 'favorite_colors', initialValue: []);
    favoriteColors.value = ['red', 'blue', 'green'];
    favoriteColors.add('yellow'); // 添加新元素
    print('喜欢的颜色: ${favoriteColors.value}');
    
    // 服务器列表
    final serverList = TypedPersistentListSignal<ServerModel>(
      boxName: 'servers',
      key: 'server_list',
      initialValue: [],
    );
    
    final servers = [
      ServerModel(
        id: 1,
        name: 'Server 1',
        url: 'https://server1.com',
        enable: true,
        sortOrder: 0,
        protocol: ProtocolType.http,
        description: 'First server',
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ServerModel(
        id: 2,
        name: 'Server 2',
        url: 'https://server2.com',
        enable: true,
        sortOrder: 1,
        protocol: ProtocolType.https,
        description: 'Second server',
        isDefault: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    
    // 直接赋值整个列表
    serverList.value = servers;
    print('服务器数量: ${serverList.value.length}');
    
    // 添加新服务器
    serverList.add(ServerModel(
      id: 3,
      name: 'Server 3',
      url: 'https://server3.com',
      enable: false,
      sortOrder: 2,
      protocol: ProtocolType.http,
      description: 'Third server',
      isDefault: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    print('添加后的服务器数量: ${serverList.value.length}');
  }
  
  /// 示例4: Map类型的持久化存储
  static void mapExample() {
    // 字符串到字符串的映射
    final userSettings = typedPersistentMap<String, String>(key: 'user_settings', initialValue: {});
    userSettings.value = {
      'theme': 'dark',
      'language': 'zh-CN',
      'timezone': 'Asia/Shanghai',
    };
    print('用户设置: ${userSettings.value}');
    
    // 服务器标签映射 (服务器ID -> 标签列表)
    final serverTags = TypedPersistentMapSignal<String, List<String>>(
      boxName: 'tags',
      key: 'server_tags',
      initialValue: {},
    );
    
    serverTags.value = {
      '1': ['production', 'primary'],
      '2': ['development', 'backup'],
      '3': ['testing'],
    };
    
    // 添加新的标签映射
    serverTags.put('4', ['staging', 'temporary']);
    print('服务器标签: ${serverTags.value}');
  }
  
  /// 示例5: 在Widget中使用
  static Widget buildExampleWidget() {
    return StatefulWidget(
      child: Builder(
        builder: (context) {
          // 创建持久化信号
          final counter = typedPersistentInt(key: 'counter', initialValue: 0);
          final message = typedPersistentString(key: 'message', initialValue: 'Hello');
          
          return Column(
            children: [
              // 显示计数器
              ListenableBuilder(
                listenable: counter,
                builder: (context, child) {
                  return Text('计数器: ${counter.value}');
                },
              ),
              
              // 增加计数器按钮
              ElevatedButton(
                onPressed: () {
                  counter.value++; // 自动保存
                },
                child: const Text('增加'),
              ),
              
              // 显示消息
              ListenableBuilder(
                listenable: message,
                builder: (context, child) {
                  return Text('消息: ${message.value}');
                },
              ),
              
              // 修改消息按钮
              ElevatedButton(
                onPressed: () {
                  message.value = 'Updated at ${DateTime.now()}';
                },
                child: const Text('更新消息'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  /// 示例6: 自定义类型的存储
  static void customTypeExample() {
    // 假设我们有一个自定义的用户偏好类
    final userPreferences = TypedPersistentSignal<Map<String, dynamic>>(
      'user_preferences',
      {},
    );
    
    // 存储复杂的用户偏好
    userPreferences.value = {
      'theme': {
        'mode': 'dark',
        'primaryColor': Colors.blue.value,
        'accentColor': Colors.orange.value,
      },
      'layout': {
        'sidebarWidth': 250.0,
        'showToolbar': true,
        'compactMode': false,
      },
      'notifications': {
        'enabled': true,
        'sound': true,
        'vibration': false,
        'categories': ['updates', 'messages', 'alerts'],
      },
    };
    
    print('用户偏好已保存');
    
    // 读取特定的偏好设置
    final themeMode = userPreferences.value['theme']?['mode'] ?? 'light';
    print('主题模式: $themeMode');
  }
  
  /// 运行所有示例
  static void runAllExamples() {
    print('=== 基本类型示例 ===');
    basicTypesExample();
    
    print('\n=== 复杂对象示例 ===');
    complexObjectExample();
    
    print('\n=== 列表类型示例 ===');
    listExample();
    
    print('\n=== Map类型示例 ===');
    mapExample();
    
    print('\n=== 自定义类型示例 ===');
    customTypeExample();
    
    print('\n所有示例运行完成！');
  }
}

/// 使用说明:
/// 
/// 1. 基本类型 (String, int, bool, double):
///    使用 typedPersistentString, typedPersistentInt, typedPersistentBool, typedPersistentDouble
/// 
/// 2. 列表类型:
///    使用 typedPersistentList<T> 或 TypedPersistentListSignal<T>
/// 
/// 3. Map类型:
///    使用 typedPersistentMap<K, V> 或 TypedPersistentMapSignal<K, V>
/// 
/// 4. 复杂对象:
///    使用 TypedPersistentSignal<T>，确保T实现了Serializable接口
/// 
/// 5. 在Widget中使用:
///    使用 ListenableBuilder 来监听变化并自动重建UI
/// 
/// 优势:
/// - 类型安全：编译时检查类型
/// - 自动序列化：无需手动转换JSON
/// - 响应式：自动通知UI更新
/// - 持久化：应用重启后数据保持
/// - 简单易用：类似普通变量的使用方式