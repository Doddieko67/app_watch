import '../repositories/sleep_study_repository.dart';

/// Use case para obtener estadísticas de sueño y estudio
class GetSleepStats {
  final SleepStudyRepository _repository;

  GetSleepStats(this._repository);

  /// Obtiene estadísticas de sueño para un rango de fechas
  Future<SleepStats> getSleepStats(DateTime start, DateTime end) async {
    if (end.isBefore(start)) {
      throw ArgumentError('End date must be after start date');
    }

    return _repository.getSleepStats(start, end);
  }

  /// Obtiene estadísticas de estudio para un rango de fechas
  Future<StudyStats> getStudyStats(DateTime start, DateTime end) async {
    if (end.isBefore(start)) {
      throw ArgumentError('End date must be after start date');
    }

    return _repository.getStudyStats(start, end);
  }

  /// Obtiene estadísticas de la última semana
  Future<SleepStats> getWeeklySleepStats() async {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 7));
    return getSleepStats(start, end);
  }

  /// Obtiene estadísticas de estudio de la última semana
  Future<StudyStats> getWeeklyStudyStats() async {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 7));
    return getStudyStats(start, end);
  }
}
