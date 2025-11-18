/// 用户信息数据模型
/// 用于存储房间内用户的基本信息
class UserInfo {
  /// 构造函数
  /// [name] 用户名称
  /// [avatarUrl] 用户头像URL
  /// [ip] 用户IP地址
  /// [latency] 用户网络延迟（单位：毫秒）
  /// [device] 用户设备信息
  const UserInfo({
    required this.name,
    required this.avatarUrl,
    required this.ip,
    required this.latency,
    this.device = '',
  });

  /// 用户名称
  final String name;
  //  头像url
  final String avatarUrl;

  /// 用户IP地址
  final String ip;

  /// 网络延迟（单位：毫秒）
  /// 用于显示用户网络连接质量
  final int latency;

  /// 用户设备信息
  /// 例如：Windows、macOS、Linux、Android、iOS 等
  final String device;
}
