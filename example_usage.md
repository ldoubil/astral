# Astral 项目使用示例

## 持久化 Signal 功能

### 概述

本项目新增了持久化 Signal 功能，允许您轻松地将应用状态持久化存储到本地，实现应用重启后数据的自动恢复。

### 核心特性

1. **自动加载和保存**：数据会在应用启动时自动加载，在值变化时自动保存
2. **类型安全**：支持 String、int、double、bool 及其 List 类型
3. **简单易用**：与普通 Signal 使用方式几乎相同
4. **灵活配置**：支持自动保存和手动保存两种模式

### 快速开始

#### 1. 初始化 Hive

在 `main.dart` 中确保 Hive 已初始化：

```dart
import 'package:astral/core/hive_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Hive
  await HiveInitializer.init();
  
  runApp(MyApp());
}
```

#### 2. 创建持久化 Signal

```dart
import 'package:astral/core/persistent_signal.dart';

class MyState {
  // 自动保存模式（推荐）
  late final PersistentSignal<String> userName;
  late final PersistentSignal<int> userScore;
  late final PersistentSignal<bool> isDarkMode;
  late final PersistentSignal<List<String>> favoriteItems;
  
  MyState() {
    // 初始化持久化信号
    userName = persistentSignal('user_name', '默认用户名');
    userScore = persistentSignal('user_score', 0);
    isDarkMode = persistentSignal('dark_mode', false);
    favoriteItems = persistentSignal('favorite_items', <String>[]);
  }
}
```

#### 3. 在 Widget 中使用

```dart
class MyWidget extends StatelessWidget {
  final MyState state = MyState();
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 显示用户名（自动响应变化）
        Watch(state.userName, () => Text('用户名: ${state.userName.value}')),
        
        // 修改用户名的按钮
        ElevatedButton(
          onPressed: () => state.userName.value = '新用户名',
          child: Text('修改用户名'),
        ),
        
        // 深色模式开关
        Switch(
          value: Watch(state.isDarkMode, () => state.isDarkMode.value),
          onChanged: (value) => state.isDarkMode.value = value,
        ),
      ],
    );
  }
}
```

### 高级用法

#### 手动保存模式

```dart
// 创建不自动保存的信号
final manualSignal = persistentSignal('manual_key', 'default', autoSave: false);

// 修改值（不会自动保存）
manualSignal.value = 'new value';

// 手动保存
await manualSignal.save();
```

#### 数据管理操作

```dart
// 重置为默认值
signal.reset();

// 重新从存储加载
signal.reload();

// 删除存储的数据
await signal.delete();

// 获取信号的元信息
print('存储键: ${signal.key}');
print('默认值: ${signal.defaultValue}');
print('自动保存: ${signal.autoSave}');
```

#### 批量操作

```dart
class AppState {
  final userName = persistentSignal('user_name', '');
  final userAge = persistentSignal('user_age', 18);
  final settings = persistentSignal('settings', <String>[]);
  
  // 保存所有数据
  Future<void> saveAll() async {
    await Future.wait([
      userName.save(),
      userAge.save(),
      settings.save(),
    ]);
  }
  
  // 重置所有数据
  void resetAll() {
    userName.reset();
    userAge.reset();
    settings.reset();
  }
  
  // 重新加载所有数据
  void reloadAll() {
    userName.reload();
    userAge.reload();
    settings.reload();
  }
}
```

### 支持的数据类型

- `String` - 字符串
- `int` - 整数
- `double` - 浮点数
- `bool` - 布尔值
- `List<String>` - 字符串列表
- `List<int>` - 整数列表
- `List<double>` - 浮点数列表
- `List<bool>` - 布尔值列表

### 在 BaseState 中的集成

项目的 `BaseState` 类已经集成了持久化功能：

```dart
import 'package:astral/state/app_state.dart';

// 获取应用状态
final appState = AppState();

// 使用持久化的应用名称
print('应用名称: ${appState.baseState.appName.value}');

// 修改应用名称（会自动保存）
appState.baseState.appName.value = '新的应用名称';

// 重置所有基础状态
appState.baseState.resetToDefaults();
```

### 最佳实践

1. **合理命名存储键**：使用有意义的键名，避免冲突
2. **适度使用持久化**：不是所有状态都需要持久化，临时状态使用普通 Signal
3. **错误处理**：在关键操作中添加 try-catch 处理
4. **性能考虑**：避免频繁修改大型列表数据

### 示例项目

查看 `lib/core/persistent_signal_example.dart` 文件获取完整的使用示例，包括：

- 用户信息管理
- 应用设置持久化
- 列表数据操作
- 错误处理演示

### 故障排除

1. **初始化错误**：确保在使用前调用了 `HiveInitializer.init()`
2. **类型错误**：检查是否使用了支持的数据类型
3. **保存失败**：检查存储权限和磁盘空间
4. **数据丢失**：确认是否正确设置了存储键名

---

更多详细信息请参考源码注释和示例文件。