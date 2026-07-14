import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/ui/navigation.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class LeftNav extends StatefulWidget {
  final List<NavigationItem> items;
  final ColorScheme colorScheme;

  const LeftNav({super.key, required this.items, required this.colorScheme});

  @override
  State<LeftNav> createState() => _LeftNavState();
}

class _LeftNavState extends State<LeftNav> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _currentIndex = 0;
  int _targetIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _currentIndex = ServiceManager().uiState.selectedIndex.value;
    _targetIndex = _currentIndex;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateAnimation(int newIndex) {
    if (_targetIndex != newIndex) {
      setState(() {
        _currentIndex = _targetIndex;
        _targetIndex = newIndex;
      });
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final selectedIndex = ServiceManager().uiState.selectedIndex.watch(
        context,
      );
      final hoveredIndex = ServiceManager().uiState.hoveredIndex.watch(context);
      final colorScheme = widget.colorScheme;

      if (selectedIndex != _targetIndex) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _updateAnimation(selectedIndex);
        });
      }

      Widget buildNavItem(int index, NavigationItem item) {
        final isSelected = selectedIndex == index;
        return RepaintBoundary(
          child: MouseRegion(
            onEnter: (_) => ServiceManager().uiState.hoveredIndex.value = index,
            onExit: (_) => ServiceManager().uiState.hoveredIndex.value = null,
            child: Container(
              height: 64,
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (selectedIndex != index) {
                    ServiceManager().uiState.selectedIndex.value = index;
                  }
                },
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 100),
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
                          duration: const Duration(milliseconds: 100),
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
          ),
        );
      }

      return Container(
        width: 80,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            right: BorderSide(color: colorScheme.outline, width: 1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Stack(
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final startPosition = 4.0 + (_currentIndex * 72.0);
                  final endPosition = 4.0 + (_targetIndex * 72.0);
                  final currentPosition =
                      startPosition +
                      (endPosition - startPosition) * _animation.value;

                  return Positioned(
                    top: currentPosition,
                    left: 8,
                    right: 8,
                    height: 64,
                    child: RepaintBoundary(
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (hoveredIndex != null && hoveredIndex != selectedIndex)
                Positioned(
                  top: 4.0 + (hoveredIndex * 72.0),
                  left: 8,
                  right: 8,
                  height: 64,
                  child: RepaintBoundary(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        return buildNavItem(index, widget.items[index]);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
