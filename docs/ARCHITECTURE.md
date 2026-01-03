# Astral 项目架构文档

## 目录结构

项目采用 **Features-based Architecture**（功能模块化架构），将代码按照业务功能划分为独立的模块，提高代码的可维护性和可扩展性。

### 核心目录结构

```
lib/
├── features/              # 功能模块（按业务领域划分）
│   ├── home/             # 首页模块
│   │   ├── pages/        # 首页相关页面
│   │   └── widgets/      # 首页专用组件
│   ├── rooms/            # 房间管理模块
│   │   ├── pages/        # 房间页面
│   │   └── widgets/      # 房间专用组件
│   ├── explore/          # 探索功能模块
│   │   ├── pages/        # 探索页面
│   │   └── widgets/      # 探索专用组件
│   ├── magic_wall/       # 魔法墙模块
│   │   └── pages/
│   ├── nat_test/         # NAT测试模块
│   │   └── pages/
│   └── settings/         # 设置模块
│       └── pages/
│           ├── general/  # 通用设置
│           └── network/  # 网络设置
│
├── shared/               # 共享资源（跨模块使用）
│   ├── models/          # 共享数据模型
│   ├── utils/           # 工具类
│   │   ├── data/        # 数据处理工具
│   │   ├── dialogs/     # 对话框工具
│   │   ├── helpers/     # 辅助函数
│   │   ├── network/     # 网络工具
│   │   └── ui/          # UI工具
│   └── widgets/         # 共享UI组件
│       ├── cards/       # 卡片组件
│       ├── common/      # 通用组件
│       │   └── home/    # 首页子组件
│       └── navigation/  # 导航组件
│
├── core/                # 核心架构层
│   ├── constants/       # 常量配置
│   ├── models/          # 核心数据模型
│   ├── repositories/    # 数据仓库层
│   ├── services/        # 业务服务层
│   ├── states/          # 状态管理
│   └── ui/              # UI基类
│
├── screens/             # 旧版屏幕层（逐步迁移中）
│   ├── logs_page.dart   # 日志页面
│   ├── main_screen.dart # 主屏幕
│   └── settings_page.dart # 设置入口
│
├── services/            # 应用级服务
│   ├── app_links/       # 深度链接处理
│   └── [其他服务]
│
├── src/                 # Rust FFI 绑定
│   └── rust/
│
├── generated/           # 自动生成的代码
│   └── locale_keys.g.dart
│
├── app.dart             # 应用入口
└── main.dart            # 主函数
```

## 架构层次

### 1. Features Layer（功能层）
- **职责**：实现具体的业务功能模块
- **原则**：每个feature应尽可能独立，减少与其他feature的耦合
- **包含**：pages（页面）、widgets（专用组件）

### 2. Shared Layer（共享层）
- **职责**：提供跨模块复用的组件和工具
- **原则**：只包含纯函数和无状态组件，不依赖具体业务逻辑
- **包含**：
  - `models/`: 共享数据模型（如 HistoryVersion）
  - `utils/`: 工具函数库
  - `widgets/`: 可复用UI组件

### 3. Core Layer（核心层）
- **职责**：提供应用的基础架构和核心业务逻辑
- **架构模式**：Clean Architecture
  - **Repository**: 数据访问层，封装数据源（Isar数据库、API等）
  - **Service**: 业务逻辑层，协调多个Repository
  - **State**: 响应式状态管理（使用 signals_flutter）
- **原则**：自下而上单向依赖，Service → State → Repository

### 4. Service Manager（服务管理器）
- **位置**：`lib/core/services/service_manager.dart`
- **职责**：单例模式管理所有服务、状态和仓库
- **管理对象**：
  - 15个状态（States）
  - 7个服务（Services）
  - 6个仓库（Repositories）

## 关键组件

### BaseSettingsPage
- **位置**：`lib/core/ui/base_settings_page.dart`
- **作用**：设置页面的基类，提供统一的UI结构
- **变体**：
  - `BaseSettingsPage`: 无状态设置页
  - `BaseStatefulSettingsPage`: 有状态设置页
- **辅助方法**：
  - `buildSettingsCard()`: 构建设置卡片
  - `buildDivider()`: 构建分隔线
  - `buildEmptyState()`: 构建空状态提示

### Navigation
- **响应式导航**：使用 `signals_flutter` 实现响应式页面切换
- **导航组件**：
  - `BottomNav`: 底部导航栏（移动端）
  - `LeftNav`: 侧边导航栏（桌面端）

## 技术栈

- **UI框架**：Flutter 3.x
- **状态管理**：signals_flutter ^6.0.2
- **本地数据库**：Isar Community 3.3.0
- **FFI桥接**：flutter_rust_bridge 2.11.1
- **国际化**：easy_localization

## 迁移指南

### 从旧结构迁移到新结构

1. **页面迁移**：
   ```
   lib/screens/xxx_page.dart → lib/features/{module}/pages/xxx_page.dart
   ```

2. **组件迁移**：
   ```
   lib/widgets/xxx.dart → lib/shared/widgets/{category}/xxx.dart
   ```

3. **工具类迁移**：
   ```
   lib/utils/xxx.dart → lib/shared/utils/{category}/xxx.dart
   ```

4. **导入路径更新**：
   - 使用全路径导入：`package:astral/features/...`
   - 避免相对路径导入

## 开发规范

### 1. 命名约定
- **文件名**：snake_case（如 `user_page.dart`）
- **类名**：PascalCase（如 `UserPage`）
- **变量名**：camelCase（如 `userName`）

### 2. 目录组织
- 每个feature应包含自己的 pages/ 和 widgets/ 目录
- 跨模块使用的组件必须放在 shared/ 中
- 业务逻辑应放在 core/services/ 中

### 3. 依赖原则
- Features 可以依赖 Shared 和 Core
- Shared 只能依赖 Core
- Features 之间不应直接依赖（通过 Core 通信）

## 未来优化方向

1. **完成屏幕迁移**：
   - 将 `lib/screens/` 中剩余文件迁移到对应feature

2. **创建导出文件**：
   - 为每个feature创建 `index.dart` 便于导入

3. **测试覆盖**：
   - 为每个feature添加单元测试和集成测试

4. **文档完善**：
   - 为每个feature编写README
   - 添加API文档注释

## 更新日志

### 2024-xx-xx - 架构重构
- 从扁平结构迁移到 features-based 架构
- 创建 features/、shared/ 目录结构
- 更新所有 import 路径
- 重命名 core/mod/ → core/constants/
- 删除空目录（widgets/, models/, core/mod/）
