import 'dart:io';

import 'package:astral/core/ui/app_snack_bars.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

/// 更新对话框
class UpdateDialog extends StatelessWidget {
  final String version;
  final String releaseNotes;
  final String downloadUrl;
  final bool isLatestVersion;
  final Map<String, dynamic>? releaseInfo;
  final VoidCallback? onDownload;
  final VoidCallback? onNetDiskDownload;

  const UpdateDialog({
    super.key,
    required this.version,
    required this.releaseNotes,
    required this.downloadUrl,
    required this.isLatestVersion,
    this.releaseInfo,
    this.onDownload,
    this.onNetDiskDownload,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isLatestVersion ? version : '发现新版本: $version'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isLatestVersion) const Text('更新内容:'),
            if (!isLatestVersion) const SizedBox(height: 8),
            Text(releaseNotes, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('稍后再说'),
        ),
        if (!isLatestVersion && onNetDiskDownload != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 等弹窗完成卸载后再用外层 context 打开下载，避免 deactivated context
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onNetDiskDownload!();
              });
            },
            child: const Text('网盘下载'),
          ),
        if (!isLatestVersion && onDownload != null)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onDownload!();
              });
            },
            child: const Text('GitHub下载'),
          ),
        if (!isLatestVersion && onDownload == null)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _launchUrl(downloadUrl);
            },
            child: const Text('手动下载'),
          ),
        if (isLatestVersion)
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// 下载进度对话框
class DownloadProgressDialog extends StatefulWidget {
  final Future<String?> Function(
    void Function(double) onProgress,
    bool Function() isCancelled,
  )
  onDownload;
  final String fileName;

  const DownloadProgressDialog({
    super.key,
    required this.onDownload,
    required this.fileName,
  });

  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  double _progress = 0.0;
  bool _isDownloading = true;
  bool _isCancelled = false;
  String? _filePath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  void _cancelDownload() {
    setState(() {
      _isCancelled = true;
      _isDownloading = false;
      _error = '下载已取消';
    });
  }

  Future<void> _startDownload() async {
    try {
      final filePath = await widget.onDownload((progress) {
        if (mounted && !_isCancelled) {
          setState(() {
            _progress = progress;
          });
        }
      }, () => _isCancelled);

      if (_isCancelled) return;

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _filePath = filePath;
          if (filePath == null) {
            _error = '下载失败：无法保存文件';
          }
        });
      }
    } catch (e) {
      if (_isCancelled) return;

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _error = '下载失败: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _isDownloading ? '正在下载更新' : (_error != null ? '下载失败' : '下载完成'),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isDownloading) ...[
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 16),
            Text('下载进度: ${(_progress * 100).toStringAsFixed(1)}%'),
          ] else if (_error != null) ...[
            Text(_error!),
          ] else ...[
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            Text('文件已下载到: ${widget.fileName}'),
            const SizedBox(height: 8),
            const Text('是否立即安装？'),
          ],
        ],
      ),
      actions: [
        if (_isDownloading) ...[
          TextButton(onPressed: _cancelDownload, child: const Text('取消下载')),
        ],
        if (!_isDownloading) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          if (_filePath != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _installFile(_filePath!);
              },
              child: const Text('立即安装'),
            ),
          if (_error != null)
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
        ],
      ],
    );
  }

  Future<void> _installFile(String filePath) async {
    try {
      if (Platform.isAndroid) {
        final result = await OpenFile.open(
          filePath,
          type: "application/vnd.android.package-archive",
        );

        if (result.type != ResultType.done) {
          throw Exception('安装失败: ${result.message}');
        }
      } else {
        await OpenFile.open(filePath);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBars.error(
          context,
          '无法打开安装文件',
          '$e\n请确保已开启「允许安装未知来源应用」权限',
          duration: const Duration(seconds: 5),
        );
      }
    }
  }
}

/// 显示 Android 架构选择对话框
void showArchitectureSelectionDialog({
  required BuildContext context,
  required void Function(String fileName) onSelected,
}) {
  final parentContext = context;
  final architectures = [
    {
      'name': 'ARM64 (推荐)',
      'file': 'astral-arm64-v8a.apk',
      'desc': '适用于大多数现代 Android 设备',
    },
    {
      'name': 'ARMv7',
      'file': 'astral-armeabi-v7a.apk',
      'desc': '适用于较旧的 32 位设备',
    },
  ];

  showDialog(
    context: parentContext,
    builder:
        (dialogContext) => AlertDialog(
          title: const Text('选择设备架构'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                architectures
                    .map(
                      (arch) => ListTile(
                        title: Text(arch['name']!),
                        subtitle: Text(arch['desc']!),
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            onSelected(arch['file']!);
                          });
                        },
                      ),
                    )
                    .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
          ],
        ),
  );
}
