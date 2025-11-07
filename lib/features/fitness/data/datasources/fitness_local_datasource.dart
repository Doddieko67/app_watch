import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/workout_entity.dart';
import '../models/workout_mapper.dart';

/// Local Data Source para Fitness
///
/// Maneja las operaciones de base de datos para workouts y ejercicios
class FitnessLocalDataSource {
  final AppDatabase _database;

  FitnessLocalDataSource(this._database);

  // ==================== Workouts ====================

  /// Obtiene todos los workouts
  Future<List<WorkoutEntity>> getAllWorkouts() async {
    final workoutsData = await _database.getAllWorkouts();
    final List<WorkoutEntity> result = [];

    for (final workout in workoutsData) {
      final exercises = await _getExercisesForWorkout(workout.id);
      result.add(WorkoutMapper.toEntity(workout, exercises: exercises));
    }

    return result;
  }

  /// Obtiene un workout por su ID
  Future<WorkoutEntity?> getWorkoutById(int id) async {
    final workout = await _database.getWorkoutById(id);
    if (workout == null) return null;

    final exercises = await _getExercisesForWorkout(id);
    return WorkoutMapper.toEntity(workout, exercises: exercises);
  }

  /// Obtiene los workouts activos (no eliminados)
  Future<List<WorkoutEntity>> getActiveWorkouts() async {
    final query = _database.select(_database.workouts)
      ..where((w) => w.deletedAt.isNull())
      ..orderBy([
        (w) => OrderingTerm.desc(w.date),
      ]);

    final workoutsData = await query.get();
    final List<WorkoutEntity> result = [];

    for (final workout in workoutsData) {
      final exercises = await _getExercisesForWorkout(workout.id);
      result.add(WorkoutMapper.toEntity(workout, exercises: exercises));
    }

    return result;
  }

  /// Obtiene los workouts en un rango de fechas
  Future<List<WorkoutEntity>> getWorkoutsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final query = _database.select(_database.workouts)
      ..where((w) =>
          (w.deletedAt.isNull()) &
          (w.date.isBiggerOrEqualValue(start)) &
          (w.date.isSmallerOrEqualValue(end)))
      ..orderBy([
        (w) => OrderingTerm.desc(w.date),
      ]);

    final workoutsData = await query.get();
    final List<WorkoutEntity> result = [];

    for (final workout in workoutsData) {
      final exercises = await _getExercisesForWorkout(workout.id);
      result.add(WorkoutMapper.toEntity(workout, exercises: exercises));
    }

