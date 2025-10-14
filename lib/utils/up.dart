import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:astral/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class UpdateChecker {
  /// GitHub 仓库所有者
  final String owner;

  /// GitHub 仓库名称
  final String repo;

  /// 可选：指定检查的分支名称，默认为 'main'
  final String branch;

  UpdateChecker({
    required this.owner,
    required this.repo,
    this.branch = 'main',
  });

  /// 检查更新
  Future<void> checkForUpdates(
    BuildContext context, {
    bool showNoUpdateMessage = true,
  }) async {
    try {
      final releaseInfo = await _fetchLatestRelease(
        includePrereleases: AppState().updateState.beta.value,
      );
      if (releaseInfo == null) {
        _showUpdateDialog(
          context,
          '检查更新失败',
          '无法获取最新版本信息',
          'https://github.com/$owner/$repo/releases',
        );
        return;
      }

      // 获取当前应用版本
      final currentVersion = await _getCurrentVersion();
      debugPrint('当前版本: $currentVersion');
      debugPrint('服务器版本: ${releaseInfo['tag_name']}');

      // 保存最新版本号到数据库
      AppState().baseState.latestVersion.value = releaseInfo['tag_name'];

      // 比较版本号，如果有新版本则显示更新弹窗
      // 在 checkForUpdates 方法中修改 _showUpdateDialog 调用
      if (_shouldUpdate(currentVersion, releaseInfo['tag_name'])) {
        _showUpdateDialog(
          context,
          releaseInfo['tag_name'],
          releaseInfo['body'] ?? '新版本已发布',
          releaseInfo['html_url'],
          releaseInfo: releaseInfo, // 传递完整的 release 信息
        );
      } else if (showNoUpdateMessage) {
        _showUpdateDialog(
          context,
          '当前已是最新版本',
          '当前版本为: $currentVersion',
          'https://github.com/$owner/$repo/releases',
        );
      }
    } catch (e) {
      String errorMessage;
      String errorTitle = '更新检查失败';
      // 输出哪行出错
      debugPrint('出错行: ${StackTrace.current.toString().split('\n')[1]}');

      // 根据异常类型提供更详细的错误信息
      if (e is SocketException) {
        if (e.osError?.errorCode == 11001 || e.osError?.errorCode == -2) {
          errorMessage = 'DNS解析失败，请检查网络连接或稍后重试';
        } else if (e.osError?.errorCode == 10060 || e.osError?.errorCode == 110) {
          errorMessage = '连接超时，请检查网络连接或稍后重试';
        } else if (e.osError?.errorCode == 10061 || e.osError?.errorCode == 111) {
          errorMessage = '无法连接到服务器，请检查网络设置';
        } else {
          errorMessage = '网络连接失败: ${e.message}';
        }
      } else if (e is HttpException) {
        errorMessage = 'HTTP请求异常: ${e.message}';
      } else if (e is FormatException) {
        errorMessage = '数据格式错误，服务器返回了无效的响应';
      } else if (e.toString().contains('timeout') || e.toString().contains('TimeoutException')) {
        errorMessage = '请求超时，请检查网络连接或稍后重试';
      } else {
        errorMessage = '检查更新时发生未知错误: ${e.toString()}';
      }
      
      debugPrint('更新检查失败: $e');
      debugPrint('错误堆栈: ${StackTrace.current}');
      debugPrint('错误详情: ${e.runtimeType} - ${e.toString()}');
      
      _showUpdateDialog(
        context,
        errorTitle,
        errorMessage,
        'https://github.com/$owner/$repo/releases',
      );
    }
  }

  /// 获取最新发布版本信息
  Future<Map<String, dynamic>?> _fetchLatestRelease({
    bool includePrereleases = false,
  }) async {
    try {
      // 根据 includePrereleases 参数选择不同的 API 端点
      final apiUrl =
          includePrereleases
              ? 'https://api.github.com/repos/$owner/$repo/releases' // 获取所有版本
              : 'https://api.github.com/repos/$owner/$repo/releases/latest'; // 只获取最新稳定版

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'astral',
        },
      );

      if (response.statusCode == 200) {
        if (includePrereleases) {
          // 获取所有版本，返回第一个（最新的，可能是预发布版）
          final List<dynamic> releases = json.decode(response.body);
          if (releases.isEmpty) return null;
          return releases[0];
        } else {
          // 获取最新稳定版
          return json.decode(response.body);
        }
      } else {
        // 根据不同的HTTP状态码提供具体的错误信息
        String errorMessage;
        switch (response.statusCode) {
          case 403:
            errorMessage = 'GitHub API 访问受限，请稍后重试或检查网络设置';
            break;
          case 404:
            errorMessage = '未找到指定的仓库或版本信息';
            break;
          case 429:
            errorMessage = 'GitHub API 请求频率过高，请稍后重试';
            break;
          case 500:
          case 502:
          case 503:
          case 504:
            errorMessage = 'GitHub 服务器暂时不可用，请稍后重试';
            break;
          default:
            errorMessage = 'GitHub API 请求失败 (HTTP ${response.statusCode})';
        }
        
        debugPrint('GitHub API 请求失败: ${response.statusCode} - ${response.reasonPhrase}');
        
        return {
          'tag_name': '错误 ${response.statusCode}',
          'body': errorMessage,
          'html_url': 'https://github.com/$owner/$repo/releases',
        };
      }
    } catch (e) {
      debugPrint('获取GitHub发布信息失败: $e');
      
      // 根据异常类型返回更详细的错误信息
      String errorMessage;
      if (e is SocketException) {
        errorMessage = '网络连接失败，无法访问 GitHub';
      } else if (e is FormatException) {
        errorMessage = 'GitHub 返回的数据格式无效';
      } else if (e.toString().contains('timeout')) {
        errorMessage = '请求 GitHub 超时，请稍后重试';
      } else {
        errorMessage = '获取版本信息时发生未知错误';
      }
      
      return {
        'tag_name': '网络错误',
        'body': errorMessage,
        'html_url': 'https://github.com/$owner/$repo/releases',
      };
    }
  }

  /// 获取当前应用版本
  Future<String> _getCurrentVersion() async {
    try {
      return AppInfoUtil.getVersion();
    } catch (e) {
      return "0.0.0"; // 返回默认版本号避免后续比较崩溃
    }
  }

  /// 比较版本号，判断是否需要更新
  bool _shouldUpdate(String currentVersion, String latestVersion) {
    // 统一去除v前缀
    final current = currentVersion.replaceAll(RegExp(r'^v'), '');
    final latest = latestVersion.replaceAll(RegExp(r'^v'), '');

    // 分离主版本和预发布标签
    final currentParts = current.split('-');
    final latestParts = latest.split('-');

    // 比较主版本部分
    final currentMain = _parseVersionParts(currentParts[0]);
    final latestMain = _parseVersionParts(latestParts[0]);

    for (int i = 0; i < 3; i++) {
      final curr = i < currentMain.length ? currentMain[i] : 0;
      final lat = i < latestMain.length ? latestMain[i] : 0;

      if (lat > curr) return true;
      if (lat < curr) return false;
    }

    // 主版本相同，比较预发布标签
    if (currentParts.length == 1) return latestParts.length > 1; // 当前是正式版
    if (latestParts.length == 1) return true; // 最新是正式版

    return _comparePreRelease(currentParts[1], latestParts[1]) < 0;
  }

  List<int> _parseVersionParts(String version) {
    return version.split('.').map((s) => int.tryParse(s) ?? 0).toList();
  }

  int _comparePreRelease(String a, String b) {
    final aParts = a.split('.');
    final bParts = b.split('.');

    for (int i = 0; i < max(aParts.length, bParts.length); i++) {
      final aVal = i < aParts.length ? aParts[i] : '';
      final bVal = i < bParts.length ? bParts[i] : '';

      // 优先比较数字
      final aNum = int.tryParse(aVal);
      final bNum = int.tryParse(bVal);

      if (aNum != null && bNum != null) {
        if (aNum != bNum) return aNum.compareTo(bNum);
      } else {
        final cmp = aVal.compareTo(bVal);
        if (cmp != 0) return cmp;
      }
    }
    return 0;
  }

  /// 显示更新弹窗
  void _showUpdateDialog(
    BuildContext context,
    String version,
    String releaseNotes,
    String downloadUrl, {
    Map<String, dynamic>? releaseInfo,
  }) {
    final isLatestVersion = version.contains("当前已是最新版本");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => _UpdateDialog(
            version: version,
            releaseNotes: releaseNotes,
            downloadUrl: downloadUrl,
            isLatestVersion: isLatestVersion,
            releaseInfo: releaseInfo,
            onDownload:
                releaseInfo != null
                    ? () => _handleDownload(context, releaseInfo)
                    : null,
          ),
    );
  }

  /// 处理下载逻辑
  Future<void> _handleDownload(
    BuildContext context,
    Map<String, dynamic> releaseInfo,
  ) async {
    if (Platform.isAndroid) {
      // Android 平台显示架构选择对话框
      _showArchitectureSelectionDialog(context, releaseInfo);
    } else {
      // 其他平台直接下载
      final downloadUrlPath = _getDownloadUrl(releaseInfo);
      if (downloadUrlPath == null) return;
      final downloadUrl = AppState().updateState.downloadAccelerate.value + downloadUrlPath;
      final fileName = _getPlatformFileName();

      // 显示下载进度对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => _DownloadProgressDialog(
              onDownload:
                  (onProgress) =>
                      _downloadFile(downloadUrl, fileName, onProgress),
              fileName: fileName,
            ),
      );
    }
  }

  /// 显示架构选择对话框 (仅 Android)
  void _showArchitectureSelectionDialog(
    BuildContext context,
    Map<String, dynamic> releaseInfo,
  ) {
    final architectures = [
      {
        'name': 'ARM64 (推荐)',
        'file': 'astral-arm64-v8a.apk',
        'desc': '适用于大多数现代 Android 设备',
      },
      {'name': '通用版本', 'file': 'astral-universal.apk', 'desc': '兼容所有架构，文件较大'},
      {
        'name': 'ARMv7',
        'file': 'astral-armeabi-v7a.apk',
        'desc': '适用于较旧的 32 位设备',
      },
      {
        'name': 'x86_64',
        'file': 'astral-x86_64.apk',
        'desc': '适用于 Intel/AMD 处理器',
      },
    ];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                            Navigator.of(context).pop();
                            _startDownload(context, releaseInfo, arch['file']!);
                          },
                        ),
                      )
                      .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
            ],
          ),
    );
  }

  /// 开始下载指定文件
  void _startDownload(
    BuildContext context,
    Map<String, dynamic> releaseInfo,
    String fileName,
  ) {
    final downloadUrlPath = _getDownloadUrlForFile(releaseInfo, fileName);
    if (downloadUrlPath == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('未找到 $fileName 的下载链接')));
      return;
    }

    final downloadUrl = AppState().updateState.downloadAccelerate.value + downloadUrlPath;

    // 显示下载进度对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => _DownloadProgressDialog(
            onDownload:
                (onProgress) =>
                    _downloadFile(downloadUrl, fileName, onProgress),
            fileName: fileName,
          ),
    );
  }

  /// 根据平台获取对应的下载文件名
  String _getPlatformFileName() {
    if (Platform.isAndroid) {
      // 默认使用 arm64-v8a 架构，这是目前最常见的 Android 架构
      return 'astral-arm64-v8a.apk';
    } else if (Platform.isWindows) {
      return 'astral-windows-x64-setup.exe';
    } else {
      // 其他平台暂不支持直接下载
      return '';
    }
  }

  /// 从release信息中获取对应平台的下载链接
  String? _getDownloadUrl(Map<String, dynamic> releaseInfo) {
    final fileName = _getPlatformFileName();
    if (fileName.isEmpty) return null;

    return _getDownloadUrlForFile(releaseInfo, fileName);
  }

  /// 从release信息中获取指定文件的下载链接
  String? _getDownloadUrlForFile(
    Map<String, dynamic> releaseInfo,
    String fileName,
  ) {
    final assets = releaseInfo['assets'] as List<dynamic>?;
    if (assets == null) return null;

    for (final asset in assets) {
      if (asset['name'] == fileName) {
        return asset['browser_download_url'];
      }
    }
    return null;
  }

  /// 下载文件并显示进度 - 修复版本
  Future<String?> _downloadFile(
    String url,
    String fileName,
    Function(double) onProgress,
  ) async {
    IOSink? sink;
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await request.send();

      if (response.statusCode != 200) {
        String errorMessage;
        switch (response.statusCode) {
          case 403:
            errorMessage = '下载被拒绝，可能是访问限制或权限问题';
            break;
          case 404:
            errorMessage = '下载文件不存在，可能已被移除';
            break;
          case 429:
            errorMessage = '下载请求过于频繁，请稍后重试';
            break;
          case 500:
          case 502:
          case 503:
          case 504:
            errorMessage = '服务器暂时不可用，请稍后重试下载';
            break;
          default:
            errorMessage = '下载请求失败 (HTTP ${response.statusCode}: ${response.reasonPhrase ?? "未知错误"})';
        }
        
        throw Exception(errorMessage);
      }

      final contentLength = response.contentLength;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');

      // 检查文件是否存在，如果存在则删除
      if (await file.exists()) {
        await file.delete();
      }

      sink = file.openWrite();
      int downloadedBytes = 0;

      // 使用 await for 替代 listen
      await for (final chunk in response.stream) {
        sink.add(chunk);
        downloadedBytes += chunk.length;

        if (contentLength != null && contentLength > 0) {
          final progress = downloadedBytes / contentLength;
          onProgress(progress);
        }
      }

      await sink.flush();
      await sink.close();
      sink = null;

      onProgress(1.0); // 确保进度达到100%
      return file.path;
    } catch (e) {
      // 确保文件流被关闭
      if (sink != null) {
        try {
          await sink.close();
        } catch (_) {}
      }

      // 清理可能创建的不完整文件
      try {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}

      // 根据异常类型提供详细的错误信息
      String errorMessage;
      if (e is SocketException) {
        if (e.osError?.errorCode == 28 || e.message.contains('No space left')) {
          errorMessage = '存储空间不足，请清理设备存储空间后重试';
        } else if (e.osError?.errorCode == 13 || e.message.contains('Permission denied')) {
          errorMessage = '没有写入权限，请检查应用权限设置';
        } else if (e.osError?.errorCode == 11001 || e.osError?.errorCode == -2) {
          errorMessage = 'DNS解析失败，请检查网络连接';
        } else if (e.osError?.errorCode == 10060 || e.osError?.errorCode == 110) {
          errorMessage = '下载超时，请检查网络连接或稍后重试';
        } else {
          errorMessage = '网络连接失败: ${e.message}';
        }
      } else if (e is FileSystemException) {
        if (e.osError?.errorCode == 28) {
          errorMessage = '存储空间不足，无法保存下载文件';
        } else if (e.osError?.errorCode == 13) {
          errorMessage = '没有文件写入权限，请检查应用权限';
        } else {
          errorMessage = '文件系统错误: ${e.message}';
        }
      } else if (e is HttpException) {
        errorMessage = '下载过程中发生HTTP错误: ${e.message}';
      } else if (e.toString().contains('timeout') || e.toString().contains('TimeoutException')) {
        errorMessage = '下载超时，请检查网络连接或稍后重试';
      } else {
        errorMessage = '下载失败: ${e.toString()}';
      }

      debugPrint('文件下载失败: $e');
      debugPrint('错误类型: ${e.runtimeType}');
      if (e is SocketException && e.osError != null) {
        debugPrint('系统错误代码: ${e.osError!.errorCode}');
      }
      
      throw Exception(errorMessage);
    }
  }
}

