/// 魔法墙使用示例
///
/// 这个文件展示了如何使用魔法墙功能的一些常见场景

import 'package:astral/k/models/magic_wall_model.dart';
import 'package:astral/k/database/app_data.dart';
import 'package:uuid/uuid.dart';

class MagicWallExamples {
  static const _uuid = Uuid();

  /// 示例 1: 阻止特定端口的入站连接
  static MagicWallRuleModel blockInboundPort(int port, String description) {
    return MagicWallRuleModel()
      ..ruleId = _uuid.v4()
      ..name = '阻止端口 $port 入站'
      ..enabled = true
      ..action = 'block'
      ..protocol = 'both'
      ..direction = 'inbound'
      ..localPort = port.toString()
      ..description = description
      ..createdAt = DateTime.now().millisecondsSinceEpoch
      ..priority = 100;
  }

  /// 示例 2: 允许特定应用程序访问网络
  static MagicWallRuleModel allowApplication(String appName, String appPath) {
    return MagicWallRuleModel()
      ..ruleId = _uuid.v4()
      ..name = '允许 $appName 联网'
      ..enabled = true
      ..action = 'allow'
      ..protocol = 'both'
      ..direction = 'both'
      ..appPath = appPath
      ..description = '允许 $appName 访问网络'
      ..createdAt = DateTime.now().millisecondsSinceEpoch
      ..priority = 200;
  }

  /// 示例 3: 阻止特定 IP 段
  static MagicWallRuleModel blockIpRange(String cidr, String description) {
    return MagicWallRuleModel()
      ..ruleId = _uuid.v4()
      ..name = '阻止 $cidr'
      ..enabled = true
      ..action = 'block'
      ..protocol = 'both'
      ..direction = 'both'
      ..remoteIp = cidr
      ..description = description
      ..createdAt = DateTime.now().millisecondsSinceEpoch
      ..priority = 150;
  }

  /// 示例 4: 仅允许访问本地网络
  static MagicWallRuleModel allowLocalNetwork() {
    return MagicWallRuleModel()
      ..ruleId = _uuid.v4()
      ..name = '允许本地网络'
      ..enabled = true
      ..action = 'allow'
      ..protocol = 'both'
      ..direction = 'both'
      ..remoteIp = '192.168.0.0/16'
      ..description = '允许访问局域网设备'
      ..createdAt = DateTime.now().millisecondsSinceEpoch
      ..priority = 250;
  }

  /// 示例 5: 阻止 P2P 文件共享端口
  static List<MagicWallRuleModel> blockP2PPorts() {
    final now = DateTime.now().millisecondsSinceEpoch;

    return [
      // BitTorrent
      MagicWallRuleModel()
        ..ruleId = _uuid.v4()
        ..name = '阻止 BitTorrent'
        ..enabled = true
        ..action = 'block'
        ..protocol = 'both'
        ..direction = 'both'
        ..remotePort = '6881-6889'
        ..description = '阻止 BitTorrent P2P 端口'
        ..createdAt = now
        ..priority = 100,

      // eMule
      MagicWallRuleModel()
        ..ruleId = _uuid.v4()
        ..name = '阻止 eMule'
        ..enabled = true
        ..action = 'block'
        ..protocol = 'both'
        ..direction = 'both'
        ..remotePort = '4662'
        ..description = '阻止 eMule 端口'
        ..createdAt = now
        ..priority = 100,
    ];
  }

  /// 示例 6: 允许常见服务端口
  static List<MagicWallRuleModel> allowCommonServices() {
    final now = DateTime.now().millisecondsSinceEpoch;

    return [
      // HTTP/HTTPS
      MagicWallRuleModel()
        ..ruleId = _uuid.v4()
        ..name = '允许 HTTP/HTTPS'
        ..enabled = true
        ..action = 'allow'
        ..protocol = 'tcp'
        ..direction = 'outbound'
        ..remotePort = '80'
        ..description = 'Web 浏览'
        ..createdAt = now
        ..priority = 300,

      MagicWallRuleModel()
        ..ruleId = _uuid.v4()
        ..name = '允许 HTTPS'
        ..enabled = true
        ..action = 'allow'
        ..protocol = 'tcp'
        ..direction = 'outbound'
        ..remotePort = '443'
        ..description = 'HTTPS 安全浏览'
        ..createdAt = now
        ..priority = 300,

      // DNS
      MagicWallRuleModel()
        ..ruleId = _uuid.v4()
        ..name = '允许 DNS'
        ..enabled = true
        ..action = 'allow'
        ..protocol = 'udp'
        ..direction = 'outbound'
        ..remotePort = '53'
        ..description = '域名解析'
        ..createdAt = now
        ..priority = 300,
    ];
  }

  /// 示例 7: 创建家长控制规则（工作时段）
  static List<MagicWallRuleModel> createWorkHoursRules() {
    final now = DateTime.now().millisecondsSinceEpoch;

    return [
      // 阻止游戏端口
      MagicWallRuleModel()
        ..ruleId = _uuid.v4()
        ..name = '工作时段-阻止游戏'
        ..enabled =
            false // 需要手动启用或根据时间调度
        ..action = 'block'
        ..protocol = 'both'
        ..direction = 'both'
        ..remotePort =
            '27015-27030' // Steam 游戏端口
        ..description = '工作时段阻止游戏'
        ..createdAt = now
        ..priority = 50,

      // 阻止视频流媒体
      MagicWallRuleModel()
        ..ruleId = _uuid.v4()
        ..name = '工作时段-阻止流媒体'
        ..enabled = false
        ..action = 'block'
        ..protocol = 'both'
        ..direction = 'both'
        ..remotePort =
            '1935' // RTMP 端口
        ..description = '工作时段阻止视频流'
        ..createdAt = now
        ..priority = 50,
    ];
  }

  /// 批量保存规则到数据库
  static Future<void> saveRulesToDatabase(
    List<MagicWallRuleModel> rules,
  ) async {
    final db = await AppD().db;
    await db.MagicWallSetting.addMagicWallRules(rules);
  }

  /// 加载预设规则集
  static Future<void> loadPresetRules(String presetName) async {
    List<MagicWallRuleModel> rules;

    switch (presetName) {
      case 'security_basic':
        // 基础安全规则
        rules = [
          blockInboundPort(445, '阻止 SMB 漏洞端口'),
          blockInboundPort(135, '阻止 RPC 端口'),
          blockInboundPort(139, '阻止 NetBIOS 端口'),
        ];
        break;

      case 'local_only':
        // 仅本地网络
        rules = [
          allowLocalNetwork(),
          MagicWallRuleModel()
            ..ruleId = _uuid.v4()
            ..name = '阻止其他所有出站'
            ..enabled = true
            ..action = 'block'
            ..protocol = 'both'
            ..direction = 'outbound'
            ..description = '仅允许本地网络通信'
            ..createdAt = DateTime.now().millisecondsSinceEpoch
            ..priority = 10,
        ];
        break;

      case 'parental_control':
        // 家长控制
        rules = createWorkHoursRules();
        break;

      case 'no_p2p':
        // 禁止 P2P
        rules = blockP2PPorts();
        break;

      default:
        rules = [];
    }

    await saveRulesToDatabase(rules);
  }
}
