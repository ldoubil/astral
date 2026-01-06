/// 魔法墙规则配置常量
class MagicWallRuleConfig {
  final String name; // 规则名称
  final String action; // 动作 (allow/block)
  final String protocol; // 协议 (tcp/udp/both/any)
  final String direction; // 方向 (inbound/outbound/both)
  final String? appPath; // 应用程序路径
  final String? remoteIp; // 远程 IP/CIDR
  final String? localIp; // 本地 IP/CIDR
  final String? remotePort; // 远程端口或端口范围
  final String? localPort; // 本地端口或端口范围
  final String? description; // 规则描述
  final int priority; // 优先级（数字越大优先级越高）

  const MagicWallRuleConfig({
    required this.name,
    this.action = 'block',
    this.protocol = 'both',
    this.direction = 'both',
    this.appPath,
    this.remoteIp,
    this.localIp,
    this.remotePort,
    this.localPort,
    this.description,
    this.priority = 0,
  });
}

/// 魔法墙规则组配置
class MagicWallGroupConfig {
  final String name; // 配置名称
  final String processName; // 绑定进程名称
  final bool autoManage; // 是否自动随进程启动/关闭
  final List<MagicWallRuleConfig> rules; // 规则列表

  const MagicWallGroupConfig({
    required this.name,
    required this.processName,
    this.autoManage = true,
    this.rules = const [],
  });
}

/// 魔法墙固定配置常量
class MagicWallConfigs {
  /// 预定义的魔法墙规则组列表
  static const List<MagicWallGroupConfig> groups = [
    // Minecraft 游戏规则组
    MagicWallGroupConfig(
      name: 'payday2',
      processName: 'payday2_win32_release.exe',
      autoManage: true,
      rules: [
        MagicWallRuleConfig(
          name: '阻止UDP端口3478',
          action: 'block',
          protocol: 'udp',
          direction: 'both',
          remotePort: '3478',
          description: '阻止UDP端口3478的双向连接',
          priority: 90,
        ),
      ],
    ),
  ];

  /// 根据索引获取规则组配置
  static MagicWallGroupConfig getGroupByIndex(int index) {
    if (index < 0 || index >= groups.length) {
      return groups[0]; // 默认返回第一个
    }
    return groups[index];
  }

  /// 根据名称获取规则组索引
  static int getIndexByGroupName(String name) {
    for (int i = 0; i < groups.length; i++) {
      if (groups[i].name == name) {
        return i;
      }
    }
    return -1; // 未找到
  }

  /// 获取规则组总数
  static int get count => groups.length;

  /// 根据进程名获取相关规则组
  static List<MagicWallGroupConfig> getGroupsByProcessName(String processName) {
    return groups
        .where(
          (group) =>
              group.processName.toLowerCase() == processName.toLowerCase(),
        )
        .toList();
  }
}
