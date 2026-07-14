import 'package:astral/core/models/net_config.dart';
import 'package:isar_community/isar.dart';

int normalizeSocks5Port(int port) {
  if (port <= 0 || port > 65535) {
    return 1080;
  }
  return port;
}

/// 单例 [NetConfig] 的 Isar 访问（id 固定为 1）。
class NetConfigDao {
  static const int _id = 1;

  final Isar _isar;

  NetConfigDao(this._isar) {
    init();
  }

  Future<NetConfig?> getOrNull() => _isar.netConfigs.get(_id);

  Future<NetConfig> get() async {
    final config = await getOrNull();
    if (config == null) {
      throw StateError('NetConfig not initialized');
    }
    return config;
  }

  Future<void> save(NetConfig config) async {
    config.id = _id;
    await _isar.writeTxn(() async {
      await _isar.netConfigs.put(config);
    });
  }

  Future<void> update(void Function(NetConfig config) mutate) async {
    final config = await getOrNull();
    if (config == null) return;
    mutate(config);
    await save(config);
  }

  Future<void> init() async {
    final count = await _isar.netConfigs.count();
    if (count == 0) {
      await save(NetConfig());
      return;
    }
    await _migrateSocks5Fields();
  }

  Future<void> _migrateSocks5Fields() async {
    final config = await getOrNull();
    if (config == null) return;

    final normalizedPort = normalizeSocks5Port(config.socks5_port);
    if (config.socks5_port == normalizedPort) return;

    config.socks5_port = normalizedPort;
    await save(config);
  }
}
