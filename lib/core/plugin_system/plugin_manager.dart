import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'plugin_interface.dart';
import 'js_plugin.dart';

/// 插件管理器
/// 负责插件的加载、管理和生命周期控制
class PluginManager {
  static final PluginManager _instance = PluginManager._internal();
  factory PluginManager() => _instance;
  static PluginManager get instance => _instance;
  PluginManager._internal();

  final Map<String, PluginInterface> _plugins = {};
  final Map<String, PluginMetadata> _pluginMetadata = {};
  final Map<String, bool> _pluginEnabledState = {};
  StreamController<PluginManagerEvent> _eventController = StreamController<PluginManagerEvent>.broadcast();
  
  String _pluginsDirectory = 'plugins';
  bool _isInitialized = false;

  /// 插件管理器事件流
  Stream<PluginManagerEvent> get eventStream => _eventController.stream;

  /// 获取所有已加载的插件
  Map<String, PluginInterface> get plugins => Map.unmodifiable(_plugins);

  /// 获取所有插件元数据
  Map<String, PluginMetadata> get pluginMetadata => Map.unmodifiable(_pluginMetadata);

  /// 设置插件目录
  void setPluginsDirectory(String directory) {
    _pluginsDirectory = directory;
  }

  /// 初始化插件管理器
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 如果事件控制器已关闭，重新创建
      if (_eventController.isClosed) {
        _eventController = StreamController<PluginManagerEvent>.broadcast();
      }
      
      _emitEvent(PluginManagerEvent.initializing());
      
      // 记录当前工作目录与插件目录
      final cwd = Directory.current.path;
      final pluginsDir = Directory(_pluginsDirectory);
      final dbgFile = File(path.join(_pluginsDirectory, '.debug.log'));
      await dbgFile.create(recursive: true);
      await dbgFile.writeAsString('[Init] cwd=' + cwd + ' pluginsDir=' + pluginsDir.path + '\n', mode: FileMode.append);
      print('[PluginManager] cwd: ' + cwd);
      print('[PluginManager] configured plugins dir: ' + _pluginsDirectory);
      print('[PluginManager] resolved plugins dir: ' + pluginsDir.path);
      
      // 确保插件目录存在
      if (!await pluginsDir.exists()) {
        await pluginsDir.create(recursive: true);
        print('[PluginManager] plugins dir created: ' + pluginsDir.path);
        await dbgFile.writeAsString('[Init] plugins dir created: ' + pluginsDir.path + '\n', mode: FileMode.append);
      }

      // 扫描并加载所有插件
      await dbgFile.writeAsString('[Scan] begin listing: ' + pluginsDir.path + '\n', mode: FileMode.append);
      await _scanPlugins();
      
      // 加载插件启用状态
      await _loadPluginStates();
      await dbgFile.writeAsString('[State] enabled=' + jsonEncode(_pluginEnabledState) + '\n', mode: FileMode.append);
      
      // 自动启动已启用的插件
      await _startEnabledPlugins();

      _isInitialized = true;
      _emitEvent(PluginManagerEvent.initialized());
      
