import '../entities/workout_entity.dart';

/// Repository Interface para Fitness
///
/// Define los métodos necesarios para manejar workouts y ejercicios
/// siguiendo los principios de Clean Architecture
abstract class FitnessRepository {
  // ==================== Workouts ====================

  /// Obtiene todos los workouts
  Future<List<WorkoutEntity>> getAllWorkouts();

  /// Obtiene un workout por su ID
  Future<WorkoutEntity?> getWorkoutById(int id);

  /// Obtiene los workouts activos (no eliminados)
  Future<List<WorkoutEntity>> getActiveWorkouts();

  /// Obtiene los workouts en un rango de fechas
  Future<List<WorkoutEntity>> getWorkoutsByDateRange(
    DateTime start,
    DateTime end,
  );

  /// Obtiene los workouts por tipo de split (DEPRECATED - ya no se usa)
  // Future<List<WorkoutEntity>> getWorkoutsBySplit(WorkoutSplit split);

  /// Obtiene los workouts de hoy
  Future<List<WorkoutEntity>> getTodayWorkouts();

  /// Obtiene los workouts de la semana actual
  Future<List<WorkoutEntity>> getThisWeekWorkouts();

  /// Crea un nuevo workout
  Future<int> createWorkout(WorkoutEntity workout);

  /// Actualiza un workout existente
  Future<bool> updateWorkout(WorkoutEntity workout);

  /// Elimina un workout (soft delete)
  Future<bool> deleteWorkout(int id);

  // ==================== Exercises ====================

  /// Obtiene todos los ejercicios de un workout
  Future<List<ExerciseEntity>> getExercisesByWorkoutId(int workoutId);

  /// Obtiene un ejercicio por su ID
  Future<ExerciseEntity?> getExerciseById(int id);

  /// Crea un nuevo ejercicio
  Future<int> createExercise(ExerciseEntity exercise);

  /// Actualiza un ejercicio existente
  Future<bool> updateExercise(ExerciseEntity exercise);

  /// Elimina un ejercicio (soft delete)
  Future<bool> deleteExercise(int id);

  // ==================== Progress & Stats ====================

  /// Obtiene datos de progreso para un ejercicio específico
  /// Retorna lista de ejercicios con sus pesos/reps a lo largo del tiempo
  Future<List<ExerciseEntity>> getProgressDataForExercise(
    String exerciseName,
    DateTime start,
    DateTime end,
  );

  /// Obtiene el volumen total por semana en un rango de fechas
  /// Retorna Map<String, double> donde key es "YYYY-MM-DD" y value es volumen
  Future<Map<String, double>> getWeeklyVolume(
    DateTime start,
    DateTime end,
  );

  /// Obtiene los récords personales (PR) para cada ejercicio
  /// Retorna Map<String, ExerciseEntity> donde key es nombre del ejercicio
  Future<Map<String, ExerciseEntity>> getPersonalRecords();

  /// Obtiene estadísticas generales
  /// Retorna Map con: totalWorkouts, totalExercises, totalVolume, avgDuration
  Future<Map<String, dynamic>> getOverallStats();

  /// Obtiene los ejercicios más realizados
  /// Retorna Map<String, int> donde key es nombre del ejercicio y value es frecuencia
  Future<Map<String, int>> getMostFrequentExercises({int limit = 10});
}
