import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/app_settings_entity.dart';

/// Mapper between AppSetting (Drift) and AppSettingsEntity (Domain)
class AppSettingsMapper {
  /// Convert from Drift model to Domain entity
  static AppSettingsEntity toEntity(AppSetting model) {
    return AppSettingsEntity(
      id: model.id,
      themeMode: _themeModeFromString(model.themeMode),
      primaryColorHex: model.primaryColorHex,
      backupFrequency: model.backupFrequency,
      lastBackupDate: model.lastBackupDate,
      notificationsEnabled: model.notificationsEnabled,
      hasApiKey: model.hasApiKey,
      onboardingCompleted: model.onboardingCompleted,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// Convert from Domain entity to Drift model
  static AppSetting toModel(AppSettingsEntity entity) {
    return AppSetting(
      id: entity.id,
      themeMode: _themeModeToString(entity.themeMode),
      primaryColorHex: entity.primaryColorHex,
      backupFrequency: entity.backupFrequency,
      lastBackupDate: entity.lastBackupDate,
      notificationsEnabled: entity.notificationsEnabled,
      hasApiKey: entity.hasApiKey,
      onboardingCompleted: entity.onboardingCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert from Domain entity to Drift Companion (for inserts/updates)
  static AppSettingsCompanion toCompanion(AppSettingsEntity entity) {
    return AppSettingsCompanion.insert(
      themeMode: Value(_themeModeToString(entity.themeMode)),
      primaryColorHex: Value(entity.primaryColorHex),
      backupFrequency: Value(entity.backupFrequency),
      lastBackupDate: Value(entity.lastBackupDate),
      notificationsEnabled: Value(entity.notificationsEnabled),
      hasApiKey: Value(entity.hasApiKey),
      onboardingCompleted: Value(entity.onboardingCompleted),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }

  /// Convert ThemeMode to String
  static String _themeModeToString(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }

  /// Convert String to ThemeMode
  static ThemeMode _themeModeFromString(String mode) {
    return switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
  }
}
