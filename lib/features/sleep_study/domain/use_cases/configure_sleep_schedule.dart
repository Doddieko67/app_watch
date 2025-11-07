import '../entities/sleep_schedule_entity.dart';
import '../repositories/sleep_study_repository.dart';

/// Use case para configurar el horario de sueño
class ConfigureSleepSchedule {
  final SleepStudyRepository _repository;

  ConfigureSleepSchedule(this._repository);

  Future<SleepScheduleEntity> call({
    required DateTime defaultBedtime,
    required DateTime defaultWakeup,
    required int preSleepNotificationMinutes,
    required bool enableOptimalStudyTime,
  }) async {
    // Validaciones
    if (defaultWakeup.isBefore(defaultBedtime)) {
      throw ArgumentError('Wake up time must be after bedtime');
    }

    final sleepDuration = defaultWakeup.difference(defaultBedtime);
    if (sleepDuration.inHours < 4 || sleepDuration.inHours > 12) {
      throw ArgumentError('Sleep duration must be between 4 and 12 hours');
    }

    if (preSleepNotificationMinutes < 0 || preSleepNotificationMinutes > 120) {
      throw ArgumentError(
          'Pre-sleep notification must be between 0 and 120 minutes');
    }

    return _repository.configureSleepSchedule(
      defaultBedtime: defaultBedtime,
      defaultWakeup: defaultWakeup,
      preSleepNotificationMinutes: preSleepNotificationMinutes,
      enableOptimalStudyTime: enableOptimalStudyTime,
    );
  }
}
