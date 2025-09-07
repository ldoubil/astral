# Hive 适配器管理

本目录包含所有自定义Hive类型适配器的实现和管理。

## 文件结构

- `adapter_manager.dart` - 适配器管理器，统一注册所有适配器
- `color_adapter.dart` - Color类型适配器 (TypeId: 33)
- `README.md` - 本说明文档

## 如何添加新的适配器

### 1. 创建适配器文件

在本目录下创建新的适配器文件，例如 `custom_type_adapter.dart`：

```dart
import 'package:hive/hive.dart';
import 'adapter_type_ids.dart';

/// 自定义类型的Hive适配器
/// TypeId: AdapterTypeIds.customType
class CustomTypeAdapter extends TypeAdapter<CustomType> {
  @override
  final int typeId = AdapterTypeIds.customType; // 使用AdapterTypeIds常量

  @override
  CustomType read(BinaryReader reader) {
    // 实现反序列化逻辑
    // 从reader中读取数据并重建对象
  }

  @override
  void write(BinaryWriter writer, CustomType obj) {
    // 实现序列化逻辑
    // 将对象数据写入writer
  }
}
```

### 2. 在AdapterManager中注册

编辑 `adapter_manager.dart`，在 `registerAllAdapters()` 方法中添加新适配器的注册：

```dart
static void registerAllAdapters() {
  // 现有适配器...
  
  // 注册新的适配器
  if (!Hive.isAdapterRegistered(AdapterTypeIds.customType)) {
    Hive.registerAdapter(CustomTypeAdapter());
  }
}
```

### 3. 在AdapterTypeIds中添加常量

在 `adapter_type_ids.dart` 中添加新的typeId常量：

```dart
class AdapterTypeIds {
  // 现有常量...
  
  /// 自定义类型适配器的TypeId
  static const int customType = 35;
}
```

### 4. 导入适配器

在 `adapter_manager.dart` 顶部添加导入语句：

```dart
import 'custom_type_adapter.dart';
```

## TypeId 分配规则

为避免冲突，请按以下规则分配TypeId，并在 `AdapterTypeIds` 类中定义常量：

- 33: Color (AdapterTypeIds.color)
- 34: ThemeMode (AdapterTypeIds.themeMode)
- 35-50: 预留给核心UI类型
- 51-100: 预留给业务模型类型
- 101+: 其他自定义类型

## 注意事项

1. **TypeId唯一性**: 每个适配器必须有唯一的typeId，使用AdapterTypeIds常量
2. **常量使用**: 所有typeId必须在AdapterTypeIds类中定义，避免硬编码
3. **向后兼容**: 一旦发布，不要更改已有适配器的typeId常量值
4. **序列化稳定性**: 确保read/write方法的实现稳定，避免破坏已存储的数据
5. **错误处理**: 在read方法中添加适当的错误处理
6. **测试**: 为每个适配器编写单元测试

## 已注册的适配器列表

| TypeId常量 | 值 | 类型 | 文件 | 说明 |
|-----------|---|------|------|------|
| AdapterTypeIds.color | 33 | Color | color_adapter.dart | Flutter Color类型适配器 |
| AdapterTypeIds.themeMode | 34 | ThemeMode | theme_mode_adapter.dart | Flutter ThemeMode枚举适配器 |

更新此列表当添加新适配器时。