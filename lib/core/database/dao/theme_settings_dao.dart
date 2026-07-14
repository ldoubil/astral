import 'package:isar_community/isar.dart';
import 'package:astral/core/models/theme_settings.dart';

/// 单例 [ThemeSettings] 的 Isar 访问（id 固定为 1）。
class ThemeSettingsDao {
  static const int _id = 1;

  final Isar _isar;

  ThemeSettingsDao(this._isar) {
    init();
  }

  Future<ThemeSettings?> getOrNull() => _isar.themeSettings.get(_id);

  Future<ThemeSettings> get() async {
    final settings = await getOrNull();
    if (settings == null) {
      throw StateError('ThemeSettings not initialized');
    }
    return settings;
  }

  Future<void> save(ThemeSettings settings) async {
    settings.id = _id;
    await _isar.writeTxn(() async {
      await _isar.themeSettings.put(settings);
    });
  }

  Future<void> update(void Function(ThemeSettings settings) mutate) async {
    final settings = await getOrNull();
    if (settings == null) return;
    mutate(settings);
    await save(settings);
  }

  Future<void> init() async {
    if (await _isar.themeSettings.count() > 0) return;
    await save(ThemeSettings());
  }
}
