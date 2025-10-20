import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Flutter API方法的参数类型
enum ApiParamType {
  string,
  number,
  boolean,
  object,
  array,
  any,
}

/// Flutter API方法的返回类型
enum ApiReturnType {
  void_,
  string,
  number,
  boolean,
  object,
  future,
}

/// Flutter API方法定义
class FlutterApiMethod {
  final String name;
  final String description;
  final List<ApiParamType> paramTypes;
  final ApiReturnType returnType;
  final Function handler;
  final bool isAsync;

  const FlutterApiMethod({
    required this.name,
    required this.description,
    required this.paramTypes,
    required this.returnType,
    required this.handler,
    this.isAsync = false,
  });
}

/// 自动化的Flutter API注册器
class FlutterApiRegistry {
  final Map<String, FlutterApiMethod> _methods = {};
  final String _pluginName;
  final Function(String) _debugLogger;

  FlutterApiRegistry(this._pluginName, this._debugLogger);

  /// 获取已注册的方法列表
  Map<String, FlutterApiMethod> get registeredMethods => Map.unmodifiable(_methods);

  /// 注册API方法
  void registerMethod(FlutterApiMethod method) {
    _methods[method.name] = method;
  }

  /// 批量注册默认API方法
  void registerDefaultMethods(Map<String, dynamic> config) {
    // 日志API
    registerMethod(FlutterApiMethod(
      name: 'log',
      description: '输出日志信息',
      paramTypes: [ApiParamType.any],
      returnType: ApiReturnType.void_,
      handler: (List<dynamic> args) {
        final message = _convertToString(args.isNotEmpty ? args[0] : '');
        print('[$_pluginName] $message');
      },
    ));

    // 通知API
    registerMethod(FlutterApiMethod(
      name: 'showNotification',
      description: '显示通知',
      paramTypes: [ApiParamType.string],
      returnType: ApiReturnType.void_,
      handler: (List<dynamic> args) {
        final message = _convertToString(args.isNotEmpty ? args[0] : '');
        print('通知: $message');
        // 这里可以集成真实的通知系统
      },
    ));

    // 对话框API
    registerMethod(FlutterApiMethod(
      name: 'showDialog',
      description: '显示对话框',
      paramTypes: [ApiParamType.string, ApiParamType.string],
      returnType: ApiReturnType.void_,
      handler: (List<dynamic> args) {
        final title = _convertToString(args.isNotEmpty ? args[0] : '');
        final message = _convertToString(args.length > 1 ? args[1] : '');
        print('对话框: $title - $message');
        // 这里可以集成真实的对话框系统
      },
    ));

    // HTTP GET API
    registerMethod(FlutterApiMethod(
      name: 'httpGet',
      description: '发送HTTP GET请求',
      paramTypes: [ApiParamType.string],
      returnType: ApiReturnType.future,
      isAsync: true,
      handler: (List<dynamic> args) async {
        try {
          final url = _convertToString(args.isNotEmpty ? args[0] : '');
          if (url.isEmpty) {
            return jsonEncode({'error': 'URL is required'});
          }
          
          final client = HttpClient();
          final request = await client.getUrl(Uri.parse(url));
          final response = await request.close();
          final responseBody = await response.transform(utf8.decoder).join();
          client.close();
          return responseBody;
        } catch (e) {
          _debugLogger('[Error] httpGet: $e');
          return jsonEncode({'error': e.toString()});
        }
      },
    ));

    // 数据存储API
    registerMethod(FlutterApiMethod(
      name: 'getData',
      description: '获取存储的数据',
      paramTypes: [ApiParamType.string],
      returnType: ApiReturnType.object,
      handler: (List<dynamic> args) {
        final key = _convertToString(args.isNotEmpty ? args[0] : '');
        return config[key];
      },
    ));

    registerMethod(FlutterApiMethod(
      name: 'setData',
      description: '设置存储的数据',
      paramTypes: [ApiParamType.string, ApiParamType.any],
      returnType: ApiReturnType.void_,
      handler: (List<dynamic> args) {
        if (args.length >= 2) {
          final key = _convertToString(args[0]);
          final value = args[1];
          config[key] = value;
        }
      },
    ));
  }

