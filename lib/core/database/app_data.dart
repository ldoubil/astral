import 'dart:io';
import 'package:astral/core/models/all_settings.dart';
import 'package:astral/core/models/net_config.dart';
import 'package:astral/core/models/room.dart';
import 'package:astral/core/models/server_mod.dart';
import 'package:astral/core/models/magic_wall_model.dart';
import 'package:astral/core/models/converters/all_settings_converter.dart';
import 'package:astral/core/models/converters/net_config_converter.dart';
import 'package:astral/core/models/converters/room_converter.dart';
import 'package:astral/core/models/converters/server_converter.dart';
import 'package:astral/core/models/converters/magic_wall_converter.dart';
import 'package:isar_community/isar.dart';
import 'package:astral/core/models/theme_settings.dart';
import 'package:astral/core/models/converters/theme_settings_converter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  late final Isar isar;
  late final ThemeSettingsRepository themeSettings;
  late final NetConfigRepository netConfigSetting;
  late final RoomCz RoomSetting;
  late final AllSettingsCz AllSettings;
  late final ServerCz ServerSetting;
  late final MagicWallModelCz MagicWallSetting;

  /// 初始化数据库
  Future<void> init([String? customDbDir]) async {
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
    themeSettings = ThemeSettingsRepository(isar);
    netConfigSetting = NetConfigRepository(isar);
    RoomSetting = RoomCz(isar);
    AllSettings = AllSettingsCz(isar);
    ServerSetting = ServerCz(isar);
    MagicWallSetting = MagicWallModelCz(isar);

    // 确保初始化完成
    await RoomSetting.init();
    await ServerSetting.init();
  }
}
