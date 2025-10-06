# 类型化存储系统 (Typed Storage System)

## 概述

新的类型化存储系统为 Astral 应用提供了类型安全、响应式的数据持久化解决方案。该系统基于 JSON 文件存储，支持复杂对象的自动序列化和反序列化，并提供响应式的数据绑定功能。

## 主要特性

- **类型安全**: 编译时类型检查，避免运行时类型错误
- **自动序列化**: 无需手动转换 JSON，支持复杂对象
- **响应式**: 自动通知 UI 更新，支持 Flutter 的响应式编程
- **持久化**: 应用重启后数据自动恢复
- **高性能**: 基于内存缓存，快速读写操作
- **易于测试**: 提供清晰的 API 和测试支持

## 核心组件

### 1. TypedStorage

基础存储管理器，提供底层的数据存储功能。

```dart
final storage = TypedStorage();
await storage.ensureInitialized();

// 保存基本类型
await storage.saveValue('user', 'name', 'John Doe');
await storage.saveValue('user', 'age', 25);

// 读取基本类型
final name = await storage.getValue('user', 'name', 'Guest');
final age = await storage.getValue('user', 'age', 18);

// 保存复杂对象
final server = ServerModel(/* ... */);
await storage.saveObject('servers', 'main', server);

// 读取复杂对象
final loadedServer = await storage.getObject('servers', 'main', ServerModel.fromJson);
```

### 2. TypedPersistentSignal

响应式信号，自动处理数据的持久化和 UI 更新。

```dart
// 基本类型信号
final userName = typedPersistentString(key: 'user_name', initialValue: 'Guest');
final userAge = typedPersistentInt(key: 'user_age', initialValue: 18);
final isDarkMode = typedPersistentBool(key: 'dark_mode', initialValue: false);

// 修改值会自动保存
userName.value = 'John Doe';
userAge.value = 25;
isDarkMode.value = true;

// 在 Widget 中使用
ListenableBuilder(
  listenable: userName,
  builder: (context, child) {
    return Text('用户名: ${userName.value}');
  },
)
```

### 3. TypedPersistentListSignal

响应式列表信号，支持列表操作的自动持久化。

```dart
final favoriteColors = typedPersistentList<String>(
  key: 'favorite_colors', 
  initialValue: []
);

// 列表操作会自动保存
favoriteColors.add('red');
favoriteColors.add('blue');
favoriteColors.remove('red');

// 复杂对象列表
final serverList = TypedPersistentListSignal<ServerModel>(
  boxName: 'servers',
  key: 'server_list',
  initialValue: [],
);

serverList.add(ServerModel(/* ... */));
```

### 4. TypedPersistentMapSignal

响应式映射信号，支持键值对操作的自动持久化。

```dart
final userSettings = typedPersistentMap<String, String>(
  key: 'user_settings', 
  initialValue: {}
);

// 映射操作会自动保存
userSettings.put('theme', 'dark');
userSettings.put('language', 'zh-CN');
userSettings.removeKey('old_setting');

// 复杂映射
final serverTags = TypedPersistentMapSignal<String, List<String>>(
  boxName: 'tags',
  key: 'server_tags',
  initialValue: {},
);

serverTags.put('server1', ['production', 'primary']);
```

## 快速开始

### 1. 初始化存储系统

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化存储系统
  final storage = TypedStorage();
  await storage.ensureInitialized();
  
  runApp(MyApp());
}
```

### 2. 创建响应式数据

```dart
class AppState {
  // 用户信息
  static final userName = typedPersistentString(key: 'user_name', initialValue: 'Guest');
  static final userAge = typedPersistentInt(key: 'user_age', initialValue: 18);
  
  // 应用设置
  static final isDarkMode = typedPersistentBool(key: 'dark_mode', initialValue: false);
  static final fontSize = typedPersistentDouble(key: 'font_size', initialValue: 14.0);
  
  // 服务器列表
  static final servers = TypedPersistentListSignal<ServerModel>(
    boxName: 'servers',
    key: 'server_list',
    initialValue: [],
  );
}
```

### 3. 在 Widget 中使用

```dart
class UserProfileWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 显示用户名
        ListenableBuilder(
          listenable: AppState.userName,
          builder: (context, child) {
            return Text('用户名: ${AppState.userName.value}');
          },
        ),
        
        // 修改用户名按钮
        ElevatedButton(
          onPressed: () {
            AppState.userName.value = 'New Name';
          },
          child: Text('修改用户名'),
        ),
        
        // 主题切换
        ListenableBuilder(
          listenable: AppState.isDarkMode,
          builder: (context, child) {
            return Switch(
              value: AppState.isDarkMode.value,
              onChanged: (value) {
                AppState.isDarkMode.value = value;
              },
            );
          },
        ),
      ],
    );
  }
}
```

## API 参考

### 基本类型信号

```dart
// 字符串
TypedPersistentSignal<String> typedPersistentString({
  required String key,
  required String initialValue,
  String boxName = 'default',
});

// 整数
TypedPersistentSignal<int> typedPersistentInt({
  required String key,
  required int initialValue,
  String boxName = 'default',
});

// 布尔值
TypedPersistentSignal<bool> typedPersistentBool({
  required String key,
  required bool initialValue,
  String boxName = 'default',
});

// 浮点数
TypedPersistentSignal<double> typedPersistentDouble({
  required String key,
  required double initialValue,
  String boxName = 'default',
});
```

### 集合类型信号

```dart
// 列表
TypedPersistentListSignal<T> typedPersistentList<T>({
  required String key,
  required List<T> initialValue,
  String boxName = 'default',
});

