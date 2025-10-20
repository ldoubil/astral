# Astral 插件开发指南

欢迎使用Astral插件系统！本指南将帮助您快速上手插件开发，创建功能强大的扩展。

## 目录

1. [快速开始](#快速开始)
2. [插件结构](#插件结构)
3. [API参考](#api参考)
4. [生命周期](#生命周期)
5. [权限系统](#权限系统)
6. [最佳实践](#最佳实践)
7. [调试技巧](#调试技巧)
8. [发布插件](#发布插件)

## 快速开始

### 1. 创建插件

复制插件模板开始开发：

```bash
cp -r templates/plugin_template/ plugins/my_awesome_plugin/
```

### 2. 修改插件信息

编辑 `manifest.json` 文件：

```json
{
  "id": "my_awesome_plugin",
  "name": "我的超棒插件",
  "version": "1.0.0",
  "author": "您的名字",
  "description": "插件功能描述",
  "entry_point": "main.js",
  "permissions": ["show_notification", "show_dialog"],
  "dependencies": []
}
```

### 3. 实现插件功能

在 `main.js` 中实现您的插件逻辑：

```javascript
function init() {
    flutter.log('我的插件初始化');
    return true;
}

function start() {
    flutter.showNotification('插件启动成功！');
}
```

### 4. 测试插件

1. 重启应用或刷新插件列表
2. 在插件管理界面启用您的插件
3. 查看日志输出和功能效果

## 插件结构

标准的插件目录结构：

```
my_plugin/
├── manifest.json    # 插件清单文件（必需）
├── main.js         # 插件主代码（必需）
├── README.md       # 说明文档（推荐）
├── assets/         # 资源文件（可选）
│   ├── icon.png
│   └── styles.css
└── lib/           # 库文件（可选）
    └── utils.js
```

### manifest.json 字段说明

| 字段 | 类型 | 必需 | 说明 |
|------|------|------|------|
| `id` | string | ✓ | 插件唯一标识符 |
| `name` | string | ✓ | 插件显示名称 |
| `version` | string | ✓ | 插件版本号 |
| `author` | string | ✓ | 插件作者 |
| `description` | string | ✓ | 插件描述 |
| `entry_point` | string | ✓ | 入口文件路径 |
| `homepage` | string | - | 项目主页 |
| `permissions` | array | - | 所需权限列表 |
| `dependencies` | array | - | 依赖的其他插件 |
| `config` | object | - | 默认配置 |

## API参考

### 基础API

#### 日志记录
```javascript
flutter.log(message)
```
记录日志信息，用于调试和监控。

#### 通知系统
```javascript
flutter.showNotification(message)
```
显示系统通知给用户。

#### 对话框
```javascript
flutter.showDialog(title, message)
```
显示模态对话框。

### 数据存储API

#### 获取数据
```javascript
const value = flutter.getData(key)
```
从插件存储中获取数据。

#### 存储数据
```javascript
flutter.setData(key, value)
```
将数据存储到插件存储中。

### 网络API

#### HTTP GET请求
```javascript
flutter.httpGet(url).then(response => {
    flutter.log('响应: ' + response);
}).catch(error => {
    flutter.log('错误: ' + error);
});
```

#### HTTP POST请求
```javascript
flutter.httpPost(url, data).then(response => {
    flutter.log('响应: ' + response);
}).catch(error => {
    flutter.log('错误: ' + error);
});
```

### 应用信息API

#### 获取应用版本
```javascript
const version = flutter.getAppVersion();
```

## 生命周期

插件具有完整的生命周期管理：

### 1. 初始化 (init)
```javascript
function init() {
    // 插件初始化逻辑
    // 加载配置、初始化状态等
    return true; // 返回true表示成功
}
```

### 2. 启动 (start)
```javascript
function start() {
    // 插件启动逻辑
    // 开始执行主要功能
}
```

### 3. 停止 (stop)
```javascript
function stop() {
    // 插件停止逻辑
    // 暂停功能、保存数据等
}
```

### 4. 清理 (cleanup)
```javascript
function cleanup() {
    // 插件清理逻辑
    // 释放资源、最终保存等
}
```

## 权限系统

插件需要在 `manifest.json` 中声明所需权限：

### 可用权限

| 权限 | 说明 |
|------|------|
| `show_notification` | 显示系统通知 |
| `show_dialog` | 显示对话框 |
| `http_get` | 发送HTTP GET请求 |
| `http_post` | 发送HTTP POST请求 |
| `get_app_version` | 获取应用版本信息 |
| `get_user_data` | 获取用户数据 |
| `set_user_data` | 设置用户数据 |
| `file_read` | 读取文件 |
| `file_write` | 写入文件 |

### 权限声明示例

```json
{
  "permissions": [
    "show_notification",
    "http_get",
    "get_app_version"
  ]
}
```

## 最佳实践

### 1. 错误处理

始终包含适当的错误处理：

```javascript
function myFunction() {
    try {
        // 您的代码
    } catch (error) {
        flutter.log('错误: ' + error.message);
    }
}
```

### 2. 配置管理

使用配置对象管理插件设置：

```javascript
let config = {
    enabled: true,
    interval: 60000,
    debug: false
};

function loadConfig() {
    const saved = flutter.getData('config');
    if (saved) {
        config = Object.assign(config, JSON.parse(saved));
    }
}

function saveConfig() {
    flutter.setData('config', JSON.stringify(config));
}
```

### 3. 状态管理

维护清晰的插件状态：

```javascript
let state = {
    initialized: false,
    running: false,
    lastUpdate: null
};

function updateState(newState) {
    state = Object.assign(state, newState);
    state.lastUpdate = new Date();
}
```

### 4. 资源清理

在停止和清理时释放资源：

```javascript
let timers = [];

function start() {
    const timer = setInterval(() => {
        // 定时任务
    }, 60000);
    timers.push(timer);
}

function cleanup() {
    timers.forEach(timer => clearInterval(timer));
    timers = [];
}
```

## 调试技巧

### 1. 日志记录

使用详细的日志记录：

```javascript
function debug(message) {
    if (config.debug) {
        flutter.log('[DEBUG] ' + message);
    }
}
```

### 2. 状态检查

实现状态检查函数：

```javascript
function getStatus() {
    return {
        initialized: state.initialized,
        running: state.running,
        config: config,
        lastUpdate: state.lastUpdate
    };
}
```

### 3. 测试模式

添加测试模式支持：

```javascript
function runTests() {
    flutter.log('开始测试...');
    
    // 测试基本功能
    try {
        flutter.showNotification('测试通知');
        flutter.log('通知测试通过');
    } catch (e) {
        flutter.log('通知测试失败: ' + e.message);
    }
    
    flutter.log('测试完成');
}
```

## 发布插件

### 1. 版本管理

使用语义化版本号：
- `1.0.0` - 主版本.次版本.修订版本
- 主版本：不兼容的API修改
- 次版本：向下兼容的功能性新增
- 修订版本：向下兼容的问题修正

### 2. 文档编写

为插件编写完整的README.md：

```markdown
# 插件名称

## 功能特性
- 功能1
- 功能2

## 安装方法
1. 下载插件
2. 复制到plugins目录
3. 启用插件

## 使用说明
详细的使用说明...

## 配置选项
可用的配置选项...
```

### 3. 测试清单

发布前检查：
- [ ] 所有生命周期函数正常工作
- [ ] 错误处理完善
- [ ] 权限声明正确
- [ ] 文档完整
- [ ] 版本号正确

## 示例插件

查看以下示例插件了解更多：

1. **Hello World** (`plugins/hello_world/`) - 基础功能演示
2. **插件模板** (`templates/plugin_template/`) - 开发模板

## 常见问题

### Q: 插件无法加载？
A: 检查manifest.json格式是否正确，entry_point文件是否存在。

### Q: API调用失败？
A: 确认已在manifest.json中声明相应权限。

### Q: 数据无法持久化？
A: 使用flutter.setData()保存数据，确保在stop()中调用。

### Q: 如何调试插件？
A: 使用flutter.log()输出调试信息，查看控制台日志。

## 技术支持

如需帮助，请：
1. 查看示例插件代码
2. 阅读API文档
3. 提交Issue到项目仓库

祝您开发愉快！🚀