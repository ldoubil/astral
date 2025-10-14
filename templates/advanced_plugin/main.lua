-- 高级插件模板
-- 包含网络请求、数据存储、错误处理等高级功能

-- 插件信息
local plugin_info = {
    name = "高级插件模板",
    version = "1.0.0",
    author = "Your Name",
    description = "具有网络请求、数据存储和复杂UI的高级插件模板"
}

-- 插件配置
local config = {
    enabled = true,
    api_url = "https://api.example.com",
    refresh_interval = 300, -- 5分钟
    max_retries = 3,
    timeout = 10000, -- 10秒
    debug_mode = false
}

-- 插件状态
local state = {
    initialized = false,
    last_update = 0,
    error_count = 0,
    data_cache = {}
}

-- 工具函数
local utils = {}

-- JSON解析工具（简单实现）
function utils.parse_json(json_str)
    -- 这里应该使用真正的JSON解析器
    -- 目前只是示例
    return {}
end

function utils.encode_json(data)
    -- 这里应该使用真正的JSON编码器
    -- 目前只是示例
    return "{}"
end

-- 错误处理
function utils.handle_error(error_msg, context)
    state.error_count = state.error_count + 1
    local full_msg = "[" .. plugin_info.name .. "] 错误: " .. error_msg
    
    if context then
        full_msg = full_msg .. " (上下文: " .. context .. ")"
    end
    
    log(full_msg)
    
    if config.debug_mode then
        show_notification("插件错误", error_msg)
    end
end

-- 网络请求封装
function utils.make_request(url, method, data, callback)
    method = method or "GET"
    
    local function on_success(response)
        if callback then
            callback(true, response)
        end
    end
    
    local function on_error(error)
        utils.handle_error("网络请求失败: " .. error, url)
        if callback then
            callback(false, nil)
        end
    end
    
    if method == "GET" then
        http_get(url, on_success, on_error)
    elseif method == "POST" then
        http_post(url, data or "", on_success, on_error)
    end
end

-- 数据管理
local data_manager = {}

function data_manager.save(key, data)
    local json_data = utils.encode_json(data)
    set_user_data(plugin_info.name .. "_" .. key, json_data)
end

function data_manager.load(key, default_value)
    local json_data = get_user_data(plugin_info.name .. "_" .. key)
    if json_data then
        return utils.parse_json(json_data)
    end
    return default_value
end

function data_manager.clear(key)
    set_user_data(plugin_info.name .. "_" .. key, "")
end

-- 配置管理
function load_config()
    local saved_config = data_manager.load("config", nil)
    if saved_config then
        -- 合并保存的配置和默认配置
        for key, value in pairs(saved_config) do
            if config[key] ~= nil then
                config[key] = value
            end
        end
        log("配置已加载")
    else
        save_config()
        log("使用默认配置")
    end
end

function save_config()
    data_manager.save("config", config)
    log("配置已保存")
end

-- 数据获取和处理
function fetch_data()
    log("开始获取数据...")
    
    utils.make_request(config.api_url, "GET", nil, function(success, response)
        if success then
            -- 处理响应数据
            process_data(response)
            state.last_update = os.time()
            state.error_count = 0
            
            show_notification(plugin_info.name, "数据更新成功")
        else
            utils.handle_error("数据获取失败", "fetch_data")
            
            if state.error_count >= config.max_retries then
                show_notification(plugin_info.name, "数据获取失败，已达到最大重试次数")
            end
        end
    end)
end

function process_data(raw_data)
    -- 处理原始数据
    log("处理数据: " .. tostring(raw_data))
    
    -- 缓存处理后的数据
    state.data_cache = {
        raw = raw_data,
        processed_at = os.time(),
        -- 添加处理后的数据字段
    }
    
    -- 保存到持久存储
    data_manager.save("cache", state.data_cache)
end

