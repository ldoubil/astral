import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:astral/k/services/service_manager.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _copyAllLogs() {
    final logs = ServiceManager().appSettingsState.logs.value;
    if (logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暂无日志可复制')),
      );
      return;
    }
    
    final allLogsText = logs.join('\n');
    Clipboard.setData(ClipboardData(text: allLogsText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已复制 ${logs.length} 条日志到剪贴板'),
        action: SnackBarAction(
          label: '撤销',
          onPressed: () {
            // 可以添加撤销功能
          },
        ),
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Hero(
          tag: "logs_hero",
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text('日志'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all),
            tooltip: '复制所有日志',
            onPressed: _copyAllLogs,
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: '清空日志',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('确认清空'),
                  content: const Text('确定要清空所有日志吗？'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('取消'),
                    ),
                    TextButton(
                      onPressed: () {
                        ServiceManager().appSettingsState.logs.value = [];
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('日志已清空')),
                        );
                      },
                      child: const Text('确定'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final logs = ServiceManager().appSettingsState.logs.value;
          
          if (logs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '暂无日志',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8.0),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final isError = log.toLowerCase().contains('error') || 
                             log.toLowerCase().contains('错误');
              final isWarning = log.toLowerCase().contains('warning') || 
                               log.toLowerCase().contains('警告');
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 2.0),
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    isError 
                        ? Icons.error_outline
                        : isWarning 
                            ? Icons.warning_amber_outlined
                            : Icons.info_outline,
                    color: isError 
                        ? Colors.red
                        : isWarning 
                            ? Colors.orange
                            : Colors.blue,
                    size: 20,
                  ),
                  title: Text(
                    log,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: isError 
                          ? Colors.red
                          : isWarning 
                              ? Colors.orange
                              : null,
                    ),
                  ),
                  subtitle: Text(
                    '${DateTime.now().toString().substring(0, 19)}',
                    style: const TextStyle(fontSize: 10),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    tooltip: '复制此条日志',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: log));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('日志已复制到剪贴板'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scrollToBottom,
        tooltip: '滚动到底部',
        heroTag: "logs_fab", // 使用唯一标识
        child: const Icon(Icons.keyboard_arrow_down),
      ),
    );
  }
}