      print('插件管理器初始化完成，共加载 ${_plugins.length} 个插件');
      await dbgFile.writeAsString('[Init] done, loaded=' + _plugins.length.toString() + '\n', mode: FileMode.append);
    } catch (e) {
      _emitEvent(PluginManagerEvent.error('插件管理器初始化失败: $e'));
      try {
        final dbgFile = File(path.join(_pluginsDirectory, '.debug.log'));
        await dbgFile.writeAsString('[Error] initialize failed: ' + e.toString() + '\n', mode: FileMode.append);
      } catch (_) {}
      rethrow;
    }
  }

  /// 扫描插件目录
  Future<void> _scanPlugins() async {
    final pluginsDir = Directory(_pluginsDirectory);
    if (!await pluginsDir.exists()) return;

    print('扫描插件目录: ${pluginsDir.path}');
    int scanned = 0;
    await for (final entity in pluginsDir.list()) {
      if (entity is Directory) {
        scanned++;
        print('发现插件目录: ${entity.path}');
        try {
          final dbgFile = File(path.join(_pluginsDirectory, '.debug.log'));
          await dbgFile.writeAsString('[Scan] found dir: ' + entity.path + '\n', mode: FileMode.append);
        } catch (_) {}
        await _loadPlugin(entity.path);
      } else {
        print('忽略非目录项: ${entity.path}');
      }
    }
    print('扫描完成，共发现插件目录: $scanned');

    // 若未发现任何插件目录，尝试递归列出内容帮助诊断
    if (scanned == 0) {
      print('[PluginManager] 未发现插件目录，递归列出内容以供排查：');
      try {
        final dbgFile = File(path.join(_pluginsDirectory, '.debug.log'));
        await dbgFile.writeAsString('[Scan] none found, recursive listing...\n', mode: FileMode.append);
        int count = 0;
        await for (final entity in pluginsDir.list(recursive: true)) {
          count++;
          print(' - ${entity.path}');
          await dbgFile.writeAsString(' - ' + entity.path + '\n', mode: FileMode.append);
          if (count >= 50) {
            print(' ... 仅显示前 50 项');
            await dbgFile.writeAsString(' ... 仅显示前 50 项\n', mode: FileMode.append);
            break;
          }
        }
      } catch (e) {
        print('[PluginManager] 递归列目录失败: $e');
      }
    }
  }

  /// 加载单个插件
  Future<void> _loadPlugin(String pluginPath) async {
    try {
      print('开始加载插件: $pluginPath');
      try {
        final dbgFile = File(path.join(_pluginsDirectory, '.debug.log'));
        await dbgFile.writeAsString('[Load] begin: ' + pluginPath + '\n', mode: FileMode.append);
      } catch (_) {}
      // 读取插件清单文件
      final manifestFile = File(path.join(pluginPath, 'manifest.json'));
      if (!await manifestFile.exists()) {
        print('插件清单文件不存在: ${manifestFile.path}');
        try {
          final dbgFile = File(path.join(_pluginsDirectory, '.debug.log'));
          await dbgFile.writeAsString('[Load] manifest missing: ' + manifestFile.path + '\n', mode: FileMode.append);
        } catch (_) {}
        return;
      }

      final manifestContent = await manifestFile.readAsString();
      print('manifest.json 内容长度: ${manifestContent.length}');
      final manifestJson = jsonDecode(manifestContent) as Map<String, dynamic>;
      final metadata = PluginMetadata.fromJson(manifestJson);
      print('解析元数据: id=${metadata.id}, name=${metadata.name}, entry=${metadata.entryPoint}');

      // 检查插件是否已存在
      if (_plugins.containsKey(metadata.id)) {
        print('插件已存在: ${metadata.id}');
        return;
      }

      // 验证插件入口文件
      final entryFile = File(path.join(pluginPath, metadata.entryPoint));
      print('检查入口文件: ${entryFile.path}');
      if (!await entryFile.exists()) {
        print('插件入口文件不存在: ${entryFile.path}');
        try {
          final dbgFile = File(path.join(_pluginsDirectory, '.debug.log'));
          await dbgFile.writeAsString('[Load] entry missing: ' + entryFile.path + '\n', mode: FileMode.append);
        } catch (_) {}
        return;
      }

      // 创建插件实例
      final plugin = JSPlugin(metadata, pluginPath);
      print('创建JSPlugin实例并开始初始化: ${metadata.id}');
      
      // 初始化插件
      final success = await plugin.initialize();
      if (!success) {
        print('插件初始化失败: ${metadata.id}');
        _emitEvent(PluginManagerEvent.error('插件初始化失败: ${metadata.id}'));
        try {
          final dbgFile = File(path.join(_pluginsDirectory, '.debug.log'));
          await dbgFile.writeAsString('[Load] init failed: ' + metadata.id + '\n', mode: FileMode.append);
        } catch (_) {}
        return;
      }

      // 注册插件
      _plugins[metadata.id] = plugin;
      _pluginMetadata[metadata.id] = metadata;
      
      _emitEvent(PluginManagerEvent.pluginLoaded(metadata.id));
      print('插件加载成功: ${metadata.name} (${metadata.id})');
      try {
        final dbgFile = File(path.join(_pluginsDirectory, '.debug.log'));
        await dbgFile.writeAsString('[Load] success: ' + metadata.id + '\n', mode: FileMode.append);
      } catch (_) {}
      
    } catch (e, st) {
      print('加载插件失败: $pluginPath, 错误: $e');
      print('堆栈: $st');
      _emitEvent(PluginManagerEvent.error('加载插件失败: $pluginPath - $e'));
      try {
        final dbgFile = File(path.join(_pluginsDirectory, '.debug.log'));
        await dbgFile.writeAsString('[Error] load failed: ' + pluginPath + ' ' + e.toString() + '\n', mode: FileMode.append);
      } catch (_) {}
    }
  }

  /// 启用插件
  Future<bool> enablePlugin(String pluginId) async {
    final plugin = _plugins[pluginId];
    if (plugin == null) {
      print('插件不存在: $pluginId');
      return false;
    }

    try {
      await plugin.start();
      _pluginEnabledState[pluginId] = true;
      await _savePluginStates();
      
      _emitEvent(PluginManagerEvent.pluginEnabled(pluginId));
      print('插件已启用: $pluginId');
      return true;
    } catch (e) {
      print('启用插件失败: $pluginId, 错误: $e');
      _emitEvent(PluginManagerEvent.error('启用插件失败: $e'));
      return false;
    }
  }

  /// 禁用插件
  Future<bool> disablePlugin(String pluginId) async {
    final plugin = _plugins[pluginId];
    if (plugin == null) {
      print('插件不存在: $pluginId');
      return false;
    }

    try {
      await plugin.stop();
      _pluginEnabledState[pluginId] = false;
      await _savePluginStates();
      
      _emitEvent(PluginManagerEvent.pluginDisabled(pluginId));
      print('插件已禁用: $pluginId');
      return true;
    } catch (e) {
      print('禁用插件失败: $pluginId, 错误: $e');
      _emitEvent(PluginManagerEvent.error('禁用插件失败: $e'));
      return false;
    }
  }

  /// 从外部目录安装插件
  /// 
  /// 将插件从源目录复制到plugins目录并加载
  /// [sourcePath] 插件源目录路径
  /// 返回安装是否成功
  Future<bool> installPluginFromDirectory(String sourcePath) async {
    try {
      final sourceDir = Directory(sourcePath);
      if (!await sourceDir.exists()) {
        print('源目录不存在: $sourcePath');
        _emitEvent(PluginManagerEvent.error('源目录不存在'));
        return false;
      }

      // 检查manifest.json文件
      final manifestFile = File(path.join(sourcePath, 'manifest.json'));
      if (!await manifestFile.exists()) {
        print('插件清单文件不存在: ${manifestFile.path}');
        _emitEvent(PluginManagerEvent.error('插件清单文件不存在'));
        return false;
      }

      // 解析插件元数据
      final manifestContent = await manifestFile.readAsString();
      final manifestJson = jsonDecode(manifestContent);
      final metadata = PluginMetadata.fromJson(manifestJson);

      // 检查插件是否已存在
      if (_pluginMetadata.containsKey(metadata.id)) {
        print('插件已存在: ${metadata.id}');
        _emitEvent(PluginManagerEvent.error('插件已存在'));
        return false;
      }

      // 创建目标目录
      final targetPath = path.join(_pluginsDirectory, metadata.id);
      final targetDir = Directory(targetPath);
      if (await targetDir.exists()) {
        await targetDir.delete(recursive: true);
      }
      await targetDir.create(recursive: true);

      // 复制插件文件
      await _copyDirectory(sourceDir, targetDir);

      // 加载插件
      await _loadPlugin(targetPath);

      print('插件安装成功: ${metadata.id}');
      _emitEvent(PluginManagerEvent.pluginLoaded(metadata.id));
      return true;
    } catch (e) {
      print('安装插件失败: $e');
      _emitEvent(PluginManagerEvent.error('安装插件失败: $e'));
      return false;
    }
  }

  /// 递归复制目录
  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await for (final entity in source.list(recursive: false)) {
      if (entity is Directory) {
        final newDirectory = Directory(path.join(destination.path, path.basename(entity.path)));
        await newDirectory.create();
        await _copyDirectory(entity, newDirectory);
      } else if (entity is File) {
        final newFile = File(path.join(destination.path, path.basename(entity.path)));
        await entity.copy(newFile.path);
      }
    }
  }

  /// 卸载插件
  Future<bool> uninstallPlugin(String pluginId) async {
    final plugin = _plugins[pluginId];
    if (plugin == null) {
      print('插件不存在: $pluginId');
      return false;
    }

    try {
      // 先禁用插件
      if (plugin.isEnabled) {
        await disablePlugin(pluginId);
      }
      
      // 销毁插件
      await plugin.dispose();
      
      // 从管理器中移除
      _plugins.remove(pluginId);
      _pluginMetadata.remove(pluginId);
      _pluginEnabledState.remove(pluginId);
      
      await _savePluginStates();
      
      _emitEvent(PluginManagerEvent.pluginUninstalled(pluginId));
      print('插件已卸载: $pluginId');
      return true;
    } catch (e) {
      print('卸载插件失败: $pluginId, 错误: $e');
      _emitEvent(PluginManagerEvent.error('卸载插件失败: $e'));
      return false;
    }
  }

  /// 重新加载插件
  Future<bool> reloadPlugin(String pluginId) async {
    final metadata = _pluginMetadata[pluginId];
    if (metadata == null) {
      print('插件元数据不存在: $pluginId');
      return false;
    }

    try {
      // 先卸载插件
      await uninstallPlugin(pluginId);
      
      // 重新加载插件
      final pluginPath = path.join(_pluginsDirectory, pluginId);
      await _loadPlugin(pluginPath);
      
      // 如果之前是启用状态，重新启用
      if (_pluginEnabledState[pluginId] == true) {
        await enablePlugin(pluginId);
      }
      
      _emitEvent(PluginManagerEvent.pluginReloaded(pluginId));
      print('插件重新加载成功: $pluginId');
      return true;
    } catch (e) {
      print('重新加载插件失败: $pluginId, 错误: $e');
      _emitEvent(PluginManagerEvent.error('重新加载插件失败: $e'));
      return false;
    }
  }

  /// 获取插件状态
  bool isPluginEnabled(String pluginId) {
    return _pluginEnabledState[pluginId] ?? false;
  }

  /// 获取插件实例
  PluginInterface? getPlugin(String pluginId) {
    return _plugins[pluginId];
  }

  /// 调用插件方法
  dynamic callPluginMethod(String pluginId, String methodName, [List<dynamic>? args]) {
    final plugin = _plugins[pluginId];
    if (plugin is JSPlugin) {
      return plugin.callPluginMethod(methodName, args);
    }
    return null;
  }

  /// 加载插件状态
  Future<void> _loadPluginStates() async {
    try {
      final stateFile = File(path.join(_pluginsDirectory, '.plugin_states.json'));
      if (await stateFile.exists()) {
        final content = await stateFile.readAsString();
        final states = jsonDecode(content) as Map<String, dynamic>;
        _pluginEnabledState.addAll(states.cast<String, bool>());
      }
    } catch (e) {
      print('加载插件状态失败: $e');
    }
  }

  /// 保存插件状态
  Future<void> _savePluginStates() async {
    try {
      final stateFile = File(path.join(_pluginsDirectory, '.plugin_states.json'));
      await stateFile.writeAsString(jsonEncode(_pluginEnabledState));
    } catch (e) {
      print('保存插件状态失败: $e');
    }
  }

  /// 启动已启用的插件
  Future<void> _startEnabledPlugins() async {
    for (final pluginId in _pluginEnabledState.keys) {
      if (_pluginEnabledState[pluginId] == true && _plugins.containsKey(pluginId)) {
        await enablePlugin(pluginId);
      }
    }
  }

  /// 发送事件
  void _emitEvent(PluginManagerEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  /// 销毁插件管理器
  Future<void> dispose() async {
    if (!_isInitialized) return;
    
    // 停止所有插件
    for (final plugin in _plugins.values) {
      try {
        await plugin.dispose();
      } catch (e) {
        print('销毁插件失败: $e');
      }
    }
    
    _plugins.clear();
    _pluginMetadata.clear();
    _pluginEnabledState.clear();
    
    if (!_eventController.isClosed) {
      await _eventController.close();
    }
    _isInitialized = false;
  }
}

