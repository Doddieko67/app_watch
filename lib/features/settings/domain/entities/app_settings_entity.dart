import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'app_settings_entity.freezed.dart';

/// Entity representing app settings
@freezed
class AppSettingsEntity with _$AppSettingsEntity {
  const factory AppSettingsEntity({
    required int id,

    // Theme settings
    required ThemeMode themeMode, // light, dark, system
    required String primaryColorHex, // Color hex string

    // Backup settings
    required String backupFrequency, // 'never', 'daily', 'weekly'
    DateTime? lastBackupDate,

    // Notifications
    required bool notificationsEnabled,

    // AI settings
    required bool hasApiKey, // Flag to know if API key is configured

    // Onboarding
    required bool onboardingCompleted,

    // Timestamps
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AppSettingsEntity;

  const AppSettingsEntity._();

  /// Default settings for new users
  factory AppSettingsEntity.defaults() {
    return AppSettingsEntity(
      id: 1,
      themeMode: ThemeMode.system,
      primaryColorHex: '#6750A4', // Material 3 default purple
      backupFrequency: 'never',
      lastBackupDate: null,
      notificationsEnabled: true,
      hasApiKey: false,
      onboardingCompleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Convert hex string to Color
  Color get primaryColor {
    final buffer = StringBuffer();
    if (primaryColorHex.length == 6 || primaryColorHex.length == 7) {
      buffer.write('ff');
    }
    buffer.write(primaryColorHex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Check if backup is needed based on frequency
  bool needsBackup() {
    if (backupFrequency == 'never') return false;
    if (lastBackupDate == null) return true;

    final now = DateTime.now();
    final daysSinceLastBackup = now.difference(lastBackupDate!).inDays;

    return switch (backupFrequency) {
      'daily' => daysSinceLastBackup >= 1,
      'weekly' => daysSinceLastBackup >= 7,
      _ => false,
    };
  }
}
