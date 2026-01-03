import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:astral/k/services/service_manager.dart';
import 'package:astral/utils/net/ping_util.dart';

// 公共服务器对话框组件
class PublicServersDialog extends StatefulWidget {
  final Function(String, String) onAddServer;

  const PublicServersDialog({Key? key, required this.onAddServer})
    : super(key: key);

  @override
  State<PublicServersDialog> createState() => _PublicServersDialogState();

  // 显示公共服务器对话框
  static Future<void> show(
    BuildContext context,
    Function(String, String) onAddServer,
  ) async {
    // 根据屏幕宽度选择显示方式
    if (MediaQuery.of(context).size.width > 600) {
      // PC端显示为对话框
      await showDialog(
        context: context,
        builder:
            (context) => Hero(
              tag: 'public_servers_dialog',
              child: Dialog(
                child: SizedBox(
                  width: 400, // PC端统一宽度
                  height: 600, // 统一高度
                  child: PublicServersDialog(onAddServer: onAddServer),
                ),
              ),
            ),
      );
    } else {
      // 移动端显示为底部弹窗
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) => Hero(
              tag: 'public_servers_dialog',
              child: DraggableScrollableSheet(
                initialChildSize: 0.7,
                minChildSize: 0.5,
                maxChildSize: 0.9,
                builder:
                    (context, scrollController) => Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: PublicServersDialog(onAddServer: onAddServer),
                    ),
              ),
            ),
      );
    }
  }

  static Future<List<Map<String, String>>?> _fetchPublicServers() async {
    try {
      final response = await http.get(
        Uri.parse('https://astral.fan/server.json'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map(
              (item) => {
                'name': item['name'] as String,
                'url': item['url'] as String,
              },
            )
            .toList();
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      // 添加详细的错误日志
      debugPrint('获取公共服务器列表失败: $e');
      return []; // 返回空列表而不是null，避免后续空值异常
    }
  }
}

class _PublicServersDialogState extends State<PublicServersDialog>
    with TickerProviderStateMixin {
  List<Map<String, String>> _filteredServers = [];
  bool _isLoading = true;
  String? _error;
  final _services = ServiceManager();
  final Map<String, AnimationController> _animationControllers = {};
  final Map<String, Animation<double>> _scaleAnimations = {};

  // 公共服务器延迟结果
  final Map<String, int?> _pingResults = {};
  Timer? _pingTimer;

  @override
  void initState() {
    super.initState();
    _loadAndFilterServers();
  }

  @override
  void dispose() {
    // 清理所有动画控制器
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    // 停止ping定时器
    _pingTimer?.cancel();
    super.dispose();
  }

  // 创建动画控制器
  void _createAnimationController(String serverUrl) {
    if (!_animationControllers.containsKey(serverUrl)) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      final animation = Tween<double>(
        begin: 1.0,
        end: 0.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

      _animationControllers[serverUrl] = controller;
      _scaleAnimations[serverUrl] = animation;
    }
  }

  // 加载并过滤服务器列表
  Future<void> _loadAndFilterServers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // 获取公共服务器列表
      final allServers = await PublicServersDialog._fetchPublicServers();
      if (allServers == null || allServers.isEmpty) {
        setState(() {
          _error = '获取服务器列表失败或列表为空';
          _isLoading = false;
        });
        return;
      }

      // 实时获取本地服务器列表进行过滤
      final existingUrls =
          _services.serverState.servers.value
              .map((server) => server.url.trim().toLowerCase())
              .toSet();

      // 过滤掉已存在的服务器
      final filteredServers =
          allServers.where((server) {
            final serverUrl = server['url']?.trim().toLowerCase() ?? '';
            return serverUrl.isNotEmpty && !existingUrls.contains(serverUrl);
          }).toList();

      setState(() {
        _filteredServers = filteredServers;
        _isLoading = false;
      });

      // 为每个服务器创建动画控制器
      for (var server in filteredServers) {
        _createAnimationController(server['url']!);
      }

      // 启动ping测试
      _startPingTest();
    } catch (e) {
      setState(() {
        _error = '获取服务器列表失败: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // 标题栏
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.public, color: colorScheme.primary, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '公共服务器',
                    style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '点击服务器卡片右方的添加按钮进行添加',
                textAlign: TextAlign.left,
                maxLines: null,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // 服务器列表 - 使用 Expanded 填充剩余空间
        Expanded(child: _buildContent()),

        // 底部按钮
        Padding(
          padding: const EdgeInsets.all(24),
          child: FilledButton(
            onPressed: Navigator.of(context).pop,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 0),
            ),
            child: const Text('关闭'),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('获取中...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '获取服务器列表失败',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      );
    }

    if (_filteredServers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '所有公共服务器已添加',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '当前没有新的公共服务器可以添加',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16), // 统一边距
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _filteredServers.length,
        itemBuilder: (context, index) {
          final server = _filteredServers[index];
          final serverUrl = server['url']!;

          // 确保动画控制器存在
          _createAnimationController(serverUrl);

          return AnimatedBuilder(
            animation: _scaleAnimations[serverUrl]!,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimations[serverUrl]!.value,
                child: Opacity(
                  opacity: _scaleAnimations[serverUrl]!.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: _PublicServerItem(
                      server: server,
                      pingResult: _pingResults[server['url']!],
                      onAdd: () => _addServer(server['name']!, server['url']!),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 添加服务器并实时更新列表
  void _addServer(String name, String url) {
    // 调用外部回调添加服务器
    widget.onAddServer(name, url);

    // 显示成功提示
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('已添加服务器: $name')));

    // 从当前列表中移除已添加的服务器
    setState(() {
      _filteredServers.removeWhere(
        (server) =>
            server['url']?.trim().toLowerCase() == url.trim().toLowerCase(),
      );
    });
  }

  // 开始ping测试
  void _startPingTest() {
    _pingTimer?.cancel();

    // 为所有服务器运行一次ping测试
    for (var server in _filteredServers) {
      _pingServer(server['url']!);
    }
  }

  // ping单个服务器
  Future<void> _pingServer(String url) async {
    try {
      final pingResult = await PingUtil.ping(url);
      if (mounted) {
        setState(() {
          _pingResults[url] = pingResult ?? -1; // 使用-1表示超时
          // 每次ping完成后立即排序
          _sortServersByLatency();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pingResults[url] = -1; // 异常情况标记为无法连接
          // 每次ping完成后立即排序
          _sortServersByLatency();
        });
      }
    }
  }

  // 根据延迟排序服务器列表
  void _sortServersByLatency() {
    _filteredServers.sort((a, b) {
      final pingA = _pingResults[a['url']!] ?? 999999;
      final pingB = _pingResults[b['url']!] ?? 999999;

      // 处理超时情况(-1)，将其视为最大延迟
      final latencyA = pingA == -1 ? 999999 : pingA;
      final latencyB = pingB == -1 ? 999999 : pingB;

      return latencyA.compareTo(latencyB);
    });
  }
}

class _PublicServerItem extends StatefulWidget {
  final Map<String, String> server;
  final VoidCallback onAdd;
  final int? pingResult;

  const _PublicServerItem({
    Key? key,
    required this.server,
    required this.onAdd,
    this.pingResult,
  }) : super(key: key);

  @override
  _PublicServerItemState createState() => _PublicServerItemState();
}

class _PublicServerItemState extends State<_PublicServerItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), // 统一圆角
          color:
              (theme.brightness == Brightness.light)
                  ? colorScheme.surfaceVariant.withOpacity(1.0)
                  : colorScheme.surfaceVariant.withOpacity(1.0),
          border: Border.all(
            color: _isHovered ? colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            title: Text(
              widget.server['name']!,
              style: TextStyle(
                fontSize: 16, // 统一字体大小
                color: colorScheme.onSurface,
              ),
            ),
            subtitle: Row(
              children: [
                // 延迟显示
                if (widget.pingResult != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: _getPingColor(widget.pingResult),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.pingResult == -1 ? '超时' : '${widget.pingResult}ms',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
                Expanded(
                  child: Text(
                    widget.server['url']!,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            trailing: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: widget.onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('添加', style: TextStyle(fontSize: 12)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 根据ping结果获取颜色
  Color _getPingColor(int? ping) {
    if (ping == null || ping == -1) return Colors.red;
    return ping < 100
        ? Colors.green
        : (ping < 300 ? Colors.orange : Colors.red);
  }
}
