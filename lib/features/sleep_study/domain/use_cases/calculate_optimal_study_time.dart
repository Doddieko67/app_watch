import '../entities/sleep_schedule_entity.dart';
import '../repositories/sleep_study_repository.dart';

/// Use case para calcular la hora óptima de estudio
class CalculateOptimalStudyTime {
  final SleepStudyRepository _repository;

  CalculateOptimalStudyTime(this._repository);

  /// Calcula la hora óptima de estudio basada en el horario de sueño
  ///
  /// La hora óptima es aproximadamente 2-3 horas después de despertar,
  /// cuando el cerebro está más alerta y receptivo
  Future<DateTime?> call() async {
    final schedule = await _repository.getActiveSleepSchedule();
    if (schedule == null || !schedule.enableOptimalStudyTime) {
      return null;
    }

    return schedule.optimalStudyTime;
  }

  /// Verifica si una hora específica está en el rango óptimo
  bool isInOptimalRange(DateTime time, DateTime optimalTime) {
    final difference = time.difference(optimalTime).abs();
    // Considera óptimo si está dentro de ±1 hora
    return difference.inHours <= 1;
  }
}
