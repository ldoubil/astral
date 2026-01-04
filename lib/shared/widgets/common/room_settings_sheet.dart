import 'package:flutter/material.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:signals_flutter/signals_flutter.dart';

// 房间设置弹窗组件
class RoomSettingsSheet extends StatefulWidget {
  const RoomSettingsSheet({Key? key}) : super(key: key);

  @override
  State<RoomSettingsSheet> createState() => _RoomSettingsSheetState();

  static Future<void> show(BuildContext context) async {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    if (isDesktop) {
      // PC端显示为对话框
      return showDialog(
        context: context,
        builder:
            (_) => Dialog(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                  maxHeight: 600,
                ),
                child: const RoomSettingsSheet(),
              ),
            ),
      );
    }

    // 移动端显示为底部弹窗
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.4,
            maxChildSize: 0.8,
            builder:
                (_, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: const RoomSettingsSheet(),
                ),
          ),
    );
  }
}

class _RoomSettingsSheetState extends State<RoomSettingsSheet> {
  // 构建设置项标题
  Widget _buildSectionTitle(String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  // 构建设置项组件
  Widget _buildSettingSection(
    String title,
    List<Widget> buttons,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title, colorScheme),
        Wrap(spacing: 8, runSpacing: 8, children: buttons),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Watch((context) {
      // 监听所有显示状态
      final userListSimple = ServiceManager().displayState.userListSimple.watch(
        context,
      );
      final displayMode = ServiceManager().displayState.displayMode.watch(
        context,
      );
      final sortOption = ServiceManager().displayState.sortOption.watch(
        context,
      );
      final sortOrder = ServiceManager().displayState.sortOrder.watch(context);

      return Column(
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 8, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bar_chart_outlined,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '房间设置',
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '点击下方设置项进行配置，所有更改将实时生效',
                  textAlign: TextAlign.left,
                  maxLines: null,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // 滚动内容区域
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // 显示模式
                _buildSettingSection('显示模式', [
                  _buildOptionButton('简约', userListSimple, () {
                    ServiceManager().appSettings.setUserListSimple(true);
                  }),
                  _buildOptionButton('详细', !userListSimple, () {
                    ServiceManager().appSettings.setUserListSimple(false);
                  }),
                ], colorScheme),

                // 用户显示
                _buildSettingSection('用户显示', [
                  _buildOptionButton(
                    '默认',
                    displayMode == 0,
                    () => ServiceManager().appSettings.setDisplayMode(0),
                  ),
                  _buildOptionButton(
                    '用户',
                    displayMode == 1,
                    () => ServiceManager().appSettings.setDisplayMode(1),
                  ),
                  _buildOptionButton(
                    '服务器',
                    displayMode == 2,
                    () => ServiceManager().appSettings.setDisplayMode(2),
                  ),
                ], colorScheme),

                // 用户排序
                _buildSettingSection('用户排序', [
                  _buildOptionButton(
                    '默认',
                    sortOption == 0,
                    () => ServiceManager().appSettings.setSortOption(0),
                  ),
                  _buildOptionButton(
                    '延迟',
                    sortOption == 1,
                    () => ServiceManager().appSettings.setSortOption(1),
                  ),
                  _buildOptionButton(
                    '用户名',
                    sortOption == 2,
                    () => ServiceManager().appSettings.setSortOption(2),
                  ),
                ], colorScheme),

                // 排序方式
                _buildSettingSection('排序方式', [
                  _buildOptionButton(
                    '升序',
                    sortOrder == 0,
                    () => ServiceManager().appSettings.setSortOrder(0),
                  ),
                  _buildOptionButton(
                    '降序',
                    sortOrder == 1,
                    () => ServiceManager().appSettings.setSortOrder(1),
                  ),
                ], colorScheme),
              ],
            ),
          ),
        ],
      );
    });
  }

  // 构建选项按钮
  Widget _buildOptionButton(
    String text,
    bool isSelected,
    VoidCallback onPressed,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return IntrinsicWidth(
      child: SizedBox(
        height: 32,
        child: TextButton(
          onPressed: onPressed, // 始终可点击，避免状态不同步
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            backgroundColor:
                isSelected ? colorScheme.primary : colorScheme.surfaceVariant,
            foregroundColor:
                isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
            side: BorderSide(
              color: isSelected ? colorScheme.primary : colorScheme.outline,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Text(text, style: const TextStyle(fontSize: 13)),
        ),
      ),
    );
  }
}
