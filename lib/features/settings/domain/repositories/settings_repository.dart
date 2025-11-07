import 'package:flutter/material.dart';
import '../entities/app_settings_entity.dart';

/// Repository interface for app settings
abstract class SettingsRepository {
  /// Get current app settings
  /// Creates defaults if none exist
  Future<AppSettingsEntity> getSettings();

  /// Update theme mode (light, dark, system)
  Future<void> updateThemeMode(ThemeMode themeMode);

  /// Update primary color
  Future<void> updatePrimaryColor(String colorHex);

  /// Update backup frequency
  Future<void> updateBackupFrequency(String frequency);

  /// Update last backup date
  Future<void> updateLastBackupDate(DateTime date);

  /// Update notifications enabled
  Future<void> updateNotificationsEnabled(bool enabled);

  /// Update API key status
  Future<void> updateHasApiKey(bool hasKey);

  /// Mark onboarding as completed
  Future<void> completeOnboarding();

  /// Reset settings to defaults
  Future<void> resetToDefaults();

  /// Watch settings changes (Stream)
  Stream<AppSettingsEntity> watchSettings();
}
