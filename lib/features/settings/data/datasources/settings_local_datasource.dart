import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../models/app_settings_mapper.dart';

/// Local datasource for app settings using Drift
class SettingsLocalDataSource {
  final AppDatabase _db;

  SettingsLocalDataSource(this._db);

  /// Get current settings (creates defaults if none exist)
  Future<AppSettingsEntity> getSettings() async {
    final setting = await _db.getSettings();

    if (setting == null) {
      // Create default settings
      final defaults = AppSettingsEntity.defaults();
      final companion = AppSettingsMapper.toCompanion(defaults);
      await _db.insertSettings(companion);
      return defaults;
    }

    return AppSettingsMapper.toEntity(setting);
  }

  /// Update theme mode
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    final current = await getSettings();
    final updated = AppSettingsMapper.toModel(
      current.copyWith(
        themeMode: themeMode,
        updatedAt: DateTime.now(),
      ),
    );
    await _db.updateSettings(updated);
  }

  /// Update primary color
  Future<void> updatePrimaryColor(String colorHex) async {
    final current = await getSettings();
    final updated = AppSettingsMapper.toModel(
      current.copyWith(
        primaryColorHex: colorHex,
        updatedAt: DateTime.now(),
      ),
    );
    await _db.updateSettings(updated);
  }

  /// Update backup frequency
  Future<void> updateBackupFrequency(String frequency) async {
    final current = await getSettings();
    final updated = AppSettingsMapper.toModel(
      current.copyWith(
        backupFrequency: frequency,
        updatedAt: DateTime.now(),
      ),
    );
    await _db.updateSettings(updated);
  }

  /// Update last backup date
  Future<void> updateLastBackupDate(DateTime date) async {
    final current = await getSettings();
    final updated = AppSettingsMapper.toModel(
      current.copyWith(
        lastBackupDate: date,
        updatedAt: DateTime.now(),
      ),
    );
    await _db.updateSettings(updated);
  }

  /// Update notifications enabled
  Future<void> updateNotificationsEnabled(bool enabled) async {
    final current = await getSettings();
    final updated = AppSettingsMapper.toModel(
      current.copyWith(
        notificationsEnabled: enabled,
        updatedAt: DateTime.now(),
      ),
    );
    await _db.updateSettings(updated);
  }

  /// Update API key status
  Future<void> updateHasApiKey(bool hasKey) async {
    final current = await getSettings();
    final updated = AppSettingsMapper.toModel(
      current.copyWith(
        hasApiKey: hasKey,
        updatedAt: DateTime.now(),
      ),
    );
    await _db.updateSettings(updated);
  }

  /// Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final current = await getSettings();
    final updated = AppSettingsMapper.toModel(
      current.copyWith(
        onboardingCompleted: true,
        updatedAt: DateTime.now(),
      ),
    );
    await _db.updateSettings(updated);
  }

  /// Reset settings to defaults
  Future<void> resetToDefaults() async {
    final defaults = AppSettingsEntity.defaults();
    final updated = AppSettingsMapper.toModel(defaults);
    await _db.updateSettings(updated);
  }

  /// Watch settings changes
  Stream<AppSettingsEntity> watchSettings() {
    return _db.watchSettings().map((setting) {
      if (setting == null) {
        return AppSettingsEntity.defaults();
      }
      return AppSettingsMapper.toEntity(setting);
    });
  }
}
