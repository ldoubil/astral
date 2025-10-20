# 插件开发模板

这是Astral插件系统的标准开发模板，提供了完整的插件结构和示例代码。

## 快速开始

1. **复制模板**
   ```bash
   cp -r templates/plugin_template/ plugins/your_plugin_name/
   ```

2. **修改插件信息**
   编辑 `manifest.json` 文件，更新插件的基本信息：
   - `id`: 插件唯一标识符
   - `name`: 插件显示名称
   - `author`: 您的名字
   - `description`: 插件功能描述

3. **实现插件功能**
   在 `main.js` 中实现您的插件逻辑

4. **测试插件**
   在插件管理界面启用并测试您的插件

## 文件结构

```
plugin_template/
├── manifest.json    # 插件清单文件
├── main.js         # 插件主代码
└── README.md       # 说明文档
```

## 核心功能

### 生命周期管理
- `init()` - 插件初始化
- `start()` - 插件启动
- `stop()` - 插件停止
- `cleanup()` - 插件清理

### 配置管理
- `loadConfig()` - 加载配置
- `saveConfig()` - 保存配置
- `setConfig(key, value)` - 设置配置项
- `getConfig(key)` - 获取配置项

### 状态管理
- `getStatus()` - 获取插件状态
- 状态跟踪和更新

### 用户交互
- `handleUserAction()` - 处理用户操作
- 通知和对话框支持

### 调试支持
- `debug()` - 调试日志输出
- 详细的错误处理

## API使用示例

### 基础API
```javascript
// 日志记录
flutter.log('插件消息');

// 显示通知
flutter.showNotification('通知内容');

// 显示对话框
flutter.showDialog('标题', '内容');
```

### 数据存储
```javascript
// 保存数据
flutter.setData('key', 'value');

// 获取数据
const value = flutter.getData('key');
```

### 网络请求
```javascript
// GET请求
flutter.httpGet('https://api.example.com/data')
  .then(response => flutter.log('响应: ' + response))
  .catch(error => flutter.log('错误: ' + error));
```

## 开发建议

1. **遵循命名规范**
   - 使用有意义的函数和变量名
   - 保持代码风格一致

2. **完善错误处理**
   - 使用try-catch包装可能出错的代码
   - 提供有用的错误信息

3. **优化性能**
   - 避免阻塞操作
   - 及时清理资源

4. **编写文档**
   - 为复杂功能添加注释
   - 更新README文档

## 配置选项

默认配置项：
- `enabled` - 插件是否启用
- `debug` - 调试模式
- `auto_start` - 自动启动

您可以根据需要添加更多配置项。

## 故障排除

### 插件无法加载
- 检查manifest.json格式
- 确认entry_point文件存在
- 查看控制台错误信息

### 功能异常
- 查看调试日志
- 验证API调用

### 性能问题
- 检查是否有内存泄漏
- 优化定时器使用
- 减少不必要的API调用

## 更多资源

- [插件开发指南](../docs/plugin_development_guide.md)
- [API参考文档](../docs/api_reference.md)
- [Hello World示例](../plugins/hello_world/)

开始您的插件开发之旅吧！🚀