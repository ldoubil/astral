import 'package:astral/core/database/app_data.dart';
import 'package:astral/core/models/net_config.dart';

/// 网络配置持久化（单例 [NetConfig]）
class NetworkConfigRepository {
  final AppDatabase _db;

  NetworkConfigRepository(this._db);

  Future<NetConfig> get() => _db.netConfig.get();

  Future<void> update(void Function(NetConfig config) mutate) =>
      _db.netConfig.update(mutate);

  Future<bool> getAutoSetMTU() async => (await _db.allSettings.get()).autoSetMTU;

  Future<void> setAutoSetMTU(bool value) =>
      _db.allSettings.update((s) => s.autoSetMTU = value);
}
