import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:astral/core/models/room.dart';
import 'package:astral/core/models/network_config_share.dart';
import 'package:astral/shared/utils/data/room_crypto.dart';
import 'package:astral/core/services/service_manager.dart';

/// 房间分享助手类
/// 提供完整的房间分享功能，包括链接生成、分享、导入等
class RoomShareHelper {
  static const String appScheme = 'astral';
  static const String roomPath = 'room';

  /// 生成房间分享链接
  ///
  /// [room] 要分享的房间对象
  /// [includeDeepLink] 是否生成深度链接格式
  /// 返回分享链接字符串
  static String generateShareLink(Room room, {bool includeDeepLink = true}) {
    try {
      // 验证房间数据
      final (isValid, errorMessage) = validateRoom(room);
      if (!isValid) {
        throw Exception('房间数据无效: $errorMessage');
      }

      // 清理房间数据
      final cleanedRoom = cleanRoom(room);

      // 根据房间是否携带网络配置来调用加密方法
      final shareCode = encryptRoomWithJWT(
        cleanedRoom,
        includeNetworkConfig: cleanedRoom.networkConfigJson.isNotEmpty,
      );

      if (includeDeepLink) {
        return '$appScheme://$roomPath?code=$shareCode';
      } else {
        return shareCode;
      }
    } catch (e) {
      throw Exception('生成分享链接失败: $e');
    }
  }

  /// 生成分享文本
  ///
  /// [room] 要分享的房间对象
  /// [includeInstructions] 是否包含使用说明
  static String generateShareText(
    Room room, {
    bool includeInstructions = true,
  }) {
    final link = generateShareLink(room);
    final roomSummary = generateRoomSummary(room);

    // 构建分享信息的选项说明
    String shareOptions = '';
    final hasServers = room.servers.isNotEmpty;
    final hasNetworkConfig = room.networkConfigJson.isNotEmpty;
    if (hasServers || hasNetworkConfig) {
      shareOptions = '\n📦 分享选项：\n';
      if (hasServers) {
        shareOptions += '  ✓ 携带服务器列表\n';
      }
      if (hasNetworkConfig) {
        shareOptions += '  ✓ 携带网络配置\n';
      }
    }

    String shareText = '''
🎮 Astral 房间分享

$roomSummary$shareOptions
🔗 分享链接：$link
''';

    if (includeInstructions) {
      shareText += '''

📖 使用说明：
1. 确保已安装 Astral 应用
2. 点击上方链接自动导入房间
3. 或复制分享码在应用内手动导入

⏰ 分享链接有效期：30天
''';
    }

    return shareText;
  }

