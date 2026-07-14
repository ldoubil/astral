import 'package:astral/core/database/app_data.dart';
import 'package:astral/core/models/all_settings.dart';

/// 应用设置持久化（单例 [AllSettings]）
class AppSettingsRepository {
  final AppDatabase _db;

  AppSettingsRepository(this._db);

  Future<AllSettings> get() => _db.allSettings.get();

  Future<void> update(void Function(AllSettings settings) mutate) =>
      _db.allSettings.update(mutate);

  Future<String> getPlayerName() => _db.allSettings.getPlayerName();

  Future<List<String>> getListenList() => _db.allSettings.getListenList();
}
