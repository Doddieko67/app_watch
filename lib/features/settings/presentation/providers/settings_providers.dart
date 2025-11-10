import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/services/export_import_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../nutrition/presentation/providers/nutrition_providers.dart' as nutrition;
import '../../data/datasources/settings_local_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/use_cases/configure_backup.dart';
import '../../domain/use_cases/get_settings.dart';
import '../../domain/use_cases/update_theme.dart';

// ===== Repository Providers =====

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SettingsLocalDataSource(db);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final dataSource = ref.watch(settingsLocalDataSourceProvider);
  return SettingsRepositoryImpl(dataSource);
});

// ===== Use Case Providers =====

final getSettingsProvider = Provider<GetSettings>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetSettings(repository);
});

final updateThemeProvider = Provider<UpdateTheme>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return UpdateTheme(repository);
});

final configureBackupProvider = Provider<ConfigureBackup>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ConfigureBackup(repository);
});

// ===== Settings State Provider =====

final settingsProvider = StreamProvider<AppSettingsEntity>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.watchSettings();
});

// ===== Theme Providers =====

/// Provides current theme mode
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.when(
    data: (s) => s.themeMode,
    loading: () => ThemeMode.system,
    error: (_, __) => ThemeMode.system,
  );
});

/// Provides current primary color
final primaryColorProvider = Provider<Color>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.when(
    data: (s) => s.primaryColor,
    loading: () => const Color(0xFF6750A4),
    error: (_, __) => const Color(0xFF6750A4),
  );
});

/// Provides whether onboarding is completed
final onboardingCompletedProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.when(
    data: (s) => s.onboardingCompleted,
    loading: () => false,
    error: (_, __) => false,
  );
});

// ===== Export/Import Service Provider =====

final exportImportServiceProvider = Provider<ExportImportService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ExportImportService(db);
});

// ===== Secure Storage Providers =====

/// Check if API key is configured
final hasApiKeyProvider = FutureProvider<bool>((ref) async {
  return await SecureStorageService.hasGeminiApiKey();
});

/// Get API key (for display purposes - masked)
final apiKeyMaskedProvider = FutureProvider<String?>((ref) async {
  final key = await SecureStorageService.getGeminiApiKey();
  if (key == null || key.isEmpty) return null;
  // Return masked version: "AIz***...***xyz"
  if (key.length <= 10) return '*' * key.length;
  return '${key.substring(0, 3)}${'*' * (key.length - 6)}${key.substring(key.length - 3)}';
});

// ===== Actions Providers =====

/// Provider for updating theme mode
final updateThemeModeActionProvider = Provider<Future<void> Function(ThemeMode)>((ref) {
  return (ThemeMode mode) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.updateThemeMode(mode);
  };
});

/// Provider for updating primary color
final updatePrimaryColorActionProvider = Provider<Future<void> Function(String)>((ref) {
  return (String colorHex) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.updatePrimaryColor(colorHex);
  };
});

/// Provider for saving API key
final saveApiKeyActionProvider = Provider<Future<void> Function(String)>((ref) {
  return (String key) async {
    await SecureStorageService.saveGeminiApiKey(key);
    final repository = ref.read(settingsRepositoryProvider);
    await repository.updateHasApiKey(key.isNotEmpty);

    // Reconfigurar Gemini AI con la nueva API key
    if (key.isNotEmpty) {
      final aiService = ref.read(nutrition.aiServiceProvider);
      aiService.configureGemini(key);
      debugPrint('✅ Gemini AI reconfigurado con nueva API key');
    }

    // Invalidar provider de API key para actualizar UI
    ref.invalidate(hasApiKeyProvider);
  };
});

/// Provider for deleting API key
final deleteApiKeyActionProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    await SecureStorageService.deleteGeminiApiKey();
    final repository = ref.read(settingsRepositoryProvider);
    await repository.updateHasApiKey(false);

    // Invalidar provider de API key para actualizar UI
    ref.invalidate(hasApiKeyProvider);

    debugPrint('⚠️  API key de Gemini eliminada. Configúrala en Settings para usar IA.');
  };
});

/// Provider for updating backup frequency
final updateBackupFrequencyActionProvider = Provider<Future<void> Function(String)>((ref) {
  return (String frequency) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.updateBackupFrequency(frequency);
  };
});

/// Provider for completing onboarding
final completeOnboardingActionProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.completeOnboarding();
  };
});

/// Provider for updating notifications enabled
final updateNotificationsEnabledActionProvider = Provider<Future<void> Function(bool)>((ref) {
  return (bool enabled) async {
    final repository = ref.read(settingsRepositoryProvider);
    await repository.updateNotificationsEnabled(enabled);
  };
});
