# 通用序列化使用指南

## 概述

现在的持久化扩展支持通用的对象序列化，您可以轻松地为任何模型添加序列化支持，而无需修改核心的持久化逻辑。

## 如何为新模型添加序列化支持

### 1. 实现 Serializable 接口

让您的模型类实现 `Serializable` 接口：

```dart
import 'package:astral/data/database/serializable.dart';

class YourModel implements Serializable {
  final int id;
  final String name;
  
  YourModel({required this.id, required this.name});
  
  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
  
  factory YourModel.fromMap(Map<String, dynamic> map) {
    return YourModel(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
    );
  }
}
```

### 2. 创建工厂类

为您的模型创建一个工厂类：

```dart
class YourModelFactory implements SerializableFactory<YourModel> {
  @override
  YourModel fromMap(Map<String, dynamic> map) {
    return YourModel.fromMap(map);
  }
  
  @override
  String get typeName => 'YourModel';
}
```

### 3. 注册工厂

在 `lib/data/database/serialization_init.dart` 中注册您的工厂：

```dart
void initializeSerialization() {
  final registry = SerializationRegistry();
  
  // 现有的注册
  registry.register<ServerDb>(ServerDbFactory());
  
  // 添加您的模型注册
  registry.register<YourModel>(YourModelFactory());
}
```

### 4. 使用持久化

现在您可以直接使用持久化扩展：

```dart
// 创建信号
final yourModelList = signal<List<YourModel>>([]);

// 添加持久化
yourModelList.persistWith(
  key: 'your_model_list',
  version: 'v1',
);

// 正常使用，数据会自动持久化和恢复
yourModelList.value = [
  YourModel(id: 1, name: '示例1'),
  YourModel(id: 2, name: '示例2'),
];
```

## 优势

1. **通用性**: 一次实现，所有模型都可以使用
2. **类型安全**: 编译时检查类型正确性
3. **易于扩展**: 添加新模型只需要实现接口和注册工厂
4. **错误处理**: 内置错误处理和调试信息
5. **向后兼容**: 不影响现有的持久化功能

## 注意事项

- 确保在应用启动时调用 `initializeSerialization()` 
- 工厂的 `typeName` 必须与类名一致
- `toMap()` 和 `fromMap()` 方法必须能够正确序列化/反序列化所有字段