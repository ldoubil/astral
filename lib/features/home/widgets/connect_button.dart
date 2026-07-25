import 'dart:async';

import 'package:astral/core/services/connection_connect_guard.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/states/connection_state.dart';
import 'package:astral/core/ui/app_snack_bars.dart';
import 'package:astral/core/ui/main_tab.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:astral/features/home/widgets/connect_button_style.dart';
import 'package:astral/features/home/widgets/connect_npcap_guard.dart';

class ConnectButton extends StatefulWidget {
  const ConnectButton({super.key});

  @override
  State<ConnectButton> createState() => _ConnectButtonState();
}

class _ConnectButtonState extends State<ConnectButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 处理连接请求
  Future<void> _handleConnect() async {
    final targetIssue = ConnectionConnectGuard.connectTargetIssue();
    if (targetIssue != null) {
      if (!mounted) return;
      final (title, actionLabel, icon, tab) = switch (targetIssue) {
        ConnectTargetIssue.noRoom => (
          LocaleKeys.select_room_first.tr(),
          LocaleKeys.go_select_room.tr(),
          Icons.meeting_room_outlined,
          MainTab.room,
        ),
        ConnectTargetIssue.noneEnabled => (
          LocaleKeys.enable_server_first.tr(),
          LocaleKeys.go_enable.tr(),
          Icons.toggle_on_outlined,
          MainTab.servers,
        ),
        ConnectTargetIssue.noServers => (
          LocaleKeys.add_server_first.tr(),
          LocaleKeys.go_add.tr(),
          Icons.dns_outlined,
          MainTab.servers,
        ),
      };
      AppSnackBars.show(
        context,
        title: title,
        message: '',
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        icon: icon,
        action: SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          onPressed: () => ServiceManager().uiState.goTo(tab),
        ),
      );
      return;
    }

    if (!await ConnectionConnectGuard.isNpcapReady()) {
      if (!mounted) return;
      final shouldOpenTutorial = await showNpcapRequiredDialog(context);
      if (shouldOpenTutorial == true && mounted) {
        await openNpcapTutorial(context);
      }
      return;
    }

    final success = await ServiceManager().connection.connect(isManual: true);

    if (success == false && mounted) {
      AppSnackBars.error(context, '连接失败', '请检查网络后重试，并确认房间与服务器配置无误');
    }
  }

  /// 处理断开连接
  Future<void> _handleDisconnect() async {
    await ServiceManager().connection.disconnect();
  }

  /// 切换连接状态
  Future<void> _toggleConnection() async {
    final state = ServiceManager().connectionState.connectionState.value;
    if (state == CoState.idle) {
      await _handleConnect();
    } else if (state == CoState.connecting) {
      // 连接中时，点击可以取消
      await ServiceManager().connection.cancelConnection();
    } else if (state == CoState.connected) {
      await _handleDisconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 使用 Watch widget 包裹整个内容，监听状态变化
    return RepaintBoundary(
      child: Watch((context) {
        final connectionState = ServiceManager().connectionState.connectionState
            .watch(context);

        // 仅在连接中时播放动画，其他状态停止
        if (connectionState == CoState.connecting) {
          if (!_animationController.isAnimating) {
            _animationController.repeat(reverse: true);
          }
        } else {
          if (_animationController.isAnimating) {
            _animationController.stop();
            _animationController.reset();
          }
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: 14, // 固定高度，包含进度条高度(6px)和底部边距(8px)
                width: 180, // 固定宽度与按钮一致
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 300),
                  offset:
                      connectionState == CoState.connecting
                          ? Offset.zero
                          : const Offset(0, 1.0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: connectionState == CoState.connecting ? 1.0 : 0.0,
                    child: Container(
                      width: 180,
                      height: 6,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey(
                          'progress_${connectionState == CoState.connecting}',
                        ),
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(seconds: 15), // 连接超时时间
                        curve: Curves.easeInOut,
                        builder: (context, value, _) {
                          return FractionallySizedBox(
                            widthFactor: value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.tertiary,
                                    colorScheme.primary,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              // 按钮
              Align(
                alignment: Alignment.centerRight,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: connectionState != CoState.idle ? 180 : 100,
                  height: 60,
                  child: FloatingActionButton.extended(
                    onPressed: _toggleConnection, // 所有状态都可以点击
                    heroTag: "connect_button",
                    extendedPadding: const EdgeInsets.symmetric(horizontal: 2),
                    splashColor:
                        connectionState != CoState.idle
                            ? colorScheme.onTertiary.withAlpha(51)
                            : colorScheme.onPrimary.withAlpha(51),
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                      ) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                          // 这两个组件组合在一起会导致Impeller崩溃
                          // child: ScaleTransition(
                          //   scale: animation,
                          //   child: child,
                          // ),
                        );
                      },
                      child: connectButtonIcon(
                        connectionState,
                        _animationController,
                      ),
                    ),
                    label: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOutQuad,
                      switchOutCurve: Curves.easeInQuad,
                      child: connectButtonLabel(connectionState),
                    ),
                    backgroundColor: connectButtonColor(
                      connectionState,
                      colorScheme,
                    ),
                    foregroundColor: connectButtonForegroundColor(
                      connectionState,
                      colorScheme,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
