import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:astral/core/models/network_config_share.dart';
import 'package:astral/core/room/room_share_codec.dart';
import 'package:astral/core/ui/app_snack_bars.dart';
import 'package:astral/core/ui/room_navigation.dart';
import 'package:astral/core/services/service_manager.dart';

/// 房间分享导入对话框与相关逻辑
class RoomShareImportDialogs {
  /// 从剪贴板导入房间
  static Future<bool> importFromClipboard(BuildContext context) async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final clipboardText = clipboardData?.text?.trim() ?? '';

      if (!context.mounted) return false;

      if (clipboardText.isEmpty) {
        AppSnackBars.error(context, '剪贴板为空', '请先复制房间分享码或链接');
        return false;
      }

      return await importRoom(context, clipboardText);
    } catch (e) {
      if (!context.mounted) return false;
      AppSnackBars.error(context, '读取剪贴板失败', e.toString());
      return false;
    }
  }

  /// 导入房间
  ///
  /// [shareText] 分享码或链接
  static Future<bool> importRoom(BuildContext context, String shareText) async {
    try {
      String shareCode = shareText.trim();

      // 如果是深度链接格式，提取分享码
      if (shareCode.startsWith('${RoomShareCodec.appScheme}://')) {
        final uri = Uri.tryParse(shareCode);
        if (uri == null || uri.host != RoomShareCodec.roomPath) {
          AppSnackBars.error(context, '链接格式错误', '不是有效的房间分享链接');
          return false;
        }
        shareCode = uri.queryParameters['code'] ?? '';
      }

      shareCode = shareCode.replaceAll(RegExp(r'\s+'), '');

      if (shareCode.isEmpty) {
        AppSnackBars.error(context, '分享码为空', '请提供有效的房间分享码');
        return false;
      }

      if (shareCode.length < 10) {
        AppSnackBars.error(context, '分享码格式错误', '分享码过短或不完整，请检查是否复制完整');
        return false;
      }

      final room = RoomShareCodec.decryptRoom(shareCode);
      if (room == null) {
        AppSnackBars.error(
          context,
          '分享码解析失败',
          '无法解析房间信息，可能是分享码已过期或损坏',
        );
        return false;
      }

      final (isValid, errorMessage) = RoomShareCodec.validateRoom(room);
      if (!isValid) {
        AppSnackBars.error(
          context,
          '房间数据无效',
          errorMessage ?? '房间数据不符合要求',
        );
        return false;
      }

      final cleanedRoom = RoomShareCodec.cleanRoom(room);

      bool applyNetworkConfig = false;
      if (cleanedRoom.networkConfigJson.isNotEmpty) {
        try {
          final networkConfig = NetworkConfigShare.fromJsonString(
            cleanedRoom.networkConfigJson,
          );

          final shouldApply = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              bool applyConfig = true;

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Row(
                      children: [
                        Icon(
                          Icons.settings_suggest,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('检测到网络配置')),
                      ],
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '该房间包含以下网络配置：',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  networkConfig!
                                      .toReadableSummary()
                                      .map(
                                        (line) => Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child: Text(
                                            line,
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CheckboxListTile(
                            title: const Text('应用网络配置'),
                            subtitle: const Text('将上述配置应用到当前设备'),
                            value: applyConfig,
                            onChanged: (value) {
                              setState(() {
                                applyConfig = value ?? false;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '提示：如果不应用，仅导入房间信息',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('取消'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, applyConfig),
                        child: const Text('确定'),
                      ),
                    ],
                  );
                },
              );
            },
          );

          if (shouldApply == null) {
            return false;
          }

          applyNetworkConfig = shouldApply;

          if (applyNetworkConfig && networkConfig != null) {
            await networkConfig.applyToConfig();
            if (context.mounted) {
              AppSnackBars.info(context, '网络配置', '网络配置已应用');
            }
          }
        } catch (e) {
          debugPrint('解析或应用网络配置失败: $e');
        }
      }

      await ServiceManager().room.addRoom(cleanedRoom);

      if (!context.mounted) return false;

      await RoomNavigation.goToRoom(
        cleanedRoom,
        context: context,
      );

      if (context.mounted) {
        String serverInfo = '';
        if (cleanedRoom.servers.isNotEmpty) {
          serverInfo = ' (已内置 ${cleanedRoom.servers.length} 个服务器)';
        }
        String networkConfigInfo = '';
        if (applyNetworkConfig) {
          networkConfigInfo = '\n✓ 已应用网络配置';
        }

        AppSnackBars.success(
          context,
          '导入成功',
          '已成功添加并选中房间"${cleanedRoom.name}"$serverInfo$networkConfigInfo',
        );
      }

      return true;
    } catch (e) {
      if (context.mounted) {
        AppSnackBars.error(context, '导入失败', e.toString());
      }
      return false;
    }
  }
}
