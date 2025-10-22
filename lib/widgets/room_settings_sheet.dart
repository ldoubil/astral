import 'package:astral/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

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
                    LocaleKeys.room_settings.tr(),
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
                LocaleKeys.room_settings_desc.tr(),
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
              _buildSettingSection(LocaleKeys.display_mode.tr(), [
                _buildOptionButton(
                  LocaleKeys.display_simple.tr(),
                  AppState().applicationState.userListSimple.watch(context),
                  () {
                    AppState().applicationState.userListSimple.set(true);
                  },
                ),
                _buildOptionButton(
                  LocaleKeys.display_detailed.tr(),
                  !AppState().applicationState.userListSimple.watch(context),
                  () {
                    AppState().applicationState.userListSimple.set(false);
                  },
                ),
              ], colorScheme),

              // 用户显示
              _buildSettingSection(LocaleKeys.user_display.tr(), [
                _buildOptionButton(
                  LocaleKeys.default_option.tr(),
                  AppState().baseState.displayMode.watch(context) == 0,
                  () => AppState().baseState.displayMode.set(0),
                ),
                _buildOptionButton(
                  LocaleKeys.user_option.tr(),
                  AppState().baseState.displayMode.watch(context) == 1,
                  () => AppState().baseState.displayMode.set(1),
                ),
                _buildOptionButton(
                  LocaleKeys.server_option.tr(),
                  AppState().baseState.displayMode.watch(context) == 2,
                  () => AppState().baseState.displayMode.set(2),
                ),
              ], colorScheme),

              // 用户排序
              _buildSettingSection(LocaleKeys.user_sorting.tr(), [
                _buildOptionButton(
                  LocaleKeys.default_option.tr(),
                  AppState().baseState.sortOption.watch(context) == 0,
                  () => AppState().baseState.sortOption.set(0),
                ),
                _buildOptionButton(
                  LocaleKeys.sort_by_latency.tr(),
                  AppState().baseState.sortOption.watch(context) == 1,
                  () => AppState().baseState.sortOption.set(1),
                ),
                _buildOptionButton(
                  LocaleKeys.sort_by_username.tr(),
                  AppState().baseState.sortOption.watch(context) == 2,
                  () => AppState().baseState.sortOption.set(2),
                ),
              ], colorScheme),

              // 排序方式
              _buildSettingSection(LocaleKeys.sort_order.tr(), [
                _buildOptionButton(
                  LocaleKeys.ascending.tr(),
                  AppState().baseState.sortOrder.watch(context) == 0,
                  () => AppState().baseState.sortOrder.set(0),
                ),
                _buildOptionButton(
                  LocaleKeys.descending.tr(),
                  AppState().baseState.sortOrder.watch(context) == 1,
                  () => AppState().baseState.sortOrder.set(1),
                ),
              ], colorScheme),
            ],
          ),
        ),
      ],
    );
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
          onPressed: onPressed,
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
