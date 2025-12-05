import 'package:astral/utils/reg.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:astral/k/app_s/aps.dart';

class WindowManagerUtils {
  static Future<void> initializeWindow() async {
    // 检查当前平台是否为 Windows、MacOS 或 Linux
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux ) {
      // 确保窗口管理器已初始化
      await windowManager.ensureInitialized();
      //添加信号监听
      // 创建响应式效果，用于监听和更新窗口标题
      effect(() {
        // 设置窗口标题为当前应用名称
        windowManager.setTitle(Aps().appName.value);
      });
      // 定义窗口选项配置
      final windowOptions = WindowOptions(
        size: Size(960, 540),
        // 设置窗口最小大小为 300x300
        minimumSize: Size(200, 300),
        // 设置窗口居中显示
        center: true,
        // 设置窗口标题
        title: Aps().appName.value,
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
        if (Aps().startupMinimize.value) {
          await windowManager.hide();
        } else {
          await windowManager.show();
          await windowManager.focus();
        }
      });

      // Windows平台：验证并修复计划任务路径
      if (Platform.isWindows) {
        try {
          // 无论启动设置是否启用，都验证计划任务路径
          // 如果计划任务存在但路径不匹配，自动更新
          await verifyAndFixStartupTask();
        } catch (e) {
          if (kDebugMode) {
            debugPrint('验证计划任务路径失败: $e');
          }
        }
        
        // 启动时同步计划任务状态（如果设置已启用）
        if (Aps().startup.value) {
          try {
            await handleStartupSetting(true);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('初始化时设置开机自启失败: $e');
            }
          }
        }
      }
    }
  }
}
