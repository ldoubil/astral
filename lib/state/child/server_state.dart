import 'package:astral/models/server_node.dart';
import 'package:hive/hive.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ServerState {
  // 使用 Signal 管理服务器节点列表，初始为空列表
  late Signal<List<ServerNode>> serverNodes;

  ServerState() {
    // 初始化信号，避免 LateInitializationError
    serverNodes = signal<List<ServerNode>>([]);
    loadServerNodes();
  }

  // 以下为操作方法
  /// 添加服务器节点
  void addServerNode(ServerNode node) {
    // 数据库写入
    Hive.box<ServerNode>('ServerNodes').add(node);
    // 通过赋值新列表触发信号刷新
    serverNodes.value = [...serverNodes.value, node];
  }
  
  /// 删除服务器节点 - 使用id进行精确删除
  void removeServerNode(String nodeId) {
    final box = Hive.box<ServerNode>('ServerNodes');
    
    // 从数据库中删除：使用key进行删除
    final keys = box.keys.toList();
    for (final key in keys) {
      final node = box.get(key);
      if (node?.id == nodeId) {
        box.delete(key);
        break;
      }
    }

    // 从内存列表中删除并触发信号刷新
    serverNodes.value = serverNodes.value.where((node) => node.id != nodeId).toList();
  }

  /// 更新服务器节点 - 使用id进行精确匹配
  void updateServerNode(ServerNode updatedNode) {
    final box = Hive.box<ServerNode>('ServerNodes');
    
    // 更新数据库中的节点
    final keys = box.keys.toList();
    for (final key in keys) {
      final node = box.get(key);
      if (node?.id == updatedNode.id) {
        box.put(key, updatedNode);
        break;
      }
    }

    // 更新内存中的节点并触发信号刷新
    serverNodes.value = serverNodes.value
        .map((node) => node.id == updatedNode.id ? updatedNode : node)
        .toList();
  }

  /// 清空所有服务器节点
  void clearServerNodes() {
    final box = Hive.box<ServerNode>('ServerNodes');
    
    // 清空数据库
    box.clear();

    // 清空内存列表并触发信号刷新
    serverNodes.value = [];
  }

  /// 从数据库中加载所有服务器节点
  void loadServerNodes() {
    final box = Hive.box<ServerNode>('ServerNodes');
    serverNodes.value = box.values.toList();
  }
}