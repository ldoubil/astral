import 'package:signals_flutter/signals_flutter.dart';

/// 通知相关状态
class NotificationState {
  // 是否已显示轮播图提示
  final hasShownBannerTip = signal(false);

  // 状态更新方法
  void setHasShownBannerTip(bool value) {
    hasShownBannerTip.value = value;
  }
}
