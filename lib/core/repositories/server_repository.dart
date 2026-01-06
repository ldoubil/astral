import 'package:astral/core/database/app_data.dart';

/// 服务器管理的数据持久化（现在只管理启用索引列表）
class ServerRepository {
  final AppDatabase _db;

  ServerRepository(this._db);

  // ========== 查询操作 ==========

  /// 获取已启用的服务器索引列表
  Future<List<int>> getEnabledServerIndices() async {
    final settings = await _db.getAllSettingsInstance();
    return settings.enabledServerIndices;
  }

  // ========== 写入操作 ==========

  /// 设置已启用的服务器索引列表
  Future<void> setEnabledServerIndices(List<int> indices) async {
    await _db.updateAllSettings((settings) {
      settings.enabledServerIndices = indices;
    });
  }

  /// 切换某个服务器的启用状态
  Future<void> toggleServerEnabled(int index, bool enabled) async {
    final current = await getEnabledServerIndices();
    final list = List<int>.from(current);

    if (enabled && !list.contains(index)) {
      list.add(index);
    } else if (!enabled && list.contains(index)) {
      list.remove(index);
    }

    await setEnabledServerIndices(list);
  }
}
