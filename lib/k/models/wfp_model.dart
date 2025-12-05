import 'package:astral/src/rust/api/astral_wfp.dart';
import 'package:isar_community/isar.dart';
part 'wfp_model.g.dart';

// WfpModel
@collection
class WfpModel {
  /// 主键自增
  Id id = Isar.autoIncrement;

  /// 名称
  @Index()
  String name = '';

  /// 启用
  bool enabled = true;

  /// 协议类型
  String protocol = 'TCP'; // TCP, UDP, ICMP, ALL

  /// 方向
  String direction = 'both'; // inbound, outbound, both

  /// 过滤动作
  String action = 'block'; // allow, block

  /// 优先级
  int priority = 0;

  /// 可选：应用路径
  String? appPath;

  /// 可选：本地规则
  String? localRule;

  /// 可选：远程规则
  String? remoteRule;
}
