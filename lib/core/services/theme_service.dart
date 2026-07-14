import 'package:flutter/material.dart';
import 'package:astral/core/states/theme_state.dart';
import 'package:astral/core/repositories/theme_repository.dart';

/// 主题服务：协调ThemeState和ThemeRepository
class ThemeService {
  final ThemeState state;
  final ThemeRepository _repository;

  ThemeService(this.state, this._repository);

  Future<void> init() async {
    final config = await _repository.loadAll();
    state.updateAll(color: config.color, mode: config.mode);
  }

  Future<void> updateThemeColor(Color color) async {
    state.updateColor(color);
    await _repository.saveThemeColor(color);
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    state.updateMode(mode);
    await _repository.saveThemeMode(mode);
  }
}
