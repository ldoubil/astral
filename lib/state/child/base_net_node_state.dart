import 'package:astral/models/net_node.dart';
import 'package:hive/hive.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// 基础网络节点状态管理类
/// 
/// 提供网络节点配置的响应式状态管理和持久化存储功能。
/// 使用单一NetNode实例管理所有配置，支持自动保存功能。
/// 当NetNode的任何属性发生变化时，会自动触发持久化存储。
class BaseNetNodeState {
  /// 网络节点配置信号
  /// 包含所有网络节点的配置信息
  late final Signal<NetNode> netNode;

  BaseNetNodeState() {
    _initializeNetNode();
    loadConfiguration();
  }

  /// 初始化NetNode信号并添加监听器
  void _initializeNetNode() {
    // 创建默认的NetNode实例
    netNode = signal(NetNode());
    
    // 使用effect监听NetNode变化，实现自动保存
    effect(() {
      // 直接保存，无需防抖处理
      saveConfiguration();
    });
  }

  /* ------------------------ 辅助方法 ------------------------ */

  /// 更新NetNode实例
  /// [newNetNode] 新的NetNode对象
  void updateNetNode(NetNode newNetNode) {
    // 临时禁用自动保存，避免更新时触发保存
    netNode.value = newNetNode;
  }

  /// 获取当前NetNode实例的副本
  NetNode getCurrentNetNode() {
    return netNode.value;
  }

  /// 修改NetNode的特定字段
  /// 这个方法会创建一个新的NetNode实例来触发Signal更新
  void updateField<T>(T Function(NetNode) getter, void Function(NetNode, T) setter, T newValue) {
    final currentNode = netNode.value;
    final newNode = NetNode();
    
    // 复制所有字段
    _copyNetNodeFields(currentNode, newNode);
    
    // 更新指定字段
    setter(newNode, newValue);
    
    // 更新Signal
    netNode.value = newNode;
  }

  /// 复制NetNode的所有字段
  void _copyNetNodeFields(NetNode source, NetNode target) {
    target.id = source.id;
    target.netns = source.netns;
    target.hostname = source.hostname;
    target.instance_name = source.instance_name;
    target.ipv4 = source.ipv4;
    target.dhcp = source.dhcp;
    target.network_name = source.network_name;
    target.network_secret = source.network_secret;
    target.listeners = List.from(source.listeners);
    target.peer = List.from(source.peer);
    target.cidrproxy = List.from(source.cidrproxy);
    target.connectionManagers = List.from(source.connectionManagers);
    target.default_protocol = source.default_protocol;
    target.dev_name = source.dev_name;
    target.enable_encryption = source.enable_encryption;
    target.enable_ipv6 = source.enable_ipv6;
    target.mtu = source.mtu;
    target.latency_first = source.latency_first;
    target.enable_exit_node = source.enable_exit_node;
    target.no_tun = source.no_tun;
    target.use_smoltcp = source.use_smoltcp;
    target.relay_network_whitelist = source.relay_network_whitelist;
    target.disable_p2p = source.disable_p2p;
    target.relay_all_peer_rpc = source.relay_all_peer_rpc;
    target.disable_udp_hole_punching = source.disable_udp_hole_punching;
    target.multi_thread = source.multi_thread;
    target.data_compress_algo = source.data_compress_algo;
    target.bind_device = source.bind_device;
    target.enable_kcp_proxy = source.enable_kcp_proxy;
    target.disable_kcp_input = source.disable_kcp_input;
    target.disable_relay_kcp = source.disable_relay_kcp;
    target.proxy_forward_by_system = source.proxy_forward_by_system;
    target.accept_dns = source.accept_dns;
    target.private_mode = source.private_mode;
    target.enable_quic_proxy = source.enable_quic_proxy;
    target.disable_quic_input = source.disable_quic_input;
  }

  /// 重置所有状态为默认值
  /// 使用NetNode模型中定义的默认值
  void reset() {
    final defaultNode = NetNode();
    updateNetNode(defaultNode);
  }

  /// 复制当前状态到另一个BaseNetNodeState实例
  /// [other] 目标状态实例
  void copyTo(BaseNetNodeState other) {
    other.updateNetNode(getCurrentNetNode());
  }

  /// 验证当前配置是否有效
  /// 返回验证结果和错误信息
  Map<String, dynamic> validate() {
    final errors = <String>[];
    final currentNode = netNode.value;
    
    if (currentNode.network_name.isEmpty) {
      errors.add('网络名称不能为空');
    }
    
    if (currentNode.instance_name.isEmpty) {
      errors.add('实例名称不能为空');
    }
    
    if (currentNode.mtu < 576 || currentNode.mtu > 9000) {
      errors.add('MTU值必须在576-9000之间');
    }
    
    if (currentNode.listeners.isEmpty) {
      errors.add('至少需要配置一个监听地址');
    }
    
    return {
      'isValid': errors.isEmpty,
      'errors': errors,
    };
  }

  /* ------------------------ 持久化存储方法 ------------------------ */

  /// 保存当前配置到Hive数据库
  void saveConfiguration() {
    final box = Hive.box<NetNode>('BaseNetNodeConfig');
    final currentConfig = getCurrentNetNode();
    box.put('current_config', currentConfig);
  }

  /// 从Hive数据库加载配置
  void loadConfiguration() {
    final box = Hive.box<NetNode>('BaseNetNodeConfig');
    final savedConfig = box.get('current_config');
    if (savedConfig != null) {
      updateNetNode(savedConfig);
    }
  }

  /// 清空保存的配置
  void clearConfiguration() {
    final box = Hive.box<NetNode>('BaseNetNodeConfig');
    box.clear();
    reset();
  }

  /// 检查是否有保存的配置
  bool hasSavedConfiguration() {
    final box = Hive.box<NetNode>('BaseNetNodeConfig');
    return box.containsKey('current_config');
  }

  /// 释放资源
  void dispose() {
    // 无需清理定时器，因为已移除_saveTimer
  }
}