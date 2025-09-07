import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'adapters/adapter_manager.dart';

/// 应用数据库配置类
class DBbase {
  static DBbase? _instance;
  static DBbase get instance => _instance ??= DBbase._();

  DBbase._();

  /// 软件数据目录
  late String _dataDirectory;
  String get dataDirectory => _dataDirectory;

  /// Hive数据库目录
  late String _hiveDirectory;
  String get hiveDirectory => _hiveDirectory;

  /// 是否已初始化
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// 初始化数据库
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 获取应用数据目录
      await _initializeDirectories();

      // 初始化Hive
      await _initializeHive();

      _isInitialized = true;
      print('数据库初始化成功: $_dataDirectory');
    } catch (e) {
      print('数据库初始化失败: $e');
      rethrow;
    }
  }

  /// 初始化目录结构
  Future<void> _initializeDirectories() async {
    // 获取应用数据目录（AppData）
    final appDataDir = await getApplicationSupportDirectory();
    _dataDirectory = appDataDir.path;

    // 创建主数据目录
    final dataDir = Directory(_dataDirectory);
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }

    // 创建Hive数据库目录
    _hiveDirectory = '$_dataDirectory/database';
    final hiveDir = Directory(_hiveDirectory);
    if (!await hiveDir.exists()) {
      await hiveDir.create(recursive: true);
    }
  }

  /// 初始化Hive数据库
  Future<void> _initializeHive() async {
    // 初始化Hive Flutter
    await Hive.initFlutter(_hiveDirectory);

    // 注册TypeAdapter（在这里注册所有自定义类型）
    await _registerTypeAdapters();

    // 预先打开常用的boxes，避免UI闪烁
    await _preOpenCommonBoxes();

    print('Hive 数据库初始化完成');
  }

  /// 预先打开常用的boxes
  Future<void> _preOpenCommonBoxes() async {
    final commonBoxes = ['theme', 'app_settings'];
    
    for (final boxName in commonBoxes) {
      try {
        await ensureBoxOpen(boxName);
        print('预打开 box: $boxName');
      } catch (e) {
        print('预打开 box "$boxName" 失败: $e');
        // 继续打开其他box，不因为一个失败而中断
      }
    }
  }

  /// 注册TypeAdapter
  Future<void> _registerTypeAdapters() async {
    AdapterManager.registerAllAdapters();
    print('TypeAdapter注册完成，已注册 ${AdapterManager.getRegisteredAdapterCount()} 个适配器');
  }

  /// 按需打开指定的 Hive box（如果尚未打开）
  Future<Box<T>> ensureBoxOpen<T>(String boxName) async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<T>(boxName);
        print('按需打开 Hive box: $boxName');
      }
      return Hive.box<T>(boxName);
    } catch (e) {
      print('打开 Hive box "$boxName" 失败: $e');
      // 如果是适配器相关错误，尝试删除损坏的box并重新创建
      if (e.toString().contains('unknown typeId') || e.toString().contains('adapter')) {
        print('检测到适配器错误，尝试清理并重新创建 box: $boxName');
        try {
          await Hive.deleteBoxFromDisk(boxName);
          await Hive.openBox<T>(boxName);
          print('成功重新创建 Hive box: $boxName');
          return Hive.box<T>(boxName);
        } catch (cleanupError) {
          print('清理 box 失败: $cleanupError');
        }
      }
      rethrow;
    }
  }

  /// 获取指定名称的box
  Box<T> getBox<T>(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw Exception('Box "$boxName" 未打开，请先调用 openBox');
    }
    return Hive.box<T>(boxName);
  }

  /// 打开新的box
  Future<Box<T>> openBox<T>(String boxName) async {
    try {
      return await Hive.openBox<T>(boxName);
    } catch (e) {
      print('打开box "$boxName" 失败: $e');
      rethrow;
    }
  }

  /// 关闭指定box
  Future<void> closeBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
  }

  /// 删除指定box
  Future<void> deleteBox(String boxName) async {
    try {
      await closeBox(boxName);
      await Hive.deleteBoxFromDisk(boxName);
      print('Box "$boxName" 删除成功');
    } catch (e) {
      print('删除box "$boxName" 失败: $e');
      rethrow;
    }
  }

  /// 清理临时文件
  Future<void> cleanTempFiles() async {
    try {
      final tempDir = Directory('$_dataDirectory/temp');
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
        await tempDir.create();
      }
      print('临时文件清理完成');
    } catch (e) {
      print('清理临时文件失败: $e');
    }
  }

  /// 获取数据库大小
  Future<int> getDatabaseSize() async {
    try {
      final dbDir = Directory(_hiveDirectory);
      if (!await dbDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in dbDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      print('获取数据库大小失败: $e');
      return 0;
    }
  }

  /// 关闭所有数据库连接
  Future<void> dispose() async {
    try {
      await Hive.close();
      _isInitialized = false;
      print('数据库连接已关闭');
    } catch (e) {
      print('关闭数据库连接失败: $e');
    }
  }
}
