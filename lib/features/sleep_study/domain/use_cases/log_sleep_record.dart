import '../entities/sleep_record_entity.dart';
import '../repositories/sleep_study_repository.dart';

/// Use case para registrar un récord de sueño
class LogSleepRecord {
  final SleepStudyRepository _repository;

  LogSleepRecord(this._repository);

  /// Crea un nuevo registro de sueño planificado
  Future<SleepRecordEntity> createPlanned({
    required DateTime date,
    required DateTime plannedBedtime,
    required DateTime plannedWakeup,
    String? notes,
  }) async {
    // Validaciones
    if (plannedWakeup.isBefore(plannedBedtime)) {
      throw ArgumentError('Wake up time must be after bedtime');
    }

    return _repository.createSleepRecord(
      date: date,
      plannedBedtime: plannedBedtime,
      plannedWakeup: plannedWakeup,
      notes: notes,
    );
  }

  /// Actualiza un registro con los tiempos reales
  Future<SleepRecordEntity> logActual({
    required int recordId,
    required DateTime actualBedtime,
    required DateTime actualWakeup,
    int? sleepQuality,
    String? notes,
  }) async {
    // Validaciones
    if (actualWakeup.isBefore(actualBedtime)) {
      throw ArgumentError('Wake up time must be after bedtime');
    }

    if (sleepQuality != null && (sleepQuality < 1 || sleepQuality > 5)) {
      throw ArgumentError('Sleep quality must be between 1 and 5');
    }

    return _repository.logActualSleep(
      recordId: recordId,
      actualBedtime: actualBedtime,
      actualWakeup: actualWakeup,
      sleepQuality: sleepQuality,
      notes: notes,
    );
  }
}
