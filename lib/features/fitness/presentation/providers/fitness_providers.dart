import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/datasources/fitness_local_datasource.dart';
import '../../data/repositories/fitness_repository_impl.dart';
import '../../domain/entities/workout_entity.dart';
import '../../domain/repositories/fitness_repository.dart';
import '../../domain/usecases/create_workout.dart';
import '../../domain/usecases/get_progress_data.dart';
import '../../domain/usecases/get_workout_history.dart';
import '../../domain/usecases/log_exercise.dart';

part 'fitness_providers.g.dart';

// ========== Data Layer Providers ==========

/// Provider para FitnessLocalDataSource
@riverpod
FitnessLocalDataSource fitnessLocalDataSource(
    FitnessLocalDataSourceRef ref) {
  final database = ref.watch(appDatabaseProvider);
  return FitnessLocalDataSource(database);
}

/// Provider para FitnessRepository
@riverpod
FitnessRepository fitnessRepository(FitnessRepositoryRef ref) {
  final localDataSource = ref.watch(fitnessLocalDataSourceProvider);
  return FitnessRepositoryImpl(localDataSource);
}

// ========== Use Cases Providers ==========

/// Provider para CreateWorkout use case
@riverpod
CreateWorkout createWorkout(CreateWorkoutRef ref) {
  final repository = ref.watch(fitnessRepositoryProvider);
  return CreateWorkout(repository);
}

/// Provider para LogExercise use case
@riverpod
LogExercise logExercise(LogExerciseRef ref) {
  final repository = ref.watch(fitnessRepositoryProvider);
  return LogExercise(repository);
}

/// Provider para GetWorkoutHistory use case
@riverpod
GetWorkoutHistory getWorkoutHistory(GetWorkoutHistoryRef ref) {
  final repository = ref.watch(fitnessRepositoryProvider);
  return GetWorkoutHistory(repository);
}

/// Provider para GetProgressData use case
@riverpod
GetProgressData getProgressData(GetProgressDataRef ref) {
  final repository = ref.watch(fitnessRepositoryProvider);
  return GetProgressData(repository);
}

// ========== State Providers ==========

/// Provider para obtener todos los workouts activos
@riverpod
Future<List<WorkoutEntity>> activeWorkouts(ActiveWorkoutsRef ref) async {
  final repository = ref.watch(fitnessRepositoryProvider);
  return await repository.getActiveWorkouts();
}

/// Provider para obtener los workouts de hoy
@riverpod
Future<List<WorkoutEntity>> todayWorkouts(TodayWorkoutsRef ref) async {
  final repository = ref.watch(fitnessRepositoryProvider);
  return await repository.getTodayWorkouts();
}

/// Provider para obtener los workouts de esta semana
@riverpod
Future<List<WorkoutEntity>> thisWeekWorkouts(ThisWeekWorkoutsRef ref) async {
  final repository = ref.watch(fitnessRepositoryProvider);
  return await repository.getThisWeekWorkouts();
}

/// Provider para obtener workouts por rango de fechas
@riverpod
Future<List<WorkoutEntity>> workoutsByDateRange(
  WorkoutsByDateRangeRef ref, {
  required DateTime start,
  required DateTime end,
}) async {
  final repository = ref.watch(fitnessRepositoryProvider);
  return await repository.getWorkoutsByDateRange(start, end);
}

/// Provider para obtener workouts por split (DEPRECATED - ahora se usa muscleGroups)
// @riverpod
// Future<List<WorkoutEntity>> workoutsBySplit(
//   WorkoutsBySplitRef ref,
//   WorkoutSplit split,
// ) async {
//   final repository = ref.watch(fitnessRepositoryProvider);
//   return await repository.getWorkoutsBySplit(split);
// }

/// Provider para obtener un workout específico por ID
@riverpod
Future<WorkoutEntity?> workoutById(
  WorkoutByIdRef ref,
  int id,
) async {
  final repository = ref.watch(fitnessRepositoryProvider);
  return await repository.getWorkoutById(id);
}

/// Provider para obtener ejercicios de un workout
@riverpod
Future<List<ExerciseEntity>> exercisesByWorkoutId(
  ExercisesByWorkoutIdRef ref,
  int workoutId,
) async {
  final repository = ref.watch(fitnessRepositoryProvider);
  return await repository.getExercisesByWorkoutId(workoutId);
}

/// Provider para obtener estadísticas generales
@riverpod
Future<Map<String, dynamic>> overallStats(OverallStatsRef ref) async {
  final repository = ref.watch(fitnessRepositoryProvider);
  return await repository.getOverallStats();
}

/// Provider para obtener récords personales
@riverpod
Future<Map<String, ExerciseEntity>> personalRecords(
  PersonalRecordsRef ref,
) async {
  final repository = ref.watch(fitnessRepositoryProvider);
  return await repository.getPersonalRecords();
}

/// Provider para obtener ejercicios más frecuentes
@riverpod
Future<Map<String, int>> mostFrequentExercises(
  MostFrequentExercisesRef ref, {
  int limit = 10,
}) async {
  final repository = ref.watch(fitnessRepositoryProvider);
  return await repository.getMostFrequentExercises(limit: limit);
}

/// Provider para obtener progreso de un ejercicio
@riverpod
Future<List<ExerciseEntity>> exerciseProgress(
  ExerciseProgressRef ref, {
  required String exerciseName,
  required DateTime start,
  required DateTime end,
}) async {
  final repository = ref.watch(fitnessRepositoryProvider);
  return await repository.getProgressDataForExercise(
    exerciseName,
    start,
    end,
  );
}

/// Provider para obtener volumen semanal
@riverpod
Future<Map<String, double>> weeklyVolume(
  WeeklyVolumeRef ref, {
  required DateTime start,
  required DateTime end,
}) async {
  final repository = ref.watch(fitnessRepositoryProvider);
  return await repository.getWeeklyVolume(start, end);
}

/// Provider para obtener ejercicios guardados
@riverpod
Future<List<SavedExerciseData>> savedExercises(SavedExercisesRef ref) async {
  final database = ref.watch(appDatabaseProvider);
  return await database.getAllSavedExercises();
}

/// Provider para obtener workouts guardados
@riverpod
Future<List<SavedWorkoutData>> savedWorkouts(SavedWorkoutsRef ref) async {
  final database = ref.watch(appDatabaseProvider);
  return await database.getAllSavedWorkouts();
}
