import '../repositories/settings_repository.dart';

/// Use case to configure auto-backup settings
class ConfigureBackup {
  final SettingsRepository _repository;

  ConfigureBackup(this._repository);

  Future<void> updateFrequency(String frequency) async {
    if (!['never', 'daily', 'weekly'].contains(frequency)) {
      throw ArgumentError('Invalid backup frequency: $frequency');
    }
    await _repository.updateBackupFrequency(frequency);
  }

  Future<void> updateLastBackupDate(DateTime date) async {
    await _repository.updateLastBackupDate(date);
  }
}
