import '../entities/workout_entity.dart';
import '../repositories/fitness_repository.dart';

/// Use Case: Obtener Datos de Progreso
///
/// Obtiene datos de progreso para análisis y visualización
class GetProgressData {
  final FitnessRepository _repository;

  GetProgressData(this._repository);

  /// Obtiene el progreso de un ejercicio específico en un rango de fechas
  ///
  /// Útil para gráficas de progreso de peso/reps a lo largo del tiempo
  Future<List<ExerciseEntity>> forExercise({
    required String exerciseName,
    required DateTime start,
    required DateTime end,
  }) async {
    return await _repository.getProgressDataForExercise(
      exerciseName,
      start,
      end,
    );
  }

  /// Obtiene el volumen semanal en un rango de fechas
  ///
  /// Returns: Map donde key es fecha "YYYY-MM-DD" y value es volumen total
  Future<Map<String, double>> weeklyVolume({
    required DateTime start,
    required DateTime end,
  }) async {
    return await _repository.getWeeklyVolume(start, end);
  }

  /// Obtiene el volumen de los últimos N días
  Future<Map<String, double>> volumeLastNDays(int days) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));
    return await _repository.getWeeklyVolume(start, now);
  }

  /// Obtiene los récords personales (PR) de todos los ejercicios
  ///
  /// Returns: Map donde key es nombre del ejercicio y value es el ExerciseEntity con el PR
  Future<Map<String, ExerciseEntity>> personalRecords() async {
    return await _repository.getPersonalRecords();
  }

  /// Obtiene estadísticas generales
  ///
  /// Returns: Map con totalWorkouts, totalExercises, totalVolume, avgDuration
  Future<Map<String, dynamic>> overallStats() async {
    return await _repository.getOverallStats();
  }

  /// Obtiene los ejercicios más frecuentes
  ///
  /// Returns: Map donde key es nombre del ejercicio y value es frecuencia
  Future<Map<String, int>> mostFrequentExercises({int limit = 10}) async {
    return await _repository.getMostFrequentExercises(limit: limit);
  }

  /// Obtiene el progreso de un ejercicio en los últimos 30 días
  Future<List<ExerciseEntity>> exerciseProgressLast30Days(
    String exerciseName,
  ) async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    return await _repository.getProgressDataForExercise(
      exerciseName,
      start,
      now,
    );
  }

  /// Obtiene el progreso de un ejercicio en los últimos 90 días
  Future<List<ExerciseEntity>> exerciseProgressLast90Days(
    String exerciseName,
  ) async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 90));
    return await _repository.getProgressDataForExercise(
      exerciseName,
      start,
      now,
    );
  }
}
