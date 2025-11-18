import 'dart:convert';
import 'package:astral/models/room_info.dart';
import 'package:astral/models/server_node.dart';
import 'package:astral/models/base.dart';
import 'package:uuid/uuid.dart';

/// 房间导出工具类
/// 用于将房间信息转换为 JSON 格式
class RoomExport {
  /// 将房间信息转换为 JSON 字符串
  ///
  /// 返回的 JSON 包含以下字段：
  /// - name: 房间名称
  /// - uuid: 房间唯一标识符
  /// - servers: 服务器节点列表
  ///
  /// 每个服务器节点包含：
  /// - id: 服务器节点唯一标识符
  /// - host: 服务器节点地址
  /// - port: 服务器节点端口
  /// - protocolSwitch: 服务器协议类型（字符串形式）
  static String toJson(RoomInfo room) {
    final Map<String, dynamic> json = {
      'name': room.name,
      'uuid': room.uuid,
      'servers':
          room.servers
              .map(
                (server) => {
                  'id': server.id,
                  'host': server.host,
                  'port': server.port,
                  'protocolSwitch': _protocolSwitchToString(
                    server.protocolSwitch,
                  ),
                },
              )
              .toList(),
    };

    // 使用 JsonEncoder 格式化输出，indent 为 2 个空格
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }

  /// 从 JSON 字符串创建房间信息
  ///
  /// [jsonString] 房间信息的 JSON 字符串
  /// 返回解析后的 RoomInfo 对象，如果解析失败则返回 null
  static RoomInfo? fromJson(String jsonString) {
    try {
      final Map<String, dynamic> json =
          jsonDecode(jsonString) as Map<String, dynamic>;

      final room = RoomInfo();
      room.name = json['name'] as String? ?? '';
      room.uuid = json['uuid'] as String? ?? const Uuid().v4();

      // 解析服务器列表
      final serversList = json['servers'] as List<dynamic>? ?? [];
      room.servers =
          serversList.map((serverJson) {
            final server = ServerNode();
            server.id = (serverJson['id'] as String?) ?? const Uuid().v4();
            server.host = serverJson['host'] as String? ?? '';
            server.port = (serverJson['port'] as num?)?.toInt() ?? 0;
            server.protocolSwitch = _stringToProtocolSwitch(
              serverJson['protocolSwitch'] as String? ?? 'tcp',
            );
            return server;
          }).toList();

      return room;
    } catch (e) {
      return null;
    }
  }

  /// 将协议枚举转换为字符串
  static String _protocolSwitchToString(ServerProtocolSwitch protocol) {
    switch (protocol) {
      case ServerProtocolSwitch.tcp:
        return 'tcp';
      case ServerProtocolSwitch.udp:
        return 'udp';
      case ServerProtocolSwitch.ws:
        return 'ws';
      case ServerProtocolSwitch.wss:
        return 'wss';
      case ServerProtocolSwitch.quic:
        return 'quic';
      case ServerProtocolSwitch.wg:
        return 'wg';
      case ServerProtocolSwitch.txt:
        return 'txt';
      case ServerProtocolSwitch.srv:
        return 'srv';
      case ServerProtocolSwitch.http:
        return 'http';
      case ServerProtocolSwitch.https:
        return 'https';
    }
  }

  /// 将字符串转换为协议枚举
  static ServerProtocolSwitch _stringToProtocolSwitch(String protocol) {
    switch (protocol.toLowerCase()) {
      case 'tcp':
        return ServerProtocolSwitch.tcp;
      case 'udp':
        return ServerProtocolSwitch.udp;
      case 'ws':
        return ServerProtocolSwitch.ws;
      case 'wss':
        return ServerProtocolSwitch.wss;
      case 'quic':
        return ServerProtocolSwitch.quic;
      case 'wg':
        return ServerProtocolSwitch.wg;
      case 'txt':
        return ServerProtocolSwitch.txt;
      case 'srv':
        return ServerProtocolSwitch.srv;
      case 'http':
        return ServerProtocolSwitch.http;
      case 'https':
        return ServerProtocolSwitch.https;
      default:
        return ServerProtocolSwitch.tcp;
    }
  }
}
