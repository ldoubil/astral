import 'package:signals_flutter/signals_flutter.dart';

/// 自定义VPN状态
class VpnState {
  // 自定义VPN网段列表
  final customVpn = signal<List<String>>([]);

  // 状态更新方法
  void setCustomVpn(List<String> list) {
    customVpn.value = list;
  }

  void addCustomVpn(String value) {
    final list = List<String>.from(customVpn.value);
    list.add(value);
    customVpn.value = list;
  }

  void removeCustomVpn(int index) {
    final list = List<String>.from(customVpn.value);
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      customVpn.value = list;
    }
  }
}
