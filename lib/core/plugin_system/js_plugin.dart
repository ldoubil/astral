import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_js/flutter_js.dart';
import 'package:path/path.dart' as path;
import 'plugin_interface.dart';
import 'flutter_api_registry.dart';
import 'api_extensions.dart';

/// 基于JavaScript的插件实现
class JSPlugin implements PluginInterface {
  final PluginMetadata _metadata;
  final String _pluginPath;
  late JavascriptRuntime _jsRuntime;
  late FlutterApiRegistry _apiRegistry;
  PluginStatus _status = PluginStatus.uninitialized;
  final StreamController<PluginStatus> _statusController = StreamController<PluginStatus>.broadcast();
  Map<String, dynamic> _config = {};

  JSPlugin(this._metadata, this._pluginPath);

  @override
  String get id => _metadata.id;

  @override
  String get name => _metadata.name;

  @override
  String get version => _metadata.version;

  @override
  String get author => _metadata.author;

  @override
  String get description => _metadata.description;

  @override
  bool get isEnabled => _status == PluginStatus.running;

  @override
  Stream<PluginStatus> get statusStream => _statusController.stream;

  /// 更新插件状态
  void _updateStatus(PluginStatus status) {
    _status = status;
    _statusController.add(status);
  }

  /// 追加调试日志到插件目录下的 .debug.log
  void _appendDebug(String line) {
    try {
      final dbg = File(path.join(_pluginPath, '.debug.log'));
      dbg.writeAsStringSync(line + '\n', mode: FileMode.append);
    } catch (_) {}
  }

  @override
  Future<bool> initialize() async {
    try {
      _updateStatus(PluginStatus.initializing);

      print('[JSPlugin] 初始化插件: ${_metadata.id} at $_pluginPath');
      _appendDebug('[Init] plugin=${_metadata.id} path=$_pluginPath');

      // 创建JavaScript运行时
      _jsRuntime = getJavascriptRuntime();

      // 初始化API注册器
      _apiRegistry = FlutterApiRegistry(_metadata.name, _appendDebug);
      _apiRegistry.registerDefaultMethods(_config);
      
      // 注册API扩展
      final extensionManager = ApiExtensionManager();
      extensionManager.registerDefaultExtensions();
      extensionManager.applyExtensions(_apiRegistry);

      // 注册Flutter API到JavaScript环境
      _registerFlutterAPIs();

      // 加载插件JavaScript代码
      await _loadPluginScript();
      _appendDebug('[Init] after load script');

      // 调用插件的初始化函数
      final result = _jsRuntime.evaluate('typeof init === "function" ? init() : true');

      // 安全地处理JavaScript返回值
      bool success = false;
      if (result.isError) {
        print('插件初始化时JavaScript执行错误: ${result.rawResult}');
        _appendDebug('[Error] init js error: ${result.rawResult}');
        success = false;
      } else {
        // 尝试将结果转换为布尔值
        final rawResult = result.rawResult;
        print('[JSPlugin] 调用 init 结果: $rawResult');
        _appendDebug('[Init] result=${rawResult?.toString() ?? 'null'}');
        if (rawResult is bool) {
          success = rawResult;
        } else if (rawResult is num) {
          success = rawResult != 0;
        } else if (rawResult is String) {
          success = rawResult.toLowerCase() == 'true';
        } else {
          success = rawResult != null;
        }
      }

      if (success) {
        _updateStatus(PluginStatus.initialized);
        return true;
      } else {
        _updateStatus(PluginStatus.error);
        _appendDebug('[Error] init result indicates failure');
        return false;
      }
    } catch (e) {
      print('[JSPlugin] 初始化失败: $e');
      _appendDebug('[Error] init failed: ${e.toString()}');
      _updateStatus(PluginStatus.error);
      return false;
    }
  }

