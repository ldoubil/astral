import 'package:astral/k/navigtion.dart';
import 'package:astral/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class LeftNav extends StatelessWidget {
  final List<NavigationItem> items;
  final ColorScheme colorScheme;

  const LeftNav({super.key, required this.items, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    // 修改导航项构建方法
    Widget buildNavItem(
      IconData icon,
      String label,
      int index,
      ColorScheme colorScheme,
      dynamic item,
    ) {
      final isSelected = AppState().baseState.selectedIndex.watch(context) == index;
      return MouseRegion(
        onEnter: (_) => AppState().baseState.hoveredIndex.set(index),
        onExit: (_) => AppState().baseState.hoveredIndex.set(null),
        child: Container(
          height: 64,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (AppState().baseState.selectedIndex.watch(context) != index) {
                AppState().baseState.selectedIndex.set(index);
              }
            },
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color:
                            isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                        size: 24,
                        key: ValueKey(isSelected),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(item.label),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(right: BorderSide(color: colorScheme.outline, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 14), // 新增顶部14像素间距
        child: Stack(
          children: [
            // 添加滑动指示器
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(
                begin: 4.0 + (AppState().baseState.selectedIndex.watch(context) * 72.0),
                end: 4.0 + (AppState().baseState.selectedIndex.watch(context) * 72.0),
              ),
              builder: (context, value, child) {
                return Positioned(
                  top: value,
                  left: 8,
                  right: 8,
                  height: 64,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ), //
            // 鼠标悬停指示器
            if (AppState().baseState.hoveredIndex.watch(context) != null &&
                AppState().baseState.hoveredIndex.watch(context) !=
                    AppState().baseState.selectedIndex.watch(context))
              Positioned(
                top: 4.0 + (AppState().baseState.hoveredIndex.watch(context)! * 72.0),
                left: 8,
                right: 8,
                height: 64,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            // 导航项列表
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return buildNavItem(
                        item.icon,
                        item.label,
                        index,
                        colorScheme,
                        item,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
