import 'dart:io';

import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

// 全局数据库实例（对外暴露）
late final Store store;

// 初始化数据库
Future<void> initObjectBox({String? customDbDir}) async {
  // 获取数据库存储路径
  String dbPath;
  if (customDbDir != null) {
    // 使用自定义数据库目录
    dbPath = customDbDir;
  } else if (Platform.isAndroid) {
    // Android平台使用应用专属目录
    final appDocDir = await getApplicationDocumentsDirectory();
    dbPath = path.join(appDocDir.path, 'objectbox');
  } else if (Platform.isWindows) {
    // Windows平台使用应用数据目录
    final appSupportDir = await getApplicationSupportDirectory();
    dbPath = path.join(appSupportDir.path, 'astral', 'objectbox');
  } else {
    // 其他平台（如Linux, macOS）统一使用用户数据目录
    final homeDir = Platform.environment['HOME'] ?? '.';
    dbPath = path.join(homeDir, '.local', 'share', 'astral', 'objectbox');
  }


}
    