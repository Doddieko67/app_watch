import 'package:flutter/material.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

/// Implementation of SettingsRepository
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  SettingsRepositoryImpl(this._localDataSource);

  @override
  Future<AppSettingsEntity> getSettings() async {
    return await _localDataSource.getSettings();
  }

  @override
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    await _localDataSource.updateThemeMode(themeMode);
  }

  @override
  Future<void> updatePrimaryColor(String colorHex) async {
    await _localDataSource.updatePrimaryColor(colorHex);
  }

  @override
  Future<void> updateBackupFrequency(String frequency) async {
    await _localDataSource.updateBackupFrequency(frequency);
  }

  @override
  Future<void> updateLastBackupDate(DateTime date) async {
    await _localDataSource.updateLastBackupDate(date);
  }

  @override
  Future<void> updateNotificationsEnabled(bool enabled) async {
    await _localDataSource.updateNotificationsEnabled(enabled);
  }

  @override
  Future<void> updateHasApiKey(bool hasKey) async {
    await _localDataSource.updateHasApiKey(hasKey);
  }

  @override
  Future<void> completeOnboarding() async {
    await _localDataSource.completeOnboarding();
  }

  @override
  Future<void> resetToDefaults() async {
    await _localDataSource.resetToDefaults();
  }

  @override
  Stream<AppSettingsEntity> watchSettings() {
    return _localDataSource.watchSettings();
  }
}
