# 缺失翻译项分析

## 需要添加的翻译键

### 网络设置相关
- `network_adapter_hop_desc`: "配置网络适配器跳数"
- `listen_list_desc`: "管理网络监听地址"  
- `subnet_proxy_desc`: "配置子网代理规则"
- `update_behavior_desc`: "Configure update behavior and channels"

### 房间配置相关
- `room_basic_info`: "基本信息"
- `room_name`: "房间名称"
- `room_uuid`: "房间唯一标识"
- `network_config`: "网络配置"
- `hostname`: "主机名"
- `instance_name`: "实例名"
- `network_name`: "网络名称"
- `network_secret`: "网络密钥"
- `room_protect`: "房间保护"
- `listeners`: "监听列表"

### 服务器管理相关
- `custom_server`: "自定义服务器"
- `public_server`: "公共服务器"
- `server_management`: "服务器管理"
- `plugin_management`: "插件管理"

### 用户界面相关
- `user_profile`: "用户资料"
- `connection_status`: "连接状态"
- `log_management`: "日志管理"

## 硬编码字符串位置

### settings_main_page.dart
- 第36行: "配置网络适配器跳数"
- 第44行: "管理网络监听地址"
- 第50行: "配置子网代理规则"

### update_settings_page.dart  
- 第30行: "Configure update behavior and channels"

### room_config_form_page.dart
- 多处硬编码的中文注释和字符串

### 其他文件
- custom_server_selection_page.dart
- plugin_management_page.dart
- user_page.dart
- logs_page.dart
- 等多个文件包含硬编码字符串

## 建议的修复方案

1. 将所有硬编码字符串提取为翻译键
2. 更新LocaleKeys类添加新的翻译键
3. 在所有语言文件中添加对应的翻译内容
4. 更新相关Dart文件使用翻译键而非硬编码字符串