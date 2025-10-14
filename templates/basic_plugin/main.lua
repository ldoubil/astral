-- 基础插件模板
-- 复制此模板开始开发您的插件

-- 插件信息
local plugin_info = {
    name = "我的插件",
    version = "1.0.0",
    author = "Your Name",
    description = "插件功能描述"
}

-- 插件配置
local config = {
    enabled = true,
    -- 在此添加您的配置项
}

-- 插件初始化函数
-- 在插件加载时调用
function init()
    log("插件初始化: " .. plugin_info.name)
    
    -- 加载配置
    load_config()
    
    -- 执行初始化逻辑
    -- TODO: 添加您的初始化代码
    
    show_notification(plugin_info.name, "插件已加载")
    return true
end

-- 加载插件配置
function load_config()
    local config_data = get_user_data("my_plugin_config")
    if config_data then
        -- 这里应该解析JSON配置
        -- config = parse_json(config_data) or config
        log("配置已加载")
    else
        -- 使用默认配置
        save_config()
        log("使用默认配置")
    end
end

-- 保存插件配置
function save_config()
    -- 这里应该将配置序列化为JSON
    -- local config_json = json_encode(config)
    -- set_user_data("my_plugin_config", config_json)
    log("配置已保存")
end

-- 主要功能函数
-- TODO: 实现您的插件功能
function main_function()
    log("执行主要功能")
    
    -- 示例：显示信息对话框
    local message = "这是插件的主要功能\n\n" ..
                   "插件名称: " .. plugin_info.name .. "\n" ..
                   "版本: " .. plugin_info.version
    
    show_dialog("插件信息", message)
end

-- 获取插件信息
function get_info()
    return plugin_info
end

-- 插件设置函数
function show_settings()
    local settings_text = "插件设置\n\n" ..
                         "状态: " .. (config.enabled and "启用" or "禁用") .. "\n" ..
                         "版本: " .. plugin_info.version .. "\n\n" ..
                         "TODO: 添加更多设置选项"
    
    show_dialog("设置", settings_text)
end

-- 插件清理函数
-- 在插件卸载时调用
function cleanup()
    log("插件清理: " .. plugin_info.name)
    
    -- 保存配置
    save_config()
    
    -- 执行清理逻辑
    -- TODO: 添加您的清理代码
    
    show_notification(plugin_info.name, "插件已卸载")
end

-- 导出插件函数
-- 只导出需要外部访问的函数
return {
    init = init,
    main_function = main_function,
    get_info = get_info,
    show_settings = show_settings,
    cleanup = cleanup
}