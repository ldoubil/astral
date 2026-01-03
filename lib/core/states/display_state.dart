import 'package:signals_flutter/signals_flutter.dart';

/// 显示相关状态（排序、显示模式等）
class DisplayState {
  // 排序选项 (0: 不排序, 1: 按延迟排序, 2: 按用户名长度排序)
  final sortOption = signal(0);

  // 排序顺序 (0: 升序, 1: 降序)
  final sortOrder = signal(0);

  // 显示模式 (0: 默认, 1: 仅用户, 2: 仅服务器)
  final displayMode = signal(0);

  // 用户列表简化模式
  final userListSimple = signal(false);

  // 状态更新方法
  void setSortOption(int option) {
    sortOption.value = option;
  }

  void setSortOrder(int order) {
    sortOrder.value = order;
  }

  void setDisplayMode(int mode) {
    displayMode.value = mode;
  }

  void setUserListSimple(bool value) {
    userListSimple.value = value;
  }

  void toggleSortOrder() {
    sortOrder.value = sortOrder.value == 0 ? 1 : 0;
  }

  // Computed Signal 示例
  late final isSorted = computed(() => sortOption.value != 0);
  late final isAscending = computed(() => sortOrder.value == 0);
}