  /// 安全地转换参数为字符串
  String _convertToString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is List) {
      return value.map((e) => e?.toString() ?? '').join(' ');
    }
    return value.toString();
  }

  /// 验证参数类型
  bool _validateParams(List<dynamic> args, List<ApiParamType> expectedTypes) {
    if (args.length < expectedTypes.length) {
      return false;
    }

    for (int i = 0; i < expectedTypes.length; i++) {
      final arg = args[i];
      final expectedType = expectedTypes[i];

      switch (expectedType) {
        case ApiParamType.string:
          if (arg != null && arg is! String) return false;
          break;
        case ApiParamType.number:
          if (arg != null && arg is! num) return false;
          break;
        case ApiParamType.boolean:
          if (arg != null && arg is! bool) return false;
          break;
        case ApiParamType.array:
          if (arg != null && arg is! List) return false;
          break;
        case ApiParamType.object:
          if (arg != null && arg is! Map) return false;
          break;
        case ApiParamType.any:
          // 任何类型都可以
          break;
      }
    }
    return true;
  }

  /// 处理API调用
  Future<dynamic> handleApiCall(String methodName, List<dynamic> args) async {
    final method = _methods[methodName];
    if (method == null) {
      _debugLogger('[Error] Unknown API method: $methodName');
      return null;
    }

    try {
      // 验证参数
      if (!_validateParams(args, method.paramTypes)) {
        _debugLogger('[Error] Invalid parameters for $methodName');
        return null;
      }

      _debugLogger('[API] Calling $methodName with args: $args');

      // 调用处理函数
      if (method.isAsync) {
        return await method.handler(args);
      } else {
        return method.handler(args);
      }
    } catch (e) {
      _debugLogger('[Error] API call failed for $methodName: $e');
      return null;
    }
  }

  /// 生成JavaScript包装器代码
  String generateJavaScriptWrapper() {
    final buffer = StringBuffer();
    buffer.writeln('// 自动生成的Flutter API包装器');
    buffer.writeln('const flutter = {');

    for (final method in _methods.values) {
      buffer.writeln('  /**');
      buffer.writeln('   * ${method.description}');
      buffer.writeln('   * @param {...*} args - 方法参数');
      if (method.returnType == ApiReturnType.future) {
        buffer.writeln('   * @returns {Promise} 异步结果');
      }
      buffer.writeln('   */');

      if (method.isAsync) {
        buffer.writeln('  ${method.name}: async function(...args) {');
        buffer.writeln('    try {');
        buffer.writeln('      return await sendMessage("${method.name}", args);');
        buffer.writeln('    } catch (e) {');
        buffer.writeln('      console.error("flutter.${method.name} error:", e);');
        buffer.writeln('      return null;');
        buffer.writeln('    }');
        buffer.writeln('  },');
      } else {
        buffer.writeln('  ${method.name}: function(...args) {');
        buffer.writeln('    try {');
        buffer.writeln('      return sendMessage("${method.name}", args);');
        buffer.writeln('    } catch (e) {');
        buffer.writeln('      console.error("flutter.${method.name} error:", e);');
        if (method.returnType == ApiReturnType.void_) {
          buffer.writeln('      return;');
        } else {
          buffer.writeln('      return null;');
        }
        buffer.writeln('    }');
        buffer.writeln('  },');
      }
      buffer.writeln();
    }

    buffer.writeln('};');
    return buffer.toString();
  }

  /// 获取所有注册的方法名
  List<String> getRegisteredMethods() {
    return _methods.keys.toList();
  }

  /// 获取方法信息
  FlutterApiMethod? getMethod(String name) {
    return _methods[name];
  }
}