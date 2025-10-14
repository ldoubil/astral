import 'package:astral/state/app_state.dart';
import 'package:astral/utils/reg.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:flutter/material.dart';

class WindowManagerUtils {
  static Future<void> initializeWindow() async {
    // 检查当前平台是否为 Windows、MacOS 或 Linux
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // 确保窗口管理器已初始化
      await windowManager.ensureInitialized();
      //添加信号监听
      // 创建响应式效果，用于监听和更新窗口标题
      effect(() {
        // 设置窗口标题为当前应用名称
        windowManager.setTitle(AppState().baseState.appName.value);
      });
      // 定义窗口选项配置
      final windowOptions = WindowOptions(
        size: Size(960, 540),
        // 设置窗口最小大小为 300x300
        minimumSize: Size(200, 300),
        // 设置窗口居中显示
        center: true,
        // 设置窗口标题
        title: AppState().baseState.appName.value,
        // 设置标题栏样式为隐藏
        titleBarStyle: TitleBarStyle.hidden,
        // 设置窗口背景为透明
        backgroundColor: Colors.transparent,
        // 设置是否在任务栏显示
        skipTaskbar: false,
      );

      // 等待窗口准备就绪并显示
      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        // 如果 startupMinimize 为 true，则最小化窗口
        if (AppState().startupState.startupMinimize.value) {
          await windowManager.hide();
        } else {
          await windowManager.show();
          await windowManager.focus();
        }
      });

      if (AppState().startupState.startup.value) {
        handleStartupSetting(true);
      }
    }
  }
}
