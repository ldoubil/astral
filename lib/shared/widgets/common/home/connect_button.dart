import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/services/server_connection_manager.dart';
import 'package:astral/core/services/notification_service.dart';
import 'package:astral/core/services/vpn_manager.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ConnectButton extends StatefulWidget {
  const ConnectButton({super.key});

  @override
  State<ConnectButton> createState() => _ConnectButtonState();
}

class _ConnectButtonState extends State<ConnectButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // 初始化服务
    if (Platform.isAndroid) {
      NotificationService.instance.initialize();

      // 监听VPN事件
      VpnManager.instance.plugin?.onVpnServiceStarted.listen((data) {
        VpnManager.instance.configureTunFd(data['fd']);
      });
    }

    // 自动连接
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ServiceManager().startupState.startupAutoConnect.value) {
        _handleConnect();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 处理连接请求
  Future<void> _handleConnect() async {
    final rom = ServiceManager().roomState.selectedRoom.value;
    if (rom == null) return;

    // 检查服务器配置
    final enabledServers =
        ServiceManager().serverState.servers.value
            .where((server) => server.enable)
            .toList();
    final hasRoomServers = rom.servers.isNotEmpty;

    if (enabledServers.isEmpty && !hasRoomServers) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.add_server_first.tr()),
            action: SnackBarAction(
              label: LocaleKeys.go_add.tr(),
              onPressed: () {
                ServiceManager().uiState.selectedIndex.set(2);
              },
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // 调用连接管理器
    final success = await ServerConnectionManager.instance.connect();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('连接失败'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 处理断开连接
  Future<void> _handleDisconnect() async {
    await ServerConnectionManager.instance.disconnect();
  }

  /// 切换连接状态
  void _toggleConnection() {
    final state = ServiceManager().connectionState.connectionState.value;
    if (state == CoState.idle) {
      _handleConnect();
    } else if (state == CoState.connected) {
      _handleDisconnect();
    }
  }

  Widget _getButtonIcon(CoState state) {
    switch (state) {
      case CoState.idle:
        return Icon(
          Icons.power_settings_new_rounded,
          key: const ValueKey('idle_icon'),
        );
      case CoState.connecting:
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animationController.value * 2 * pi,
              child: const Icon(
                Icons.sync_rounded,
                key: ValueKey('connecting_icon'),
              ),
            );
          },
        );
      case CoState.connected:
        return Icon(Icons.link_rounded, key: const ValueKey('connected_icon'));
    }
  }

  Widget _getButtonLabel(CoState state) {
    final String text;
    switch (state) {
      case CoState.idle:
        text = '连接';
      case CoState.connecting:
        text = '连接中...';
      case CoState.connected:
        text = '已连接';
    }

    return Text(
      text,
      key: ValueKey('label_$state'),
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
    );
  }

  Color _getButtonColor(CoState state, ColorScheme colorScheme) {
    switch (state) {
      case CoState.idle:
        return colorScheme.primary;
      case CoState.connecting:
        return colorScheme.surfaceVariant;
      case CoState.connected:
        return colorScheme.tertiary;
    }
  }

  Color _getButtonForegroundColor(CoState state, ColorScheme colorScheme) {
    switch (state) {
      case CoState.idle:
        return colorScheme.onPrimary;
      case CoState.connecting:
        return colorScheme.onSurfaceVariant;
      case CoState.connected:
        return colorScheme.onTertiary;
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
                        color: colorScheme.surfaceVariant,
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
                          // 更新进度值
                          _progress = value * 100;
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
                    onPressed:
                        connectionState == CoState.connecting
                            ? null
                            : _toggleConnection,
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
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        );
                      },
                      child: _getButtonIcon(connectionState),
                    ),
                    label: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOutQuad,
                      switchOutCurve: Curves.easeInQuad,
                      child: _getButtonLabel(connectionState),
                    ),
                    backgroundColor: _getButtonColor(
                      connectionState,
                      colorScheme,
                    ),
                    foregroundColor: _getButtonForegroundColor(
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
