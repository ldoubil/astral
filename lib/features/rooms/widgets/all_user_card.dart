import 'package:astral/src/rust/api/simple.dart';
import 'package:astral/core/ui/app_snack_bars.dart';
import 'package:astral/features/rooms/widgets/all_user_card_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 将列表项卡片抽取为独立的StatefulWidget
class AllUserCard extends StatefulWidget {
  final KVNodeInfo player;
  final ColorScheme colorScheme;
  final String? localIPv4;

  const AllUserCard({
    super.key,
    required this.player,
    required this.colorScheme,
    required this.localIPv4,
  });

  @override
  State<AllUserCard> createState() => _AllUserCardState();
}

class _AllUserCardState extends State<AllUserCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color:
                isHovered ? widget.colorScheme.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            // 复制IP地址到剪贴板
            Clipboard.setData(ClipboardData(text: widget.player.ipv4));
            AppSnackBars.success(
              context,
              '已复制',
              'IP: ${widget.player.ipv4}',
              duration: const Duration(seconds: 2),
            );
          },
          splashColor: widget.colorScheme.primary.withValues(alpha: 0.3),
          highlightColor: widget.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.all(12),
            width: double.infinity,
            child: AllUserCardTile(
              player: widget.player,
              colorScheme: widget.colorScheme,
              localIPv4: widget.localIPv4 ?? '',
            ),
          ),
        ),
      ),
    );
  }
}
