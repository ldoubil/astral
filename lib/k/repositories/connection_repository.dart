import 'package:astral/k/database/app_data.dart';
import 'package:astral/k/models/net_config.dart';

/// 连接管理的数据持久化
class ConnectionRepository {
  final AppDatabase _db;

  ConnectionRepository(this._db);

  // ========== 查询操作 ==========

  Future<List<ConnectionManager>> getConnectionManagers() async {
    return await _db.netConfigSetting.getConnectionManagers();
  }

  Future<ConnectionManager?> getConnectionManagerByIndex(int index) async {
    final all = await getConnectionManagers();
    if (index >= 0 && index < all.length) {
      return all[index];
    }
    return null;
  }

  // ========== 写入操作 ==========

  Future<void> addConnectionManager(ConnectionManager manager) async {
    await _db.netConfigSetting.addConnectionManager(manager);
  }

  Future<void> updateConnectionManager(
    int index,
    ConnectionManager manager,
  ) async {
    await _db.netConfigSetting.updateConnectionManager(index, manager);
  }

  Future<void> removeConnectionManager(int index) async {
    await _db.netConfigSetting.removeConnectionManager(index);
  }

  Future<void> updateConnectionManagerEnabled(int index, bool enabled) async {
    await _db.netConfigSetting.updateConnectionManagerEnabled(index, enabled);
  }

  // ========== 批量操作 ==========

  Future<void> batchUpdate(List<ConnectionManager> managers) async {
    for (int i = 0; i < managers.length; i++) {
      await updateConnectionManager(i, managers[i]);
    }
  }

  Future<void> clearAll() async {
    final all = await getConnectionManagers();
    for (int i = all.length - 1; i >= 0; i--) {
      await removeConnectionManager(i);
    }
  }
}
