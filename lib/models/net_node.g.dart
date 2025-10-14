// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net_node.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NetNodeAdapter extends TypeAdapter<NetNode> {
  @override
  final int typeId = 11;

  @override
  NetNode read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NetNode()
      ..id = fields[0] as int
      ..netns = fields[1] as String
      ..hostname = fields[2] as String
      ..instance_name = fields[3] as String
      ..ipv4 = fields[4] as String
      ..dhcp = fields[5] as bool
      ..network_name = fields[6] as String
      ..network_secret = fields[7] as String
      ..listeners = (fields[8] as List).cast<String>()
      ..peer = (fields[9] as List).cast<String>()
      ..cidrproxy = (fields[10] as List).cast<String>()
      ..connectionManagers = (fields[11] as List).cast<ConnectionManager>()
      ..default_protocol = fields[12] as String
      ..dev_name = fields[13] as String
      ..enable_encryption = fields[14] as bool
      ..enable_ipv6 = fields[15] as bool
      ..mtu = fields[16] as int
      ..latency_first = fields[17] as bool
      ..enable_exit_node = fields[18] as bool
      ..no_tun = fields[19] as bool
      ..use_smoltcp = fields[20] as bool
      ..relay_network_whitelist = fields[21] as String
      ..disable_p2p = fields[22] as bool
      ..relay_all_peer_rpc = fields[23] as bool
      ..disable_udp_hole_punching = fields[24] as bool
      ..multi_thread = fields[25] as bool
      ..data_compress_algo = fields[26] as int
      ..bind_device = fields[27] as bool
      ..enable_kcp_proxy = fields[28] as bool
      ..disable_kcp_input = fields[29] as bool
      ..disable_relay_kcp = fields[30] as bool
      ..proxy_forward_by_system = fields[31] as bool
      ..accept_dns = fields[32] as bool
      ..private_mode = fields[33] as bool
      ..enable_quic_proxy = fields[34] as bool
      ..disable_quic_input = fields[35] as bool;
  }

  @override
  void write(BinaryWriter writer, NetNode obj) {
    writer
      ..writeByte(36)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.netns)
      ..writeByte(2)
      ..write(obj.hostname)
      ..writeByte(3)
      ..write(obj.instance_name)
      ..writeByte(4)
      ..write(obj.ipv4)
      ..writeByte(5)
      ..write(obj.dhcp)
      ..writeByte(6)
      ..write(obj.network_name)
      ..writeByte(7)
      ..write(obj.network_secret)
      ..writeByte(8)
      ..write(obj.listeners)
      ..writeByte(9)
      ..write(obj.peer)
      ..writeByte(10)
      ..write(obj.cidrproxy)
      ..writeByte(11)
      ..write(obj.connectionManagers)
      ..writeByte(12)
      ..write(obj.default_protocol)
      ..writeByte(13)
      ..write(obj.dev_name)
      ..writeByte(14)
      ..write(obj.enable_encryption)
      ..writeByte(15)
      ..write(obj.enable_ipv6)
      ..writeByte(16)
      ..write(obj.mtu)
      ..writeByte(17)
      ..write(obj.latency_first)
      ..writeByte(18)
      ..write(obj.enable_exit_node)
      ..writeByte(19)
      ..write(obj.no_tun)
      ..writeByte(20)
      ..write(obj.use_smoltcp)
      ..writeByte(21)
      ..write(obj.relay_network_whitelist)
      ..writeByte(22)
      ..write(obj.disable_p2p)
      ..writeByte(23)
      ..write(obj.relay_all_peer_rpc)
      ..writeByte(24)
      ..write(obj.disable_udp_hole_punching)
      ..writeByte(25)
      ..write(obj.multi_thread)
      ..writeByte(26)
      ..write(obj.data_compress_algo)
      ..writeByte(27)
      ..write(obj.bind_device)
      ..writeByte(28)
      ..write(obj.enable_kcp_proxy)
      ..writeByte(29)
      ..write(obj.disable_kcp_input)
      ..writeByte(30)
      ..write(obj.disable_relay_kcp)
      ..writeByte(31)
      ..write(obj.proxy_forward_by_system)
      ..writeByte(32)
      ..write(obj.accept_dns)
      ..writeByte(33)
      ..write(obj.private_mode)
      ..writeByte(34)
      ..write(obj.enable_quic_proxy)
      ..writeByte(35)
      ..write(obj.disable_quic_input);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetNodeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
