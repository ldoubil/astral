# 插件模板

本目录包含了不同类型的插件开发模板，帮助您快速开始插件开发。

## 模板类型

### 1. 基础插件模板 (`basic_plugin/`)

适合初学者和简单功能插件的模板。

**特性：**
- 基本的插件结构
- 简单的配置管理
- 通知和对话框功能
- 完整的生命周期管理

**适用场景：**
- 简单的工具插件
- 学习插件开发
- 快速原型开发

### 2. 高级插件模板 (`advanced_plugin/`)

适合复杂功能和专业开发的模板。

**特性：**
- 网络请求功能
- 数据持久化存储
- 错误处理机制
- 定时任务支持
- 配置管理系统
- 数据缓存机制

**适用场景：**
- 需要网络交互的插件
- 数据处理插件
- 企业级插件开发

## 使用方法

### 1. 选择模板

根据您的需求选择合适的模板：
- 简单功能 → 使用基础模板
- 复杂功能 → 使用高级模板

### 2. 复制模板

```bash
# 复制基础模板
cp -r templates/basic_plugin/ my_new_plugin/

# 或复制高级模板
cp -r templates/advanced_plugin/ my_new_plugin/
```

### 3. 修改配置

编辑 `manifest.json` 文件：

```json
{
  "id": "your_plugin_id",           // 修改为您的插件ID
  "name": "您的插件名称",            // 修改插件名称
  "version": "1.0.0",               // 设置版本号
  "author": "您的名字",              // 设置作者
  "description": "插件功能描述",     // 描述插件功能
  "entry_point": "main.lua",        // 保持不变
  "homepage": "您的项目主页",        // 设置项目主页
  "permissions": [                  // 根据需要调整权限
    "show_notification",
    "show_dialog"
  ]
}
```

### 4. 实现功能

编辑 `main.lua` 文件，实现您的插件功能：

1. **修改插件信息**：更新 `plugin_info` 表
2. **配置参数**：根据需要修改 `config` 表
3. **实现功能**：在相应的函数中添加您的代码
4. **测试插件**：使用日志和通知进行调试

### 5. 测试插件

1. 将插件文件夹放入应用的插件目录
2. 重启应用或重新加载插件
3. 检查日志输出和功能是否正常

## 开发指南

### 必需函数

每个插件都必须实现以下函数：

```lua
function init()
    -- 插件初始化代码
    return true  -- 返回true表示初始化成功
end

function cleanup()
    -- 插件清理代码
end
```

### 推荐实践

1. **错误处理**：始终包含适当的错误处理
2. **日志记录**：使用 `log()` 函数记录重要事件
3. **用户反馈**：使用通知告知用户操作结果
4. **资源管理**：在 `cleanup()` 中释放资源
5. **配置管理**：提供配置保存和加载功能

### 权限系统

根据插件功能申请必要的权限：

- `show_notification` - 显示通知
- `show_dialog` - 显示对话框
- `http_get` - HTTP GET请求
- `http_post` - HTTP POST请求
- `get_app_version` - 获取应用版本
- `get_user_data` - 读取用户数据
- `set_user_data` - 写入用户数据

### 调试技巧

1. **使用日志**：`log("调试信息")`
2. **显示变量**：`log("变量值: " .. tostring(variable))`
3. **错误捕获**：使用 pcall 包装可能出错的代码
4. **分步测试**：逐步实现和测试功能

## 示例代码片段

### 配置管理

```lua
function load_config()
    local config_data = get_user_data("my_plugin_config")
    if config_data then
        -- 解析配置
        config = parse_json(config_data) or config
    end
end

function save_config()
    local config_json = json_encode(config)
    set_user_data("my_plugin_config", config_json)
end
```

### 网络请求

```lua
function fetch_data(url, callback)
    http_get(url, 
        function(response)
            -- 成功回调
            callback(true, response)
        end,
        function(error)
            -- 错误回调
            log("请求失败: " .. error)
            callback(false, nil)
        end
    )
end
```

### 错误处理

```lua
function safe_execute(func, error_msg)
    local success, result = pcall(func)
    if not success then
        log("错误: " .. error_msg .. " - " .. tostring(result))
        show_notification("错误", error_msg)
        return false
    end
    return true, result
end
```

## 相关文档

- [插件开发文档](../docs/plugin_development.md)
- [API参考](../docs/api_reference.md)
- [内置插件示例](../plugins/)

## 支持

如果您在开发过程中遇到问题，请：

1. 查看文档和示例代码
2. 检查日志输出
3. 参考内置插件的实现
4. 在项目仓库提交Issue

祝您开发愉快！