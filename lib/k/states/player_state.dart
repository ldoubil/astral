import 'package:signals_flutter/signals_flutter.dart';

/// 玩家/用户状态（纯Signal）
class PlayerState {
  // 玩家名称
  final playerName = signal('');

  // 监听列表
  final listenList = signal<List<String>>([]);

  // 用户列表简化显示
  final userListSimple = signal(false);

  // 状态更新方法
  void updatePlayerName(String name) {
    playerName.value = name;
  }

  void setListenList(List<String> list) {
    listenList.value = list;
  }

  void addListen(String listen) {
    final list = List<String>.from(listenList.value);
    list.add(listen);
    listenList.value = list;
  }

  void removeListen(int index) {
    final list = List<String>.from(listenList.value);
    list.removeAt(index);
    listenList.value = list;
  }

  void updateListen(int index, String listen) {
    final list = List<String>.from(listenList.value);
    if (index >= 0 && index < list.length) {
      list[index] = listen;
      listenList.value = list;
    }
  }

  void toggleUserListSimple() {
    userListSimple.value = !userListSimple.value;
  }

  void setUserListSimple(bool value) {
    userListSimple.value = value;
  }
}
