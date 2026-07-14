import 'dart:io';
import 'package:astral/core/models/all_settings.dart';
import 'package:astral/core/models/net_config.dart';
import 'package:astral/core/models/room.dart';
import 'package:astral/core/models/server_mod.dart';
import 'package:astral/core/models/magic_wall_model.dart';
import 'package:astral/core/database/dao/all_settings_dao.dart';
import 'package:astral/core/database/dao/net_config_dao.dart';
import 'package:astral/core/database/dao/room_dao.dart';
import 'package:astral/core/database/dao/server_dao.dart';
import 'package:astral/core/database/dao/magic_wall_dao.dart';
import 'package:isar_community/isar.dart';
import 'package:astral/core/models/theme_settings.dart';
import 'package:astral/core/database/dao/theme_settings_dao.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  late Isar isar;
  late ThemeSettingsDao themeSettings;
  late NetConfigDao netConfig;
  late RoomDao rooms;
  late AllSettingsDao allSettings;
  late ServerDao servers;
  late MagicWallDao magicWall;
  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// 初始化数据库
  Future<void> init([String? customDbDir]) async {
    if (_initialized) return;
    late final String dbDir;

    if (customDbDir != null) {
      // 使用自定义数据库目录
      dbDir = customDbDir;
    } else if (Platform.isAndroid) {
      // Android平台使用应用专属目录
      final appDocDir = await getApplicationDocumentsDirectory();
      dbDir = Directory(path.join(appDocDir.path, 'db')).path;
    } else if (Platform.isLinux) {
      // Linux平台使用用户数据目录
      final homeDir = Platform.environment['HOME'] ?? '.';
      dbDir =
          Directory(path.join(homeDir, '.local', 'share', 'astral', 'db')).path;
    } else if (Platform.isMacOS) {
      // macOS平台使用应用支持目录
      final appSupportDir = await getApplicationSupportDirectory();
      dbDir = Directory(path.join(appSupportDir.path, 'astral', 'db')).path;
    } else {
      // 其他平台使用可执行文件所在目录
      final executablePath = Platform.resolvedExecutable;
      final executableDir = Directory(executablePath).parent.path;
      dbDir = Directory(path.join(executableDir, 'data', 'db')).path;
    }

    // 确保数据库目录存在
    await Directory(dbDir).create(recursive: true);
    isar = await Isar.open([
      ThemeSettingsSchema,
      NetConfigSchema,
      RoomSchema,
      AllSettingsSchema,
      ServerModSchema,
      MagicWallRuleModelSchema,
      MagicWallGroupModelSchema,
      MagicWallEventLogModelSchema,
    ], directory: dbDir);
    themeSettings = ThemeSettingsDao(isar);
    netConfig = NetConfigDao(isar);
    rooms = RoomDao(isar);
    allSettings = AllSettingsDao(isar);
    servers = ServerDao(isar);
    magicWall = MagicWallDao(isar);

    // 确保初始化完成
    await rooms.init();
    await servers.init();
    _initialized = true;
  }
}

