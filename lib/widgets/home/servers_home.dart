import 'package:astral/k/app_s/aps.dart';
import 'package:astral/utils/blocked_servers.dart';
import 'package:astral/widgets/home_box.dart';
import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

class ServersHome extends StatelessWidget {
  const ServersHome({super.key});

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;
    return HomeBox(
      widthSpan: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dns, color: colorScheme.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                LocaleKeys.current_servers.tr(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final servers = Aps().servers.watch(context);
              var enabledServers =
                  servers.where((s) => s.enable == true).toList();
              if (enabledServers.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    LocaleKeys.no_enabled_servers.tr(),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    enabledServers.map<Widget>((server) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colorScheme.outlineVariant.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // 状态指示竖条
                            Container(
                              width: 4,
                              height: 48,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // 服务器信息
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    server.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.language,
                                        size: 12,
                                        color: colorScheme.onSurfaceVariant
                                            .withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          BlockedServers.isBlocked(server.url)
                                              ? '***'
                                              : server.url,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colorScheme.onSurfaceVariant,
                                            height: 1.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
