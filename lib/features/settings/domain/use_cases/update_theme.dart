import 'package:flutter/material.dart';
import '../repositories/settings_repository.dart';

/// Use case to update theme mode and primary color
class UpdateTheme {
  final SettingsRepository _repository;

  UpdateTheme(this._repository);

  Future<void> updateThemeMode(ThemeMode mode) async {
    await _repository.updateThemeMode(mode);
  }

  Future<void> updatePrimaryColor(String colorHex) async {
    await _repository.updatePrimaryColor(colorHex);
  }
}
