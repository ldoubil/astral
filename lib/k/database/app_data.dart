import 'dart:io';
import 'package:astral/k/models/all_settings.dart';
import 'package:astral/k/models/net_config.dart';
import 'package:astral/k/models/room.dart';
import 'package:astral/k/models/server_mod.dart';
import 'package:astral/k/models/wfp_model.dart';
import 'package:astral/k/models_mod/all_settings_cz.dart';
import 'package:astral/k/models_mod/net_config_cz.dart';
import 'package:astral/k/models_mod/room_cz.dart';
import 'package:astral/k/models_mod/server_cz.dart';
import 'package:astral/k/models_mod/wfp_model_cz.dart';
import 'package:isar_community/isar.dart';
import 'package:astral/k/models/theme_settings.dart';
import 'package:astral/k/models_mod/theme_settings_cz.dart';
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
  late final WfpModelCz WfpModelSetting;

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
      WfpModelSchema,
    ], directory: dbDir);
    themeSettings = ThemeSettingsRepository(isar);
    netConfigSetting = NetConfigRepository(isar);
    RoomSetting = RoomCz(isar);
    AllSettings = AllSettingsCz(isar);
    ServerSetting = ServerCz(isar);
    WfpModelSetting = WfpModelCz(isar);
  }
}
