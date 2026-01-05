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
import 'package:astral/core/services/service_manager.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  late Isar isar;
  late ThemeSettingsRepository themeSettings;
  late NetConfigRepository netConfigSetting;
  late RoomCz RoomSetting;
  late AllSettingsCz AllSettings;
  late ServerCz ServerSetting;
  late MagicWallModelCz MagicWallSetting;

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

  /// 导出数据库到指定路径
  Future<String> exportDatabase(String exportPath) async {
    // 获取数据库文件路径（需要在关闭前获取）
    final dbPath = isar.directory!;
    final dbFile = File(path.join(dbPath, 'default.isar'));

    // 关闭当前数据库连接
    await isar.close();

    // 复制数据库文件到导出路径
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final exportFile = File(
      path.join(exportPath, 'astral_backup_$timestamp.isar'),
    );
    await dbFile.copy(exportFile.path);

    // 重新打开数据库
    await init();

    return exportFile.path;
  }

  /// 从文件导入数据库（完全替换）
  /// 导入后会自动重新加载所有服务状态
  Future<void> importDatabase(String importFilePath) async {
    final importFile = File(importFilePath);
    if (!await importFile.exists()) {
      throw Exception('导入文件不存在');
    }

    // 获取数据库目录（需要在关闭前获取）
    final dbPath = isar.directory!;
    final dbFile = File(path.join(dbPath, 'default.isar'));

    // 关闭当前数据库连接
    await isar.close();

    // 备份当前数据库（以防导入失败）
    final backupFile = File(path.join(dbPath, 'default.isar.backup'));
    if (await dbFile.exists()) {
      await dbFile.copy(backupFile.path);
    }

    try {
      // 删除旧数据库文件
      if (await dbFile.exists()) {
        await dbFile.delete();
      }

      // 复制导入文件到数据库位置
      await importFile.copy(dbFile.path);

      // 重新初始化数据库
      await init();

      // 重新加载所有服务数据
      await ServiceManager().reload();

      // 删除备份文件
      if (await backupFile.exists()) {
        await backupFile.delete();
      }
    } catch (e) {
      // 导入失败，恢复备份
      if (await backupFile.exists()) {
        await backupFile.copy(dbFile.path);
        await backupFile.delete();
      }
      await init();
      rethrow;
    }
  }
}