  @override
  Future<void> start() async {
    if (_status != PluginStatus.initialized) {
      throw StateError('插件必须先初始化才能启动');
    }

    try {
      _updateStatus(PluginStatus.starting);

      // 调用插件的启动函数
      _jsRuntime.evaluate('typeof start === "function" && start()');

      _updateStatus(PluginStatus.running);
    } catch (e) {
      print('插件启动失败: $e');
      _appendDebug('[Error] start failed: ${e.toString()}');
      _updateStatus(PluginStatus.error);
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    if (_status != PluginStatus.running) {
      return;
    }

    try {
      _updateStatus(PluginStatus.stopping);

      // 调用插件的停止函数
      _jsRuntime.evaluate('typeof stop === "function" && stop()');

      _updateStatus(PluginStatus.stopped);
    } catch (e) {
      print('插件停止失败: $e');
      _appendDebug('[Error] stop failed: ${e.toString()}');
      _updateStatus(PluginStatus.error);
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      // 先停止插件
      if (_status == PluginStatus.running) {
        await stop();
      }

      // 调用插件的清理函数
      _jsRuntime.evaluate('typeof cleanup === "function" && cleanup()');

      // 销毁JavaScript运行时
      _jsRuntime.dispose();

      _updateStatus(PluginStatus.disposed);
      await _statusController.close();
    } catch (e) {
      print('插件销毁失败: $e');
      _appendDebug('[Error] dispose failed: ${e.toString()}');
      _updateStatus(PluginStatus.error);
    }
  }

  @override
  Map<String, dynamic> getConfig() {
    return Map<String, dynamic>.from(_config);
  }

  @override
  void setConfig(Map<String, dynamic> config) {
    _config = Map<String, dynamic>.from(config);

    // 将配置传递给JavaScript环境
    _jsRuntime.evaluate('if (typeof setConfig === "function") setConfig(${jsonEncode(_config)})');
  }

  /// 将嵌套列表或其他类型转换为字符串
  /// 用于处理JavaScript传递的复杂参数类型
  String _flattenToString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List) {
      return value.map((item) => _flattenToString(item)).join(' ');
    }
    return value.toString();
  }

  /// 安全地转换参数为字符串，处理类型转换错误
  /// 用于防止 List<dynamic> 到 String 的类型转换错误
  String _safeConvertToString(dynamic value) {
    try {
      if (value == null) return '';
      if (value is String) return value;
      if (value is List) {
        return _flattenToString(value);
      }
      return value.toString();
    } catch (e) {
      print('类型转换错误: $e, value: $value, type: ${value.runtimeType}');
      _appendDebug('[Error] _safeConvertToString failed: $e, value: $value');
      return value?.toString() ?? '';
    }
  }

  /// 注册Flutter API到JavaScript环境 - 使用自动化注册器
  void _registerFlutterAPIs() {
    // 为所有注册的API方法创建消息处理器
    for (final methodName in _apiRegistry.getRegisteredMethods()) {
      _jsRuntime.onMessage(methodName, (args) async {
        try {
          // 确保args是List类型
          List<dynamic> argsList;
          if (args == null) {
            argsList = [];
          } else if (args is List) {
            argsList = args;
          } else {
            argsList = [args];
          }

          // 使用API注册器处理调用
          return await _apiRegistry.handleApiCall(methodName, argsList);
        } catch (e) {
          _appendDebug('[Error] API call failed for $methodName: $e');
          return null;
        }
      });
    }
  }

  /// 加载插件JavaScript代码
  Future<void> _loadPluginScript() async {
    final scriptFile = File('$_pluginPath/${_metadata.entryPoint}');
    if (!await scriptFile.exists()) {
      _appendDebug('[Error] script file not exists: ${scriptFile.path}');
      throw FileSystemException('插件脚本文件不存在: ${scriptFile.path}');
    }

    final scriptContent = await scriptFile.readAsString();
    print('[JSPlugin] 读取脚本完成，长度: ${scriptContent.length}');
    _appendDebug('[Script] length=' + scriptContent.length.toString());

    // 使用自动生成的Flutter API包装器
    final wrappedScript = '''
      ${_apiRegistry.generateJavaScriptWrapper()}
      
      // 插件代码
      $scriptContent
    ''';

    _jsRuntime.evaluate(wrappedScript);
    print('[JSPlugin] 脚本执行完成');
    _appendDebug('[Script] executed');
  }

  /// 调用插件方法
  dynamic callPluginMethod(String methodName, [List<dynamic>? args]) {
    try {
      final argsStr = args != null ? jsonEncode(args) : '[]';
      final result = _jsRuntime.evaluate('typeof $methodName === "function" ? $methodName(...$argsStr) : null');
      return result.rawResult;
    } catch (e) {
      print('调用插件方法失败: $methodName, 错误: $e');
      _appendDebug('[Error] callPluginMethod($methodName) ' + e.toString());
      return null;
    }
  }
}