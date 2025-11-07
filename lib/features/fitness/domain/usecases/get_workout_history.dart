import '../entities/workout_entity.dart';
import '../repositories/fitness_repository.dart';

/// Use Case: Obtener Historial de Workouts
///
/// Obtiene el historial de workouts con opciones de filtrado
class GetWorkoutHistory {
  final FitnessRepository _repository;

  GetWorkoutHistory(this._repository);

  /// Obtiene todos los workouts activos
  Future<List<WorkoutEntity>> call() async {
    return await _repository.getActiveWorkouts();
  }

  /// Obtiene workouts en un rango de fechas
  Future<List<WorkoutEntity>> byDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    return await _repository.getWorkoutsByDateRange(start, end);
  }

  /// Obtiene workouts por tipo de split
  Future<List<WorkoutEntity>> bySplit(WorkoutSplit split) async {
    return await _repository.getWorkoutsBySplit(split);
  }

  /// Obtiene los workouts de hoy
  Future<List<WorkoutEntity>> today() async {
    return await _repository.getTodayWorkouts();
  }

  /// Obtiene los workouts de esta semana
  Future<List<WorkoutEntity>> thisWeek() async {
    return await _repository.getThisWeekWorkouts();
  }

  /// Obtiene workouts del último mes
  Future<List<WorkoutEntity>> lastMonth() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 1, now.day);
    final end = now;
    return await _repository.getWorkoutsByDateRange(start, end);
  }

  /// Obtiene workouts de los últimos N días
  Future<List<WorkoutEntity>> lastNDays(int days) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));
    return await _repository.getWorkoutsByDateRange(start, now);
  }
}
