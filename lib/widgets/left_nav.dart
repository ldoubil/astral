import 'package:astral/k/app_s/aps.dart';
import 'package:astral/k/navigtion.dart';
import 'package:flutter/material.dart';

class LeftNav extends StatelessWidget {
  final List<NavigationItem> items;
  final ColorScheme colorScheme;
  final PageController? pageController;

  const LeftNav({
    super.key,
    required this.items,
    required this.colorScheme,
    this.pageController,
  });

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
      final isSelected = Aps().selectedIndex.watch(context) == index;
      return MouseRegion(
        onEnter: (_) => Aps().hoveredIndex.set(index),
        onExit: (_) => Aps().hoveredIndex.set(null),
        child: Container(
          height: 64,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (Aps().selectedIndex.watch(context) != index) {
                if (pageController != null) {
                  pageController!.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                  );
                } else {
                  Aps().selectedIndex.set(index);
                }
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
                begin: 4.0 + (Aps().selectedIndex.watch(context) * 72.0),
                end: 4.0 + (Aps().selectedIndex.watch(context) * 72.0),
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
            if (Aps().hoveredIndex.watch(context) != null &&
                Aps().hoveredIndex.watch(context) !=
                    Aps().selectedIndex.watch(context))
              Positioned(
                top: 4.0 + (Aps().hoveredIndex.watch(context)! * 72.0),
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