class AppInfoUtil {
  static PackageInfo? _packageInfo;

  /// 初始化应用信息
  static Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  /// 获取应用版本号 (例如: 1.0.0)
  static String getVersion() {
    return _packageInfo?.version ?? '';
  }

  /// 获取应用构建号 (例如: 1)
  static String getBuildNumber() {
    return _packageInfo?.buildNumber ?? '';
  }

  /// 获取完整版本号 (例如: 1.0.0+1)
  static String getFullVersion() {
    final version = getVersion();
    final buildNumber = getBuildNumber();
    return '$version+$buildNumber';
  }

  /// 获取应用名称
  static String getAppName() {
    return _packageInfo?.appName ?? '';
  }

  /// 获取包名
  static String getPackageName() {
    return _packageInfo?.packageName ?? '';
  }
}

/// 更新对话框组件
class _UpdateDialog extends StatelessWidget {
  final String version;
  final String releaseNotes;
  final String downloadUrl;
  final bool isLatestVersion;
  final Map<String, dynamic>? releaseInfo;
  final VoidCallback? onDownload;

  const _UpdateDialog({
    required this.version,
    required this.releaseNotes,
    required this.downloadUrl,
    required this.isLatestVersion,
    this.releaseInfo,
    this.onDownload,
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
        if (!isLatestVersion && onDownload != null)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDownload!();
            },
            child: const Text('立即更新'),
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

/// 下载进度对话框组件
class _DownloadProgressDialog extends StatefulWidget {
  final Future<String?> Function(Function(double) onProgress) onDownload;
  final String fileName;

  const _DownloadProgressDialog({
    required this.onDownload,
    required this.fileName,
  });

  @override
  State<_DownloadProgressDialog> createState() =>
      _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<_DownloadProgressDialog> {
  double _progress = 0.0;
  bool _isDownloading = true;
  String? _filePath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      final filePath = await widget.onDownload((progress) {
        if (mounted) {
          setState(() {
            _progress = progress;
          });
        }
      });

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _filePath = filePath;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _error = e.toString(); // 直接使用详细的错误信息
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

  /// 安装下载的文件
  /// 提供详细的安装错误处理和用户指导
  Future<void> _installFile(String filePath) async {
    try {
      if (Platform.isAndroid) {
        // Android平台需要特殊处理
        final result = await OpenFile.open(
          filePath,
          type: "application/vnd.android.package-archive",
        );

        // 根据不同的结果类型提供具体的错误信息
        if (result.type != ResultType.done) {
          String errorMessage;
          switch (result.type) {
            case ResultType.noAppToOpen:
              errorMessage = '没有找到可以安装APK的应用程序\n\n解决方案：\n1. 确保设备支持APK安装\n2. 检查是否禁用了包安装器';
              break;
            case ResultType.fileNotFound:
              errorMessage = '安装文件不存在或已被删除\n\n解决方案：\n1. 重新下载安装包\n2. 检查存储空间是否充足';
              break;
            case ResultType.permissionDenied:
              errorMessage = '没有安装权限\n\n解决方案：\n1. 前往设置 > 安全 > 允许安装未知来源应用\n2. 为本应用开启安装权限\n3. 重启应用后重试';
              break;
            case ResultType.error:
            default:
              errorMessage = '安装过程中发生错误: ${result.message}\n\n可能原因：\n1. 安装包损坏或不完整\n2. 设备存储空间不足\n3. 系统版本不兼容\n4. 安装权限被拒绝';
              break;
          }
          throw Exception(errorMessage);
        }
      } else {
        // 其他平台（Windows、macOS、Linux）
        final result = await OpenFile.open(filePath);
        
        if (result.type != ResultType.done) {
          String errorMessage;
          switch (result.type) {
            case ResultType.noAppToOpen:
              errorMessage = '没有找到可以打开此文件的应用程序\n\n解决方案：\n1. 手动双击文件进行安装\n2. 使用系统默认的安装程序';
              break;
            case ResultType.fileNotFound:
              errorMessage = '安装文件不存在\n\n解决方案：\n1. 重新下载安装包\n2. 检查文件路径是否正确';
              break;
            case ResultType.permissionDenied:
              errorMessage = '没有权限访问安装文件\n\n解决方案：\n1. 以管理员身份运行应用\n2. 检查文件权限设置';
              break;
            case ResultType.error:
            default:
              errorMessage = '无法打开安装文件: ${result.message}\n\n解决方案：\n1. 手动导航到下载文件夹\n2. 双击安装文件进行安装';
              break;
          }
          throw Exception(errorMessage);
        }
      }
    } catch (e) {
      debugPrint('安装文件失败: $e');
      
      if (mounted) {
        // 显示详细的错误信息和解决建议
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: '查看文件',
              onPressed: () {
                // 尝试打开文件所在的目录
                try {
                  final directory = filePath.substring(0, filePath.lastIndexOf(Platform.pathSeparator));
                  OpenFile.open(directory);
                } catch (_) {
                  // 如果无法打开目录，则忽略
                }
              },
            ),
          ),
        );
      }
    }
  }
}
