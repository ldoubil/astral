import 'package:flutter/material.dart';
import 'package:astral/core/states/theme_state.dart';
import 'package:astral/core/repositories/theme_repository.dart';

/// 主题服务：协调 State 与持久化
class ThemeService {
  final ThemeState state;
  final ThemeRepository _repo;

  ThemeService(this.state, this._repo);

  Future<void> init() async {
    final settings = await _repo.get();
    state.updateAll(
      color: Color(settings.colorValue),
      mode: settings.themeModeValue,
    );
  }

  Future<void> updateThemeColor(Color color) async {
    state.updateColor(color);
    await _repo.update((s) => s.colorValue = color.toARGB32());
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    state.updateMode(mode);
    await _repo.update((s) => s.themeModeValue = mode);
  }
}