-- UI功能
function show_main_dialog()
    local app_version = get_app_version()
    local last_update_str = state.last_update > 0 and 
                           os.date("%Y-%m-%d %H:%M:%S", state.last_update) or 
                           "从未更新"
    
    local dialog_text = plugin_info.name .. "\n\n" ..
                       "版本: " .. plugin_info.version .. "\n" ..
                       "应用版本: " .. app_version .. "\n" ..
                       "最后更新: " .. last_update_str .. "\n" ..
                       "错误次数: " .. state.error_count .. "\n" ..
                       "状态: " .. (config.enabled and "启用" or "禁用") .. "\n\n" ..
                       "缓存数据: " .. (state.data_cache.raw and "有数据" or "无数据")
    
    show_dialog("插件状态", dialog_text)
end

function show_settings_dialog()
    local settings_text = "插件设置\n\n" ..
                         "API地址: " .. config.api_url .. "\n" ..
                         "刷新间隔: " .. config.refresh_interval .. "秒\n" ..
                         "最大重试: " .. config.max_retries .. "次\n" ..
                         "超时时间: " .. config.timeout .. "毫秒\n" ..
                         "调试模式: " .. (config.debug_mode and "开启" or "关闭") .. "\n\n" ..
                         "注意: 修改设置需要重新加载插件"
    
    show_dialog("设置", settings_text)
end

-- 定时任务
function start_periodic_update()
    -- 这里应该实现定时器功能
    -- 目前只是示例
    log("定时更新已启动，间隔: " .. config.refresh_interval .. "秒")
end

function stop_periodic_update()
    -- 停止定时器
    log("定时更新已停止")
end

-- 插件生命周期函数
function init()
    log("初始化高级插件: " .. plugin_info.name)
    
    -- 加载配置
    load_config()
    
    -- 加载缓存数据
    state.data_cache = data_manager.load("cache", {})
    
    -- 启动定时任务
    if config.enabled then
        start_periodic_update()
    end
    
    state.initialized = true
    show_notification(plugin_info.name, "插件已初始化")
    
    return true
end

-- 主要功能函数
function refresh_data()
    if not state.initialized then
        utils.handle_error("插件未初始化", "refresh_data")
        return
    end
    
    if not config.enabled then
        show_notification(plugin_info.name, "插件已禁用")
        return
    end
    
    fetch_data()
end

function toggle_plugin()
    config.enabled = not config.enabled
    save_config()
    
    local status = config.enabled and "启用" or "禁用"
    show_notification(plugin_info.name, "插件已" .. status)
    
    if config.enabled then
        start_periodic_update()
    else
        stop_periodic_update()
    end
end

function clear_cache()
    state.data_cache = {}
    data_manager.clear("cache")
    show_notification(plugin_info.name, "缓存已清除")
end

function export_data()
    local export_data = {
        plugin_info = plugin_info,
        config = config,
        state = {
            last_update = state.last_update,
            error_count = state.error_count
        },
        cache = state.data_cache,
        exported_at = os.time()
    }
    
    local export_json = utils.encode_json(export_data)
    data_manager.save("export_" .. os.time(), export_data)
    
    show_notification(plugin_info.name, "数据已导出")
end

-- 获取插件信息
function get_info()
    return plugin_info
end

function get_status()
    return {
        initialized = state.initialized,
        enabled = config.enabled,
        last_update = state.last_update,
        error_count = state.error_count,
        has_cache = state.data_cache.raw ~= nil
    }
end

-- 插件清理
function cleanup()
    log("清理高级插件: " .. plugin_info.name)
    
    -- 停止定时任务
    stop_periodic_update()
    
    -- 保存配置和状态
    save_config()
    data_manager.save("state", {
        last_update = state.last_update,
        error_count = state.error_count
    })
    
    state.initialized = false
    show_notification(plugin_info.name, "插件已清理")
end

-- 导出插件接口
return {
    -- 生命周期
    init = init,
    cleanup = cleanup,
    
    -- 主要功能
    refresh_data = refresh_data,
    toggle_plugin = toggle_plugin,
    clear_cache = clear_cache,
    export_data = export_data,
    
    -- UI
    show_main_dialog = show_main_dialog,
    show_settings_dialog = show_settings_dialog,
    
    -- 信息获取
    get_info = get_info,
    get_status = get_status
}