import 'package:astral/src/rust/api/simple.dart';

/// 判断节点是否为公共服务器节点。
bool isServerNode(KVNodeInfo node) {
  return node.hostname.startsWith('PublicServer_') || node.ipv4 == '0.0.0.0';
}

/// 获取节点的显示名称（去除 PublicServer_ 前缀）。
String normalizeNodeName(String hostname) {
  return hostname.startsWith('PublicServer_')
      ? hostname.substring('PublicServer_'.length)
      : hostname;
}
