import 'package:flutter/material.dart';

/// 导航按钮位置
enum NavigationButtonPosition { top, bottom }

/// 导航页面配置（统一配置菜单项和页面内容）
class NavigationPageConfig {
  const NavigationPageConfig({
    required this.id,
    required this.icon,
    required this.selectedIcon,
    required this.tooltip,
    required this.builder,
    this.position = NavigationButtonPosition.top,
  });

  final int id;
  final IconData icon;
  final IconData selectedIcon;
  final String tooltip;
  final WidgetBuilder builder;
  final NavigationButtonPosition position;
}

/// 导航菜单项配置（向后兼容）
@Deprecated('使用 NavigationPageConfig 替代')
class NavigationMenuItem {
  const NavigationMenuItem({
    required this.id,
    required this.icon,
    required this.selectedIcon,
    required this.tooltip,
  });

  final int id;
  final IconData icon;
  final IconData selectedIcon;
  final String tooltip;
}

/// 导航侧边栏组件
class NavigationSidebar extends StatefulWidget {
  const NavigationSidebar({
    super.key,
    required this.currentIndex,
    required this.onPageChanged,
    this.menuItems,
    this.pageConfigs,
    this.theme,
  }) : assert(
         (menuItems != null) != (pageConfigs != null),
         '必须提供 menuItems 或 pageConfigs 之一',
       );

  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  @Deprecated('使用 pageConfigs 替代')
  final List<NavigationMenuItem>? menuItems;
  final List<NavigationPageConfig>? pageConfigs;
  final ThemeData? theme;

  @override
  State<NavigationSidebar> createState() => _NavigationSidebarState();
}

class _NavigationSidebarState extends State<NavigationSidebar> {
  final Map<int, GlobalKey> _buttonKeys = {};

