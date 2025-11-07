import '../entities/app_settings_entity.dart';
import '../repositories/settings_repository.dart';

/// Use case to get current app settings
class GetSettings {
  final SettingsRepository _repository;

  GetSettings(this._repository);

  Future<AppSettingsEntity> call() async {
    return await _repository.getSettings();
  }
}
