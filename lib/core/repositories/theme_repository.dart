import 'package:astral/core/database/app_data.dart';
import 'package:astral/core/models/theme_settings.dart';

/// 主题设置持久化（单例 [ThemeSettings]）
class ThemeRepository {
  final AppDatabase _db;

  ThemeRepository(this._db);

  Future<ThemeSettings> get() => _db.themeSettings.get();

  Future<void> update(void Function(ThemeSettings settings) mutate) =>
      _db.themeSettings.update(mutate);
}