/// 插件管理器事件
class PluginManagerEvent {
  final String type;
  final String? pluginId;
  final String? message;

  const PluginManagerEvent._(this.type, {this.pluginId, this.message});

  factory PluginManagerEvent.initializing() => const PluginManagerEvent._('initializing');
  factory PluginManagerEvent.initialized() => const PluginManagerEvent._('initialized');
  factory PluginManagerEvent.pluginLoaded(String pluginId) => PluginManagerEvent._('plugin_loaded', pluginId: pluginId);
  factory PluginManagerEvent.pluginEnabled(String pluginId) => PluginManagerEvent._('plugin_enabled', pluginId: pluginId);
  factory PluginManagerEvent.pluginDisabled(String pluginId) => PluginManagerEvent._('plugin_disabled', pluginId: pluginId);
  factory PluginManagerEvent.pluginUninstalled(String pluginId) => PluginManagerEvent._('plugin_uninstalled', pluginId: pluginId);
  factory PluginManagerEvent.pluginReloaded(String pluginId) => PluginManagerEvent._('plugin_reloaded', pluginId: pluginId);
  factory PluginManagerEvent.error(String message) => PluginManagerEvent._('error', message: message);

  @override
  String toString() {
    return 'PluginManagerEvent{type: $type, pluginId: $pluginId, message: $message}';
  }
}