// 映射
TypedPersistentMapSignal<K, V> typedPersistentMap<K, V>({
  required String key,
  required Map<K, V> initialValue,
  String boxName = 'default',
});
```

### 复杂对象信号

```dart
// 自定义对象
final currentServer = TypedPersistentSignal<ServerModel?>(
  'current_server',
  null, // 初始值
);

// 使用时需要确保对象实现了 Serializable 接口
```

## 最佳实践

### 1. 键命名约定

```dart
// ✅ 推荐：使用层次结构的命名
class StorageKeys {
  static const String userProfileName = 'user_profile_name';
  static const String userSettingsDarkMode = 'user_settings_dark_mode';
  static const String appConfigVersion = 'app_config_version';
}

// ❌ 避免：模糊或无意义的命名
// 'data', 'x', 'temp'
```

### 2. 数据分组

```dart
// 使用不同的 boxName 对数据进行逻辑分组
final userSettings = TypedPersistentMapSignal<String, dynamic>(
  boxName: 'user_settings',  // 用户设置
  key: 'preferences',
  initialValue: {},
);

final serverConfigs = TypedPersistentListSignal<ServerModel>(
  boxName: 'servers',        // 服务器配置
  key: 'config_list',
  initialValue: [],
);
```

### 3. 错误处理

```dart
try {
  final servers = await storage.getList('servers', 'server_list', ServerModel.fromJson);
  
  // 验证数据完整性
  final validServers = servers.where((server) => 
    server.url.isNotEmpty && server.url.startsWith('http')
  ).toList();
  
  if (validServers.length != servers.length) {
    // 清理无效数据
    await storage.saveList('servers', 'server_list', validServers);
  }
  
} catch (e) {
  print('加载数据失败: $e');
  // 使用默认值
}
```

### 4. 性能优化

```dart
// ✅ 复用信号实例
class AppState {
  static final _userNameSignal = typedPersistentString(
    key: 'user_name', 
    initialValue: 'Guest'
  );
  
  static TypedPersistentSignal<String> get userName => _userNameSignal;
}

// ✅ 批量操作
serverList.value = newServers; // 一次性设置整个列表

// ❌ 避免频繁的单个操作
// for (final server in newServers) {
//   serverList.add(server); // 每次都会触发保存
// }
```

## 迁移指南

### 从 SharedPreferences 迁移

```dart
// 旧方式
final prefs = await SharedPreferences.getInstance();
final userName = prefs.getString('user_name') ?? 'Guest';
await prefs.setString('user_name', 'John');

// 新方式
final userName = typedPersistentString(key: 'user_name', initialValue: 'Guest');
userName.value = 'John'; // 自动保存
```

### 从手动 JSON 处理迁移

```dart
// 旧方式
final jsonString = prefs.getString('server_config') ?? '{}';
final json = jsonDecode(jsonString);
final server = ServerModel.fromJson(json);

// 保存
final updatedJson = jsonEncode(server.toJson());
await prefs.setString('server_config', updatedJson);

// 新方式
final currentServer = TypedPersistentSignal<ServerModel?>(
  'current_server',
  null,
);
currentServer.value = server; // 自动序列化和保存
```

## 测试

### 单元测试

```dart
void main() {
  group('TypedStorage Tests', () {
    late TypedStorage storage;
    
    setUp(() async {
      storage = TypedStorage();
      await storage.ensureInitialized();
    });
    
    test('should save and load string values', () async {
      await storage.saveValue('test', 'key', 'value');
      final result = await storage.getValue('test', 'key', '');
      expect(result, equals('value'));
    });
    
    test('should save and load complex objects', () async {
      final server = ServerModel(/* ... */);
      await storage.saveObject('test', 'server', server);
      final result = await storage.getObject('test', 'server', ServerModel.fromJson);
      expect(result?.name, equals(server.name));
    });
  });
}
```

### Widget 测试

```dart
void main() {
  testWidgets('should update UI when signal changes', (tester) async {
    final testSignal = typedPersistentString(key: 'test_key', initialValue: 'initial');
    
    await tester.pumpWidget(
      MaterialApp(
        home: ListenableBuilder(
          listenable: testSignal,
          builder: (context, child) {
            return Text(testSignal.value);
          },
        ),
      ),
    );
    
    expect(find.text('initial'), findsOneWidget);
    
    testSignal.value = 'updated';
    await tester.pump();
    
    expect(find.text('updated'), findsOneWidget);
  });
}
```

## 故障排除

### 常见问题

1. **数据没有持久化**
   - 确保调用了 `TypedStorage().ensureInitialized()`
   - 检查是否有写入权限

2. **类型转换错误**
   - 确保复杂对象实现了正确的 `fromJson` 方法
   - 检查数据类型是否匹配

3. **UI 没有更新**
   - 确保使用了 `ListenableBuilder`
   - 检查是否正确监听了信号

4. **性能问题**
   - 避免频繁创建新的信号实例
   - 使用批量操作而不是单个操作

### 调试技巧

```dart
// 启用调试日志
if (kDebugMode) {
  print('[Storage] 保存数据: $key = $value');
}

// 检查存储状态
final storage = TypedStorage();
print('存储已初始化: ${storage.isInitialized}');

// 验证数据完整性
final data = await storage.getValue('box', 'key', null);
assert(data != null, '数据不应为空');
```

## 示例代码

完整的示例代码可以在以下文件中找到：

- `lib/examples/typed_storage_example.dart` - 基本使用示例
- `lib/examples/storage_migration_example.dart` - 迁移示例
- `lib/examples/storage_best_practices.dart` - 最佳实践示例

## 更新日志

### v1.0.0
- 初始版本发布
- 支持基本类型的响应式存储
- 支持复杂对象的自动序列化
- 提供列表和映射的响应式操作
- 完整的测试覆盖

---

如有问题或建议，请提交 Issue 或 Pull Request。