  List<NavigationPageConfig> get _effectiveConfigs {
    if (widget.pageConfigs != null) {
      return widget.pageConfigs!;
    }
    // 向后兼容：从 menuItems 转换为 pageConfigs
    return widget.menuItems!.map((item) {
      return NavigationPageConfig(
        id: item.id,
        icon: item.icon,
        selectedIcon: item.selectedIcon,
        tooltip: item.tooltip,
        builder: (_) => const SizedBox.shrink(), // 占位
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    // 为每个按钮创建 GlobalKey
    for (final config in _effectiveConfigs) {
      _buttonKeys[config.id] = GlobalKey();
    }
  }

  @override
  void didUpdateWidget(NavigationSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果配置变化，更新 keys
    if (oldWidget.pageConfigs != widget.pageConfigs ||
        oldWidget.menuItems != widget.menuItems) {
      _buttonKeys.clear();
      for (final config in _effectiveConfigs) {
        _buttonKeys[config.id] = GlobalKey();
      }
    }
  }

  /// 获取顶部按钮配置
  List<NavigationPageConfig> get _topConfigs {
    return _effectiveConfigs
        .where((config) => config.position == NavigationButtonPosition.top)
        .toList();
  }

  /// 获取底部按钮配置
  List<NavigationPageConfig> get _bottomConfigs {
    return _effectiveConfigs
        .where((config) => config.position == NavigationButtonPosition.bottom)
        .toList();
  }

  /// 计算指示器的位置
  double _calculateIndicatorTop(BoxConstraints constraints) {
    final topConfigs = _topConfigs;
    final bottomConfigs = _bottomConfigs;

    // 检查当前选中的是顶部还是底部按钮
    final topIndex = topConfigs.indexWhere((c) => c.id == widget.currentIndex);
    if (topIndex != -1) {
      return topIndex * (_navItemSize + _navItemSpacing);
    }

    // 如果是底部按钮，需要从容器底部向上计算位置
    final bottomIndex = bottomConfigs.indexWhere(
      (c) => c.id == widget.currentIndex,
    );
    if (bottomIndex != -1) {
      // 尝试使用 GlobalKey 获取实际位置
      final key = _buttonKeys[widget.currentIndex];
      if (key?.currentContext != null) {
        final RenderBox? box =
            key!.currentContext!.findRenderObject() as RenderBox?;
        if (box != null) {
          // 获取按钮相对于 Stack 的位置
          final buttonPosition = box.localToGlobal(Offset.zero);
          final stackBox = context.findRenderObject() as RenderBox?;
          if (stackBox != null) {
            final stackPosition = stackBox.localToGlobal(Offset.zero);
            return buttonPosition.dy - stackPosition.dy;
          }
        }
      }

      // 回退到计算方式：LayoutBuilder 的 constraints 已经是相对于 Padding 内部的
      final containerHeight = constraints.maxHeight;
      // 底部按钮从底部向上排列，最后一个按钮紧贴底部
      // 调整计算：从底部开始计算，最后一个按钮在 containerHeight - _navItemSize
      final reverseIndex = bottomConfigs.length - 1 - bottomIndex;
      return containerHeight -
          _navItemSize -
          reverseIndex * (_navItemSize + _navItemSpacing);
    }

    return 0;
  }

  static const double _navItemSize = 56;
  static const double _navItemSpacing = 12;
  static const double _navPadding = 16;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: _navPadding,
          horizontal: 10,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.fastOutSlowIn,
                  top: _calculateIndicatorTop(constraints),
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: _NavIndicator(size: _navItemSize, theme: theme),
                  ),
                ),
                Column(
                  children: [
                    // 顶部按钮
                    for (int i = 0; i < _topConfigs.length; i++) ...[
                      Align(
                        alignment: Alignment.center,
                        child: _NavButton(
                          key: _buttonKeys[_topConfigs[i].id],
                          config: _topConfigs[i],
                          isSelected: widget.currentIndex == _topConfigs[i].id,
                          onTap: () => widget.onPageChanged(_topConfigs[i].id),
                          theme: theme,
                          size: _navItemSize,
                        ),
                      ),
                      if (i != _topConfigs.length - 1)
                        const SizedBox(height: _navItemSpacing),
                    ],
                    // 中间弹性空间
                    const Spacer(),
                    // 底部按钮
                    for (int i = 0; i < _bottomConfigs.length; i++) ...[
                      if (i > 0) const SizedBox(height: _navItemSpacing),
                      Align(
                        alignment: Alignment.center,
                        child: _NavButton(
                          key: _buttonKeys[_bottomConfigs[i].id],
                          config: _bottomConfigs[i],
                          isSelected:
                              widget.currentIndex == _bottomConfigs[i].id,
                          onTap:
                              () => widget.onPageChanged(_bottomConfigs[i].id),
                          theme: theme,
                          size: _navItemSize,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 导航指示器
class _NavIndicator extends StatelessWidget {
  const _NavIndicator({required this.size, required this.theme});

  final double size;
  final ThemeData theme;

  static const double _borderWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    // 确保指示器大小与按钮完全一致，包括圆角
    final borderRadius = BorderRadius.circular(size / 2);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.15),
        borderRadius: borderRadius,
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.25),
          width: _borderWidth,
        ),
      ),
    );
  }
}

/// 导航按钮
class _NavButton extends StatefulWidget {
  const _NavButton({
    super.key,
    required this.config,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    required this.size,
  });

  final NavigationPageConfig config;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;
  final double size;

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  @override
  Widget build(BuildContext context) {
    final iconColor =
        widget.isSelected
            ? widget.theme.colorScheme.primary
            : widget.theme.colorScheme.onSurfaceVariant;

    // 确保按钮的圆角与指示器完全一致
    final borderRadius = BorderRadius.circular(widget.size / 2);

    return Tooltip(
      message: widget.config.tooltip,
      child: MouseRegion(
        child: ClipRRect(
          borderRadius: borderRadius,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: borderRadius,
                splashColor: widget.theme.colorScheme.primary.withOpacity(0.15),
                hoverColor: widget.theme.colorScheme.primary.withOpacity(0.1),
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: Center(
                    child: Icon(
                      widget.isSelected
                          ? widget.config.selectedIcon
                          : widget.config.icon,
                      size: 24,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
