import 'dart:convert';

import 'package:drift/drift.dart' as drift;

import '../../../../core/database/app_database.dart';
import '../../domain/entities/workout_entity.dart';

/// Mapper para convertir entre Workout/Exercise (Drift) y WorkoutEntity/ExerciseEntity (Domain)
class WorkoutMapper {
  /// Convierte de Workout (Drift) a WorkoutEntity (Domain)
  /// Nota: exercises debe ser proporcionada por separado
  static WorkoutEntity toEntity(
    Workout workout, {
    List<ExerciseEntity> exercises = const [],
  }) {
    // Decodificar muscleGroups desde JSON
    final muscleGroupsList = _decodeMuscleGroups(workout.muscleGroups);

    return WorkoutEntity(
      id: workout.id,
      name: workout.name,
      muscleGroups: muscleGroupsList,
      date: workout.date,
      durationMinutes: workout.durationMinutes,
      notes: workout.notes,
      exercises: exercises,
      createdAt: workout.createdAt,
      updatedAt: workout.updatedAt,
      deletedAt: workout.deletedAt,
    );
  }

  /// Convierte de WorkoutEntity (Domain) a WorkoutsCompanion (Drift)
  static WorkoutsCompanion toCompanion(WorkoutEntity entity) {
    return WorkoutsCompanion(
      id: drift.Value(entity.id),
      name: drift.Value(entity.name),
      muscleGroups: drift.Value(_encodeMuscleGroups(entity.muscleGroups)),
      date: drift.Value(entity.date),
      durationMinutes: entity.durationMinutes != null
          ? drift.Value(entity.durationMinutes!)
          : const drift.Value.absent(),
      notes: entity.notes != null
          ? drift.Value(entity.notes!)
          : const drift.Value.absent(),
      createdAt: drift.Value(entity.createdAt),
      updatedAt: drift.Value(entity.updatedAt),
      deletedAt: entity.deletedAt != null
          ? drift.Value(entity.deletedAt!)
          : const drift.Value.absent(),
    );
  }

  /// Convierte de WorkoutEntity (Domain) a WorkoutsCompanion para inserción
  static WorkoutsCompanion toCompanionForInsert(WorkoutEntity entity) {
    return WorkoutsCompanion.insert(
      name: entity.name,
      muscleGroups: _encodeMuscleGroups(entity.muscleGroups),
      date: entity.date,
      durationMinutes: entity.durationMinutes != null
          ? drift.Value(entity.durationMinutes!)
          : const drift.Value.absent(),
      notes: entity.notes != null
          ? drift.Value(entity.notes!)
          : const drift.Value.absent(),
      createdAt: drift.Value(entity.createdAt),
      updatedAt: drift.Value(entity.updatedAt),
      deletedAt: entity.deletedAt != null
          ? drift.Value(entity.deletedAt!)
          : const drift.Value.absent(),
    );
  }

  /// Decodifica muscleGroups desde JSON string a List<MuscleGroup>
  static List<MuscleGroup> _decodeMuscleGroups(String json) {
    try {
      final List<dynamic> decoded = jsonDecode(json);
      return decoded
          .map((value) => MuscleGroup.fromValue(value.toString()))
          .toList();
    } catch (e) {
      // Fallback: retornar lista vacía si hay error
      return [];
    }
  }

  /// Codifica List<MuscleGroup> a JSON string
  static String _encodeMuscleGroups(List<MuscleGroup> groups) {
    final List<String> values = groups.map((g) => g.value).toList();
    return jsonEncode(values);
  }
}

/// Mapper para Exercise
class ExerciseMapper {
  /// Convierte de Exercise (Drift) a ExerciseEntity (Domain)
  static ExerciseEntity toEntity(Exercise exercise) {
    return ExerciseEntity(
      id: exercise.id,
      workoutId: exercise.workoutId,
      name: exercise.name,
      sets: exercise.sets,
      reps: exercise.reps,
      weight: exercise.weight,
      notes: exercise.notes,
      createdAt: exercise.createdAt,
      updatedAt: exercise.updatedAt,
      deletedAt: exercise.deletedAt,
    );
  }

  /// Convierte de ExerciseEntity (Domain) a ExercisesCompanion (Drift)
  static ExercisesCompanion toCompanion(ExerciseEntity entity) {
    return ExercisesCompanion(
      id: drift.Value(entity.id),
      workoutId: drift.Value(entity.workoutId),
      name: drift.Value(entity.name),
      sets: drift.Value(entity.sets),
      reps: drift.Value(entity.reps),
      weight: drift.Value(entity.weight),
      notes: entity.notes != null
          ? drift.Value(entity.notes!)
          : const drift.Value.absent(),
      createdAt: drift.Value(entity.createdAt),
      updatedAt: drift.Value(entity.updatedAt),
      deletedAt: entity.deletedAt != null
          ? drift.Value(entity.deletedAt!)
          : const drift.Value.absent(),
    );
  }

  /// Convierte de ExerciseEntity (Domain) a ExercisesCompanion para inserción
  static ExercisesCompanion toCompanionForInsert(ExerciseEntity entity) {
    return ExercisesCompanion.insert(
      workoutId: entity.workoutId,
      name: entity.name,
      sets: entity.sets,
      reps: entity.reps,
      weight: entity.weight,
      notes: entity.notes != null
          ? drift.Value(entity.notes!)
          : const drift.Value.absent(),
      createdAt: drift.Value(entity.createdAt),
      updatedAt: drift.Value(entity.updatedAt),
      deletedAt: entity.deletedAt != null
          ? drift.Value(entity.deletedAt!)
          : const drift.Value.absent(),
    );
  }
}
