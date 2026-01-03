import 'package:flutter/material.dart';
import 'package:astral/k/states/theme_state.dart';
import 'package:astral/k/repositories/theme_repository.dart';

/// 主题服务：协调ThemeState和ThemeRepository
class ThemeService {
  final ThemeState state;
  final ThemeRepository _repository;

  ThemeService(this.state, this._repository);

  // ========== 初始化 ==========

  Future<void> init() async {
    final config = await _repository.loadAll();
    state.updateAll(color: config.color, mode: config.mode);
  }

  // ========== 业务方法（更新状态 + 持久化） ==========

  Future<void> updateThemeColor(Color color) async {
    state.updateColor(color);
    await _repository.saveThemeColor(color);
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    state.updateMode(mode);
    await _repository.saveThemeMode(mode);
  }

  Future<void> updateLanguage(String language) async {
    state.updateLanguage(language);
    // 语言设置目前不持久化，如需持久化可添加
  }

  // ========== 批量操作 ==========

  Future<void> updateAll({Color? color, ThemeMode? mode}) async {
    if (color != null) state.updateColor(color);
    if (mode != null) state.updateMode(mode);

    final config = ThemeConfig(
      color: color ?? state.themeColor.value,
      mode: mode ?? state.themeMode.value,
    );
    await _repository.saveAll(config);
  }
}
