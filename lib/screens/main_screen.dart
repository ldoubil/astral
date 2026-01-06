// 导入所需的包
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/constants/small_window_adapter.dart'; // 导入小窗口适配器
import 'package:astral/features/home/pages/home_page.dart';
import 'package:astral/shared/widgets/common/status_bar.dart';
import 'package:flutter/material.dart';

// 主屏幕Widget，使用StatefulWidget以管理状态
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// MainScreen的状态管理类
class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 监听屏幕等状态变化
    // 在第一帧渲染完成后获取屏幕宽度并更新分割宽度
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      ServiceManager().uiState.updateScreenSplitWidth(screenWidth);
    });
  }

  // 组件销毁时移除观察者
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 屏幕尺寸变化时的回调
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // 确保context可用
    if (!mounted) return;

    // 屏幕尺寸变化时更新
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // 记录小窗口状态变化
    bool isSmallWindow = screenWidth < 300 || screenHeight < 400;
    print(
      'Screen size changed: $screenWidth x $screenHeight, isSmallWindow: $isSmallWindow',
    );

    // 更新分割宽度
    ServiceManager().uiState.updateScreenSplitWidth(screenWidth);

    // 强制刷新UI以适应新的尺寸
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallWindow = SmallWindowAdapter.shouldApplyAdapter(context);

    // 直接显示首页，不需要导航
    return Scaffold(
      appBar: isSmallWindow ? null : StatusBar(),
      body: const HomePage(),
    );
  }
}
