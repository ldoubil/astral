/// IP地址和CIDR相关的工具函数
library;

/// 将整数转换为IPv4地址字符串
///
/// 例如: 3232235777 -> "192.168.1.1"
String intToIp(int ipInt) {
  return [
    (ipInt >> 24) & 0xFF,
    (ipInt >> 16) & 0xFF,
    (ipInt >> 8) & 0xFF,
    ipInt & 0xFF,
  ].join('.');
}

/// 验证IPv4地址格式是否有效
///
/// 返回 true 如果地址有效，否则返回 false
/// 排除特殊地址如 0.0.0.0, 255.255.255.255, 127.x.x.x
bool isValidIpAddress(String ip) {
  if (ip.isEmpty) return false;

  // 严格的正则表达式验证（每个数字段 0-255）
  final RegExp ipRegex = RegExp(
    r"^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",
  );

  // 排除特殊保留地址
  if (!ipRegex.hasMatch(ip) ||
      ip == "0.0.0.0" ||
      ip == "255.255.255.255" ||
      ip.startsWith("127.")) {
    return false;
  }
  return true;
}

/// 验证CIDR地址格式是否有效
///
/// 例如: "192.168.1.0/24" 是有效的
/// 返回 true 如果CIDR有效，否则返回 false
bool isValidCIDR(String cidr) {
  final cidrPattern = RegExp(
    r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/(3[0-2]|[12]?[0-9])$',
  );

  if (!cidrPattern.hasMatch(cidr)) {
    return false;
  }

  // 额外验证网络地址有效性
  final parts = cidr.split('/');
  final ip = parts[0];
  final mask = int.parse(parts[1]);

  return isValidIpAddress(ip) && mask >= 0 && mask <= 32;
}
