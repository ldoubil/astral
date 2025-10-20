import 'dart:convert';
import 'dart:io';
import 'flutter_api_registry.dart';

/// API扩展接口，允许插件系统扩展新的API
abstract class ApiExtension {
  /// 扩展名称
  String get name;
  
  /// 扩展描述
  String get description;
  
  /// 注册扩展的API方法
  void registerMethods(FlutterApiRegistry registry);
}

/// 文件系统API扩展
class FileSystemApiExtension implements ApiExtension {
  @override
  String get name => 'FileSystem';
  
  @override
  String get description => '文件系统操作API';
  
  @override
  void registerMethods(FlutterApiRegistry registry) {
    // 读取文件
    registry.registerMethod(FlutterApiMethod(
      name: 'readFile',
      description: '读取文件内容',
      paramTypes: [ApiParamType.string],
      returnType: ApiReturnType.future,
      isAsync: true,
      handler: (List<dynamic> args) async {
        try {
          final filePath = args[0].toString();
          final file = File(filePath);
          if (await file.exists()) {
            return await file.readAsString();
          } else {
            return null;
          }
        } catch (e) {
          return null;
        }
      },
    ));
    
    // 写入文件
    registry.registerMethod(FlutterApiMethod(
      name: 'writeFile',
      description: '写入文件内容',
      paramTypes: [ApiParamType.string, ApiParamType.string],
      returnType: ApiReturnType.future,
      isAsync: true,
      handler: (List<dynamic> args) async {
        try {
          final filePath = args[0].toString();
          final content = args[1].toString();
          final file = File(filePath);
          await file.writeAsString(content);
          return true;
        } catch (e) {
          return false;
        }
      },
    ));
    
    // 检查文件是否存在
    registry.registerMethod(FlutterApiMethod(
      name: 'fileExists',
      description: '检查文件是否存在',
      paramTypes: [ApiParamType.string],
      returnType: ApiReturnType.future,
      isAsync: true,
      handler: (List<dynamic> args) async {
        try {
          final filePath = args[0].toString();
          final file = File(filePath);
          return await file.exists();
        } catch (e) {
          return false;
        }
      },
    ));
  }
}

/// 网络API扩展
class NetworkApiExtension implements ApiExtension {
  @override
  String get name => 'Network';
  
  @override
  String get description => '网络请求API';
  
  @override
  void registerMethods(FlutterApiRegistry registry) {
    // HTTP POST请求
    registry.registerMethod(FlutterApiMethod(
      name: 'httpPost',
      description: '发送HTTP POST请求',
      paramTypes: [ApiParamType.string, ApiParamType.object],
      returnType: ApiReturnType.future,
      isAsync: true,
      handler: (List<dynamic> args) async {
        try {
          final url = args[0].toString();
          final data = args.length > 1 ? args[1] : {};
          
          final client = HttpClient();
          final request = await client.postUrl(Uri.parse(url));
          request.headers.contentType = ContentType.json;
          
          if (data != null) {
            final jsonData = jsonEncode(data);
            request.write(jsonData);
          }
          
          final response = await request.close();
          final responseBody = await response.transform(utf8.decoder).join();
          client.close();
          return responseBody;
        } catch (e) {
          return jsonEncode({'error': e.toString()});
        }
      },
    ));
    
    // HTTP PUT请求
    registry.registerMethod(FlutterApiMethod(
      name: 'httpPut',
      description: '发送HTTP PUT请求',
      paramTypes: [ApiParamType.string, ApiParamType.object],
      returnType: ApiReturnType.future,
      isAsync: true,
      handler: (List<dynamic> args) async {
        try {
          final url = args[0].toString();
          final data = args.length > 1 ? args[1] : {};
          
          final client = HttpClient();
          final request = await client.putUrl(Uri.parse(url));
          request.headers.contentType = ContentType.json;
          
          if (data != null) {
            final jsonData = jsonEncode(data);
            request.write(jsonData);
          }
          
          final response = await request.close();
          final responseBody = await response.transform(utf8.decoder).join();
          client.close();
          return responseBody;
        } catch (e) {
          return jsonEncode({'error': e.toString()});
        }
      },
    ));
    
    // HTTP DELETE请求
    registry.registerMethod(FlutterApiMethod(
      name: 'httpDelete',
      description: '发送HTTP DELETE请求',
      paramTypes: [ApiParamType.string],
      returnType: ApiReturnType.future,
      isAsync: true,
      handler: (List<dynamic> args) async {
        try {
          final url = args[0].toString();
          
          final client = HttpClient();
          final request = await client.deleteUrl(Uri.parse(url));
          final response = await request.close();
          final responseBody = await response.transform(utf8.decoder).join();
          client.close();
          return responseBody;
        } catch (e) {
          return jsonEncode({'error': e.toString()});
        }
      },
    ));
  }
}

/// 系统信息API扩展
class SystemApiExtension implements ApiExtension {
  @override
  String get name => 'System';
  
  @override
  String get description => '系统信息API';
  
  @override
  void registerMethods(FlutterApiRegistry registry) {
    // 获取平台信息
    registry.registerMethod(FlutterApiMethod(
      name: 'getPlatform',
      description: '获取当前平台信息',
      paramTypes: [],
      returnType: ApiReturnType.string,
      handler: (List<dynamic> args) {
        return Platform.operatingSystem;
      },
    ));
    
    // 获取环境变量
    registry.registerMethod(FlutterApiMethod(
      name: 'getEnvironment',
      description: '获取环境变量',
      paramTypes: [ApiParamType.string],
      returnType: ApiReturnType.string,
      handler: (List<dynamic> args) {
        final key = args[0].toString();
        return Platform.environment[key];
      },
    ));
    
    // 获取当前时间戳
    registry.registerMethod(FlutterApiMethod(
      name: 'getTimestamp',
      description: '获取当前时间戳',
      paramTypes: [],
      returnType: ApiReturnType.number,
      handler: (List<dynamic> args) {
        return DateTime.now().millisecondsSinceEpoch;
      },
    ));
  }
}

/// API扩展管理器
class ApiExtensionManager {
  final List<ApiExtension> _extensions = [];
  
  /// 注册API扩展
  void registerExtension(ApiExtension extension) {
    _extensions.add(extension);
  }
  
  /// 应用所有扩展到注册器
  void applyExtensions(FlutterApiRegistry registry) {
    for (final extension in _extensions) {
      extension.registerMethods(registry);
    }
  }
  
  /// 获取所有扩展
  List<ApiExtension> get extensions => List.unmodifiable(_extensions);
  
  /// 注册默认扩展
  void registerDefaultExtensions() {
    registerExtension(FileSystemApiExtension());
    registerExtension(NetworkApiExtension());
    registerExtension(SystemApiExtension());
  }
}