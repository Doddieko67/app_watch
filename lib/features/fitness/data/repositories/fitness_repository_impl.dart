import '../../domain/entities/workout_entity.dart';
import '../../domain/repositories/fitness_repository.dart';
import '../datasources/fitness_local_datasource.dart';

/// Implementación del FitnessRepository
///
/// Implementa los métodos definidos en la interfaz del repositorio
/// usando el local data source
class FitnessRepositoryImpl implements FitnessRepository {
  final FitnessLocalDataSource _localDataSource;

  FitnessRepositoryImpl(this._localDataSource);

  // ==================== Workouts ====================

  @override
  Future<List<WorkoutEntity>> getAllWorkouts() async {
    return await _localDataSource.getAllWorkouts();
  }

  @override
  Future<WorkoutEntity?> getWorkoutById(int id) async {
    return await _localDataSource.getWorkoutById(id);
  }

  @override
  Future<List<WorkoutEntity>> getActiveWorkouts() async {
    return await _localDataSource.getActiveWorkouts();
  }

  @override
  Future<List<WorkoutEntity>> getWorkoutsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return await _localDataSource.getWorkoutsByDateRange(start, end);
  }

  // @override
  // Future<List<WorkoutEntity>> getWorkoutsBySplit(WorkoutSplit split) async {
  //   return await _localDataSource.getWorkoutsBySplit(split);
  // }

  @override
  Future<List<WorkoutEntity>> getTodayWorkouts() async {
    return await _localDataSource.getTodayWorkouts();
  }

  @override
  Future<List<WorkoutEntity>> getThisWeekWorkouts() async {
    return await _localDataSource.getThisWeekWorkouts();
  }

  @override
  Future<int> createWorkout(WorkoutEntity workout) async {
    return await _localDataSource.createWorkout(workout);
  }

  @override
  Future<bool> updateWorkout(WorkoutEntity workout) async {
    return await _localDataSource.updateWorkout(workout);
  }

  @override
  Future<bool> deleteWorkout(int id) async {
    return await _localDataSource.deleteWorkout(id);
  }

  // ==================== Exercises ====================

  @override
  Future<List<ExerciseEntity>> getExercisesByWorkoutId(int workoutId) async {
    return await _localDataSource.getExercisesByWorkoutId(workoutId);
  }

  @override
  Future<ExerciseEntity?> getExerciseById(int id) async {
    return await _localDataSource.getExerciseById(id);
  }

  @override
  Future<int> createExercise(ExerciseEntity exercise) async {
    return await _localDataSource.createExercise(exercise);
  }

  @override
  Future<bool> updateExercise(ExerciseEntity exercise) async {
    return await _localDataSource.updateExercise(exercise);
  }

  @override
  Future<bool> deleteExercise(int id) async {
    return await _localDataSource.deleteExercise(id);
  }

  // ==================== Progress & Stats ====================

  @override
  Future<List<ExerciseEntity>> getProgressDataForExercise(
    String exerciseName,
    DateTime start,
    DateTime end,
  ) async {
    return await _localDataSource.getProgressDataForExercise(
      exerciseName,
      start,
      end,
    );
  }

  @override
  Future<Map<String, double>> getWeeklyVolume(
    DateTime start,
    DateTime end,
  ) async {
    return await _localDataSource.getWeeklyVolume(start, end);
  }

  @override
  Future<Map<String, ExerciseEntity>> getPersonalRecords() async {
    return await _localDataSource.getPersonalRecords();
  }

  @override
  Future<Map<String, dynamic>> getOverallStats() async {
    return await _localDataSource.getOverallStats();
  }

  @override
  Future<Map<String, int>> getMostFrequentExercises({int limit = 10}) async {
    return await _localDataSource.getMostFrequentExercises(limit: limit);
  }
}