    return result;
  }

  /// Obtiene los workouts por tipo de split
  Future<List<WorkoutEntity>> getWorkoutsBySplit(WorkoutSplit split) async {
    final query = _database.select(_database.workouts)
      ..where((w) =>
          (w.deletedAt.isNull()) & (w.split.equals(split.value)))
      ..orderBy([
        (w) => OrderingTerm.desc(w.date),
      ]);

    final workoutsData = await query.get();
    final List<WorkoutEntity> result = [];

    for (final workout in workoutsData) {
      final exercises = await _getExercisesForWorkout(workout.id);
      result.add(WorkoutMapper.toEntity(workout, exercises: exercises));
    }

    return result;
  }

  /// Obtiene los workouts de hoy
  Future<List<WorkoutEntity>> getTodayWorkouts() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = _database.select(_database.workouts)
      ..where((w) =>
          (w.deletedAt.isNull()) &
          (w.date.isBiggerOrEqualValue(startOfDay)) &
          (w.date.isSmallerThanValue(endOfDay)))
      ..orderBy([
        (w) => OrderingTerm.desc(w.date),
      ]);

    final workoutsData = await query.get();
    final List<WorkoutEntity> result = [];

    for (final workout in workoutsData) {
      final exercises = await _getExercisesForWorkout(workout.id);
      result.add(WorkoutMapper.toEntity(workout, exercises: exercises));
    }

    return result;
  }

  /// Obtiene los workouts de esta semana
  Future<List<WorkoutEntity>> getThisWeekWorkouts() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final endOfWeek = startOfWeekDay.add(const Duration(days: 7));

    return await getWorkoutsByDateRange(startOfWeekDay, endOfWeek);
  }

  /// Crea un nuevo workout
  Future<int> createWorkout(WorkoutEntity workout) async {
    final companion = WorkoutMapper.toCompanionForInsert(workout);
    return await _database.insertWorkout(companion);
  }

  /// Actualiza un workout existente
  Future<bool> updateWorkout(WorkoutEntity workout) async {
    final driftWorkout = Workout(
      id: workout.id,
      name: workout.name,
      split: workout.split.value,
      date: workout.date,
      durationMinutes: workout.durationMinutes,
      notes: workout.notes,
      createdAt: workout.createdAt,
      updatedAt: DateTime.now(), // Actualizar timestamp
      deletedAt: workout.deletedAt,
      syncStatus: 0,
    );

    return await _database.updateWorkout(driftWorkout);
  }

  /// Elimina un workout (soft delete)
  Future<bool> deleteWorkout(int id) async {
    final workout = await _database.getWorkoutById(id);
    if (workout == null) return false;

    final now = DateTime.now();
    final updated = workout.copyWith(
      deletedAt: Value(now),
      updatedAt: now,
    );

    return await _database.updateWorkout(updated);
  }

  // ==================== Exercises ====================

  /// Obtiene todos los ejercicios de un workout
  Future<List<ExerciseEntity>> getExercisesByWorkoutId(int workoutId) async {
    final exercisesData = await _database.getExercisesByWorkoutId(workoutId);
    return exercisesData
        .where((e) => e.deletedAt == null)
        .map((e) => ExerciseMapper.toEntity(e))
        .toList();
  }

  /// Obtiene un ejercicio por su ID
  Future<ExerciseEntity?> getExerciseById(int id) async {
    final query = _database.select(_database.exercises)
      ..where((e) => e.id.equals(id));
    final exercise = await query.getSingleOrNull();
    return exercise != null ? ExerciseMapper.toEntity(exercise) : null;
  }

  /// Crea un nuevo ejercicio
  Future<int> createExercise(ExerciseEntity exercise) async {
    final companion = ExerciseMapper.toCompanionForInsert(exercise);
    return await _database.insertExercise(companion);
  }

  /// Actualiza un ejercicio existente
  Future<bool> updateExercise(ExerciseEntity exercise) async {
    final driftExercise = Exercise(
      id: exercise.id,
      workoutId: exercise.workoutId,
      name: exercise.name,
      sets: exercise.sets,
      reps: exercise.reps,
      weight: exercise.weight,
      notes: exercise.notes,
      createdAt: exercise.createdAt,
      updatedAt: DateTime.now(), // Actualizar timestamp
      deletedAt: exercise.deletedAt,
      syncStatus: 0,
    );

    return await _database.updateExercise(driftExercise);
  }

  /// Elimina un ejercicio (soft delete)
  Future<bool> deleteExercise(int id) async {
    final query = _database.select(_database.exercises)
      ..where((e) => e.id.equals(id));
    final exercise = await query.getSingleOrNull();
    if (exercise == null) return false;

    final now = DateTime.now();
    final updated = exercise.copyWith(
      deletedAt: Value(now),
      updatedAt: now,
    );

    return await _database.updateExercise(updated);
  }

  // ==================== Progress & Stats ====================

  /// Obtiene datos de progreso para un ejercicio específico
  Future<List<ExerciseEntity>> getProgressDataForExercise(
    String exerciseName,
    DateTime start,
    DateTime end,
  ) async {
    // Obtener todos los workouts en el rango de fechas
    final workoutsQuery = _database.select(_database.workouts)
      ..where((w) =>
          (w.deletedAt.isNull()) &
          (w.date.isBiggerOrEqualValue(start)) &
          (w.date.isSmallerOrEqualValue(end)))
      ..orderBy([
        (w) => OrderingTerm.asc(w.date),
      ]);

    final workoutsData = await workoutsQuery.get();
    final workoutIds = workoutsData.map((w) => w.id).toList();

    if (workoutIds.isEmpty) return [];

    // Obtener todos los ejercicios con ese nombre en esos workouts
    final exercisesQuery = _database.select(_database.exercises)
      ..where((e) =>
          (e.deletedAt.isNull()) &
          (e.workoutId.isIn(workoutIds)) &
          (e.name.equals(exerciseName)))
      ..orderBy([
        (e) => OrderingTerm.asc(e.createdAt),
      ]);

    final exercisesData = await exercisesQuery.get();
    return exercisesData.map((e) => ExerciseMapper.toEntity(e)).toList();
  }

  /// Obtiene el volumen total por día en un rango de fechas
  Future<Map<String, double>> getWeeklyVolume(
    DateTime start,
    DateTime end,
  ) async {
    final workoutsData = await getWorkoutsByDateRange(start, end);
    final Map<String, double> volumeByDate = {};

    for (final workout in workoutsData) {
      final dateKey = _formatDate(workout.date);
      final volume = workout.totalVolume;

      if (volumeByDate.containsKey(dateKey)) {
        volumeByDate[dateKey] = volumeByDate[dateKey]! + volume;
      } else {
        volumeByDate[dateKey] = volume;
      }
    }

    return volumeByDate;
  }

  /// Obtiene los récords personales (PR) para cada ejercicio
  Future<Map<String, ExerciseEntity>> getPersonalRecords() async {
    final allExercises = await _getAllActiveExercises();
    final Map<String, ExerciseEntity> personalRecords = {};

    for (final exercise in allExercises) {
      final existingPR = personalRecords[exercise.name];

      if (existingPR == null || exercise.weight > existingPR.weight) {
        personalRecords[exercise.name] = exercise;
      }
    }

    return personalRecords;
  }

  /// Obtiene estadísticas generales
  Future<Map<String, dynamic>> getOverallStats() async {
    final activeWorkouts = await getActiveWorkouts();
    final allExercises = await _getAllActiveExercises();

    double totalVolume = 0;
    int totalDuration = 0;
    int workoutsWithDuration = 0;

    for (final workout in activeWorkouts) {
      totalVolume += workout.totalVolume;
      if (workout.durationMinutes != null) {
        totalDuration += workout.durationMinutes!;
        workoutsWithDuration++;
      }
    }

    return {
      'totalWorkouts': activeWorkouts.length,
      'totalExercises': allExercises.length,
      'totalVolume': totalVolume,
      'avgDuration': workoutsWithDuration > 0
          ? totalDuration / workoutsWithDuration
          : 0.0,
    };
  }

  /// Obtiene los ejercicios más realizados
  Future<Map<String, int>> getMostFrequentExercises({int limit = 10}) async {
    final allExercises = await _getAllActiveExercises();
    final Map<String, int> frequency = {};

    for (final exercise in allExercises) {
      frequency[exercise.name] = (frequency[exercise.name] ?? 0) + 1;
    }

    // Ordenar por frecuencia y tomar los top N
    final sortedEntries = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(
      sortedEntries.take(limit),
    );
  }

  // ==================== Private Helpers ====================

  /// Obtiene los ejercicios de un workout específico (solo activos)
  Future<List<ExerciseEntity>> _getExercisesForWorkout(int workoutId) async {
    return await getExercisesByWorkoutId(workoutId);
  }

  /// Obtiene todos los ejercicios activos
  Future<List<ExerciseEntity>> _getAllActiveExercises() async {
    final query = _database.select(_database.exercises)
      ..where((e) => e.deletedAt.isNull());

    final exercisesData = await query.get();
    return exercisesData.map((e) => ExerciseMapper.toEntity(e)).toList();
  }

  /// Formatea una fecha a string "YYYY-MM-DD"
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
