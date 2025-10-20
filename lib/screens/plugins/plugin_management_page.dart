import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/plugin_system/plugin_manager.dart';
import '../../core/plugin_system/plugin_interface.dart';

/// 插件管理页面
class PluginManagementPage extends StatefulWidget {
  const PluginManagementPage({Key? key}) : super(key: key);

  @override
  State<PluginManagementPage> createState() => _PluginManagementPageState();
}

class _PluginManagementPageState extends State<PluginManagementPage> {
  final PluginManager _pluginManager = PluginManager();
  bool _isLoading = true;
  String? _errorMessage;
  bool _isInstalling = false;

  @override
  void initState() {
    super.initState();
    _initializePluginManager();
  }

  /// 初始化插件管理器
  Future<void> _initializePluginManager() async {
    try {
      print('[PluginPage] 初始化插件管理器开始');
      await _pluginManager.initialize();
      print('[PluginPage] 初始化完成，已加载插件数: ${_pluginManager.plugins.length}');
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '插件管理器初始化失败: $e';
      });
      print('[PluginPage] 初始化失败: $e');
    }
  }

  /// 安装插件
  Future<void> _installPlugin() async {
    try {
      // 选择插件目录
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: '选择插件目录',
      );

      if (selectedDirectory == null) {
        return; // 用户取消选择
      }

      setState(() {
        _isInstalling = true;
      });

      // 安装插件
      final success = await _pluginManager.installPluginFromDirectory(selectedDirectory);

      setState(() {
        _isInstalling = false;
      });

      if (success) {
        // 刷新插件列表
        await _refreshPlugins();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('插件安装成功'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('插件安装失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isInstalling = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('安装插件时发生错误: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 刷新插件列表
  Future<void> _refreshPlugins() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      print('[PluginPage] 刷新插件列表');
      // 重新初始化插件管理器
      await _pluginManager.dispose();
      await _pluginManager.initialize();
      print('[PluginPage] 刷新完成，当前插件数: ${_pluginManager.plugins.length}');
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '刷新插件列表失败: $e';
      });
      print('[PluginPage] 刷新失败: $e');
    }
  }

  /// 切换插件启用状态
  Future<void> _togglePlugin(String pluginId, bool enabled) async {
    try {
      bool success;
      if (enabled) {
        success = await _pluginManager.enablePlugin(pluginId);
      } else {
        success = await _pluginManager.disablePlugin(pluginId);
      }
      
      if (success) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enabled ? '插件已启用' : '插件已禁用'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enabled ? '启用插件失败' : '禁用插件失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('操作失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// 卸载插件
  Future<void> _uninstallPlugin(String pluginId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认卸载'),
        content: const Text('确定要卸载这个插件吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('卸载'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _pluginManager.uninstallPlugin(pluginId);
        if (success) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('插件已卸载'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('卸载插件失败'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('卸载失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 重新加载插件
  Future<void> _reloadPlugin(String pluginId) async {
    try {
      final success = await _pluginManager.reloadPlugin(pluginId);
      if (success) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('插件已重新加载'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('重新加载插件失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('重新加载失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('插件管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _isInstalling ? null : _installPlugin,
            tooltip: '安装插件',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPlugins,
            tooltip: '刷新',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshPlugins,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    final plugins = _pluginManager.pluginMetadata;
    
    if (plugins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.extension_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无插件',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击右上角的 + 按钮安装插件',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isInstalling ? null : _installPlugin,
              icon: _isInstalling 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
              label: Text(_isInstalling ? '安装中...' : '安装插件'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plugins.length,
      itemBuilder: (context, index) {
        final pluginId = plugins.keys.elementAt(index);
        final metadata = plugins[pluginId]!;
        final isEnabled = _pluginManager.isPluginEnabled(pluginId);
        
        return _buildPluginCard(pluginId, metadata, isEnabled);
      },
    );
  }

  Widget _buildPluginCard(String pluginId, PluginMetadata metadata, bool isEnabled) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metadata.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'v${metadata.version} • ${metadata.author}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isEnabled,
                  onChanged: (value) => _togglePlugin(pluginId, value),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              metadata.description,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            if (metadata.permissions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: metadata.permissions.map((permission) {
                  return Chip(
                    label: Text(
                      permission,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.blue[50],
                    side: BorderSide(color: Colors.blue[200]!),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _reloadPlugin(pluginId),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('重新加载'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _uninstallPlugin(pluginId),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('卸载'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}