  /// 复制房间分享链接到剪贴板
  ///
  /// [context] 上下文，用于显示提示信息
  /// [room] 要分享的房间对象
  /// [linkOnly] 是否只复制链接（不包含说明文字）
  static Future<void> copyShareLink(
    BuildContext context,
    Room room, {
    bool linkOnly = false,
  }) async {
    try {
      final content =
          linkOnly ? generateShareLink(room) : generateShareText(room);

      await Clipboard.setData(ClipboardData(text: content));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '复制成功',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        linkOnly ? '房间链接已复制到剪贴板' : '房间分享信息已复制到剪贴板',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('复制失败: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// 使用系统分享功能分享房间
  ///
  /// [context] 上下文
  /// [room] 要分享的房间对象
  static Future<void> shareRoom(BuildContext context, Room room) async {
    try {
      final shareText = generateShareText(room);

      // 由于没有share_plus包，直接复制到剪贴板并提示用户
      await Clipboard.setData(ClipboardData(text: shareText));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '已复制分享信息',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        '请粘贴到其他应用分享给好友',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blue[700],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分享失败: ${e.toString()}'),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 显示房间分享对话框
  /// 支持选择是否携带服务器列表和网络配置
  ///
  /// [context] 上下文
  /// [room] 要分享的房间对象
  static Future<void> showShareDialog(BuildContext context, Room room) async {
    // 服务器选择状态
    final selectedServers = <String>[];

    // 网络配置选择状态
    final networkConfigOptions = <String, bool>{
      'dhcp': false,
      'defaultProtocol': false,
      'enableEncryption': false,
      'latencyFirst': false,
      'disableP2p': false,
      'disableUdpHolePunching': false,
      'disableSymHolePunching': false,
      'dataCompressAlgo': false,
      'enableKcpProxy': false,
      'enableQuicProxy': false,
      'bindDevice': false,
      'noTun': false,
    };

    // 预先加载所有启用的服务器列表
    final allServers = await ServiceManager().server.getAllServers();
    final enabledServers = allServers.where((s) => s.enable).toList();
    final enabledServerUrls =
        enabledServers.expand((s) {
          final urls = <String>[];
          if (s.tcp) urls.add('tcp://${s.url}');
          if (s.udp) urls.add('udp://${s.url}');
          if (s.ws) urls.add('ws://${s.url}');
          if (s.wss) urls.add('wss://${s.url}');
          if (s.quic) urls.add('quic://${s.url}');
          if (s.wg) urls.add('wg://${s.url}');
          if (s.txt) urls.add('txt://${s.url}');
          if (s.srv) urls.add('srv://${s.url}');
          if (s.http) urls.add('http://${s.url}');
          if (s.https) urls.add('https://${s.url}');
          return urls;
        }).toList();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // 构建要分享的房间对象
            final hasServers = selectedServers.isNotEmpty;
            final hasNetworkConfig = networkConfigOptions.values.any((v) => v);

            NetworkConfigShare? networkConfig;
            if (hasNetworkConfig) {
              final currentConfig = NetworkConfigShare.fromCurrentConfig();
              // 只保留用户选中的配置项
              networkConfig = NetworkConfigShare(
                dhcp:
                    networkConfigOptions['dhcp']! ? currentConfig.dhcp : false,
                defaultProtocol:
                    networkConfigOptions['defaultProtocol']!
                        ? currentConfig.defaultProtocol
                        : null,
                enableEncryption:
                    networkConfigOptions['enableEncryption']!
                        ? currentConfig.enableEncryption
                        : null,
                latencyFirst:
                    networkConfigOptions['latencyFirst']!
                        ? currentConfig.latencyFirst
                        : null,
                disableP2p:
                    networkConfigOptions['disableP2p']!
                        ? currentConfig.disableP2p
                        : null,
                disableUdpHolePunching:
                    networkConfigOptions['disableUdpHolePunching']!
                        ? currentConfig.disableUdpHolePunching
                        : null,
                disableSymHolePunching:
                    networkConfigOptions['disableSymHolePunching']!
                        ? currentConfig.disableSymHolePunching
                        : null,
                dataCompressAlgo:
                    networkConfigOptions['dataCompressAlgo']!
                        ? currentConfig.dataCompressAlgo
                        : null,
                enableKcpProxy:
                    networkConfigOptions['enableKcpProxy']!
                        ? currentConfig.enableKcpProxy
                        : null,
                enableQuicProxy:
                    networkConfigOptions['enableQuicProxy']!
                        ? currentConfig.enableQuicProxy
                        : null,
                bindDevice:
                    networkConfigOptions['bindDevice']!
                        ? currentConfig.bindDevice
                        : null,
                noTun:
                    networkConfigOptions['noTun']! ? currentConfig.noTun : null,
              );
            }

            final roomToShare = Room(
              id: room.id,
              name: room.name,
              encrypted: room.encrypted,
              roomName: room.roomName,
              messageKey: room.messageKey,
              password: room.password,
              tags: room.tags,
              sortOrder: room.sortOrder,
              servers: hasServers ? selectedServers : [],
              customParam:
                  hasServers
                      ? DateTime.now().millisecondsSinceEpoch.toString()
                      : '',
              networkConfigJson:
                  hasNetworkConfig ? networkConfig!.toJsonString() : '',
            );

            final shareLink = generateShareLink(
              roomToShare,
              includeDeepLink: true,
            );

            final colorScheme = Theme.of(context).colorScheme;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ===== 顶部标题区域 =====
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.share,
                                color: colorScheme.onPrimaryContainer,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '分享房间',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    room.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Divider(height: 1, color: colorScheme.outlineVariant),

                      // ===== 主要内容区域 =====
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ===== 房间基本信息 =====
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceVariant.withOpacity(
                                  0.3,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: colorScheme.outlineVariant,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 18,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '房间基本信息',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.tag,
                                        size: 16,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '房间名称',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.labelSmall?.copyWith(
                                                color:
                                                    colorScheme
                                                        .onSurfaceVariant,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              room.name,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ===== 高级选项折叠区域 =====
                            if (enabledServerUrls.isNotEmpty ||
                                networkConfigOptions.isNotEmpty)
                              _buildAdvancedShareOptions(
                                context,
                                selectedServers,
                                networkConfigOptions,
                                enabledServerUrls,
                                setState,
                                colorScheme,
                              ),

                            // ===== 分享选项摘要 =====
                            if (hasServers || hasNetworkConfig) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondaryContainer
                                      .withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colorScheme.outline,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 18,
                                      color: colorScheme.secondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        hasServers && hasNetworkConfig
                                            ? '将分享 ${selectedServers.length} 个服务器 + ${networkConfigOptions.values.where((v) => v).length} 项配置'
                                            : hasServers
                                            ? '将分享 ${selectedServers.length} 个服务器'
                                            : '将分享 ${networkConfigOptions.values.where((v) => v).length} 项配置',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          color: colorScheme.secondary,
                                        ),
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      Divider(height: 1, color: colorScheme.outlineVariant),

                      // ===== 底部操作按钮 =====
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('取消'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                copyShareLink(
                                  context,
                                  roomToShare,
                                  linkOnly: true,
                                );
                              },
                              icon: const Icon(Icons.copy_outlined),
                              label: const Text('复制链接'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 从剪贴板导入房间
  ///
  /// [context] 上下文
  /// 返回是否成功导入
  static Future<bool> importFromClipboard(BuildContext context) async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final clipboardText = clipboardData?.text?.trim() ?? '';

      if (clipboardText.isEmpty) {
        _showError(context, '剪贴板为空', '请先复制房间分享码或链接');
        return false;
      }

      return await importRoom(context, clipboardText);
    } catch (e) {
      _showError(context, '读取剪贴板失败', e.toString());
      return false;
    }
  }

  /// 导入房间
  ///
  /// [context] 上下文
  /// [shareText] 分享码或链接
  /// 返回是否成功导入
  static Future<bool> importRoom(BuildContext context, String shareText) async {
    try {
      String shareCode = shareText.trim();

      // 如果是深度链接格式，提取分享码
      if (shareCode.startsWith('$appScheme://')) {
        final uri = Uri.tryParse(shareCode);
        if (uri == null || uri.host != roomPath) {
          _showError(context, '链接格式错误', '不是有效的房间分享链接');
          return false;
        }
        shareCode = uri.queryParameters['code'] ?? '';
      }

      // 清理分享码
      shareCode = shareCode.replaceAll(RegExp(r'\s+'), '');

      if (shareCode.isEmpty) {
        _showError(context, '分享码为空', '请提供有效的房间分享码');
        return false;
      }

      // 验证分享码格式
      if (!isValidShareCode(shareCode)) {
        _showError(context, '分享码格式错误', '分享码格式不正确，请检查是否完整');
        return false;
      }

      // 解密房间信息
      final room = decryptRoomFromJWT(shareCode);
      if (room == null) {
        _showError(context, '分享码无效', '无法解析房间信息，请检查分享码是否正确或已过期');
        return false;
      }

      // 验证房间数据完整性
      final (isValid, errorMessage) = validateRoom(room);
      if (!isValid) {
        _showError(context, '房间数据无效', errorMessage ?? '房间数据不符合要求');
        return false;
      }

      // 清理房间数据
      final cleanedRoom = cleanRoom(room);

      // 如果房间携带网络配置，显示确认对话框
      bool applyNetworkConfig = false;
      if (cleanedRoom.networkConfigJson.isNotEmpty) {
        try {
          final networkConfig = NetworkConfigShare.fromJsonString(
            cleanedRoom.networkConfigJson,
          );

          // 显示确认对话框
          final shouldApply = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              bool applyConfig = true; // 默认勾选

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
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceVariant.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outline.withOpacity(0.3),
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

          applyNetworkConfig = shouldApply ?? false;

          // 如果用户选择应用配置
          if (applyNetworkConfig && networkConfig != null) {
            await networkConfig.applyToConfig();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('网络配置已应用'),
                    ],
                  ),
                  backgroundColor: Colors.blue[700],
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        } catch (e) {
          debugPrint('解析或应用网络配置失败: $e');
          // 即使配置应用失败，也继续导入房间
        }
      }

      // 如果房间携带服务器列表，只保存房间自己的服务器列表
      // 合并操作延迟到连接时进行（这样能获取最新的全局启用服务器）
      // cleanedRoom.servers 已经包含分享时的服务器列表，不需要在此修改

      // 添加房间
      await ServiceManager().room.addRoom(cleanedRoom);

      // 安全地跳转到房间页面并选中房间
      await navigateToRoomPage(cleanedRoom, context: context);

      if (context.mounted) {
        // 构建导入成功提示
        String serverInfo = '';
        if (cleanedRoom.servers.isNotEmpty) {
          serverInfo = ' (已内置 ${cleanedRoom.servers.length} 个服务器)';
        }
        String networkConfigInfo = '';
        if (applyNetworkConfig) {
          networkConfigInfo = '\n✓ 已应用网络配置';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '导入成功',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '已成功添加并选中房间"${cleanedRoom.name}"$serverInfo$networkConfigInfo',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      return true;
    } catch (e) {
      _showError(context, '导入失败', e.toString());
      return false;
    }
  }

  /// 显示错误信息
  static void _showError(BuildContext context, String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(message, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 显示信息提示
  static void _showInfo(BuildContext context, String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(message, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[700],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 安全地跳转到房间页面并选中房间
  ///
  /// [room] 要选中的房间
  /// [context] 上下文（可选）
  static Future<void> navigateToRoomPage(
    Room room, {
    BuildContext? context,
  }) async {
    try {
      // 使用 Future.microtask 确保在下一个事件循环中执行
      // 这样可以避免在应用初始化过程中出现问题
      await Future.microtask(() async {
        // 跳转到房间页面
        ServiceManager().uiState.selectedIndex.set(1);

        // 延迟一点时间确保页面已经切换
        await Future.delayed(const Duration(milliseconds: 100));

        // 选中房间
        await ServiceManager().room.setRoom(room);
      });

      debugPrint('已跳转到房间页面并选中房间: ${room.name}');
    } catch (e) {
      debugPrint('跳转到房间页面失败: $e');
      if (context != null) {
        _showError(context, '跳转失败', '无法跳转到房间页面: $e');
      }
    }
  }

  /// 构建高级分享选项 (折叠展开式设计)
  static Widget _buildAdvancedShareOptions(
    BuildContext context,
    List<String> selectedServers,
    Map<String, bool> networkConfigOptions,
    List<String> enabledServerUrls,
    StateSetter setState,
    ColorScheme colorScheme,
  ) {
    return ExpansionTile(
      initiallyExpanded: false,
      title: Row(
        children: [
          Icon(Icons.tune_outlined, size: 20, color: colorScheme.secondary),
          const SizedBox(width: 8),
          Text(
            '高级选项',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.secondary,
            ),
          ),
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      backgroundColor: colorScheme.surface,
      collapsedBackgroundColor: colorScheme.surfaceVariant.withOpacity(0.2),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 服务器选择
              if (enabledServerUrls.isNotEmpty) ...[
                Text(
                  '🔗 服务器列表',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    children:
                        enabledServerUrls.map((serverUrl) {
                          final isSelected = selectedServers.contains(
                            serverUrl,
                          );
                          return CheckboxListTile(
                            dense: true,
                            title: Text(
                              serverUrl,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontFamily: 'monospace'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedServers.add(serverUrl);
                                } else {
                                  selectedServers.remove(serverUrl);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 网络配置选择
              if (networkConfigOptions.isNotEmpty)
                Text(
                  '⚙️ 网络配置',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    _buildConfigCheckbox(
                      context,
                      'DHCP',
                      'dhcp',
                      networkConfigOptions,
                      setState,
                    ),
                    _buildConfigCheckbox(
                      context,
                      '默认协议',
                      'defaultProtocol',
                      networkConfigOptions,
                      setState,
                    ),
                    _buildConfigCheckbox(
                      context,
                      '加密',
                      'enableEncryption',
                      networkConfigOptions,
                      setState,
                    ),
                    _buildConfigCheckbox(
                      context,
                      '延迟优先',
                      'latencyFirst',
                      networkConfigOptions,
                      setState,
                    ),
                    _buildConfigCheckbox(
                      context,
                      '禁用P2P',
                      'disableP2p',
                      networkConfigOptions,
                      setState,
                    ),
                    _buildConfigCheckbox(
                      context,
                      '禁用UDP打洞',
                      'disableUdpHolePunching',
                      networkConfigOptions,
                      setState,
                    ),
                    _buildConfigCheckbox(
                      context,
                      '禁用对称打洞',
                      'disableSymHolePunching',
                      networkConfigOptions,
                      setState,
                    ),
                    _buildConfigCheckbox(
                      context,
                      '数据压缩',
                      'dataCompressAlgo',
                      networkConfigOptions,
                      setState,
                    ),
                    _buildConfigCheckbox(
                      context,
                      'KCP代理',
                      'enableKcpProxy',
                      networkConfigOptions,
                      setState,
                    ),
                    _buildConfigCheckbox(
                      context,
                      'QUIC代理',
                      'enableQuicProxy',
                      networkConfigOptions,
                      setState,
                    ),
                    _buildConfigCheckbox(
                      context,
                      '绑定设备',
                      'bindDevice',
                      networkConfigOptions,
                      setState,
                    ),
                    _buildConfigCheckbox(
                      context,
                      '禁用TUN',
                      'noTun',
                      networkConfigOptions,
                      setState,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建网络配置复选框
  static Widget _buildConfigCheckbox(
    BuildContext context,
    String label,
    String key,
    Map<String, bool> options,
    StateSetter setState, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        CheckboxListTile(
          dense: true,
          title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          value: options[key],
          onChanged: (value) {
            setState(() {
              options[key] = value ?? false;
            });
          },
        ),
        if (!isLast)
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
      ],
    );
  }
}
