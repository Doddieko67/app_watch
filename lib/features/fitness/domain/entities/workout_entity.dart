import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_entity.freezed.dart';

/// Entity de Workout
///
/// Representa un entrenamiento en el dominio de la aplicación
@freezed
class WorkoutEntity with _$WorkoutEntity {
  const factory WorkoutEntity({
    required int id,
    required String name,
    required List<MuscleGroup> muscleGroups,
    required DateTime date,
    int? durationMinutes,
    String? notes,
    required List<ExerciseEntity> exercises,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _WorkoutEntity;

  const WorkoutEntity._();

  /// Verifica si el workout es de hoy
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Calcula el volumen total del workout (sets * reps * weight)
  double get totalVolume {
    return exercises.fold(0.0, (sum, exercise) {
      return sum + (exercise.sets * exercise.reps * exercise.weight);
    });
  }

  /// Número total de ejercicios
  int get exerciseCount => exercises.length;

  /// Número total de sets
  int get totalSets {
    return exercises.fold(0, (sum, exercise) => sum + exercise.sets);
  }

  /// Duración formateada (e.g., "1h 30m")
  String get formattedDuration {
    if (durationMinutes == null) return 'N/A';
    final hours = durationMinutes! ~/ 60;
    final minutes = durationMinutes! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

/// Entity de Exercise
///
/// Representa un ejercicio dentro de un workout
@freezed
class ExerciseEntity with _$ExerciseEntity {
  const factory ExerciseEntity({
    required int id,
    required int workoutId,
    required String name,
    required int sets,
    required int reps,
    required double weight, // en kg
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _ExerciseEntity;

  const ExerciseEntity._();

  /// Calcula el volumen del ejercicio (sets * reps * weight)
  double get volume => sets * reps * weight;

  /// Formato de resumen (e.g., "3x10 @ 80kg")
  String get summary => '$sets x $reps @ ${weight}kg';
}

/// Enum de Grupos Musculares
enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  forearms,
  abs,
  quads,
  hamstrings,
  glutes,
  calves,
  cardio;

  String get displayName {
    switch (this) {
      case MuscleGroup.chest:
        return 'Pecho';
      case MuscleGroup.back:
        return 'Espalda';
      case MuscleGroup.shoulders:
        return 'Hombros';
      case MuscleGroup.biceps:
        return 'Bíceps';
      case MuscleGroup.triceps:
        return 'Tríceps';
      case MuscleGroup.forearms:
        return 'Antebrazos';
      case MuscleGroup.abs:
        return 'Abdomen';
      case MuscleGroup.quads:
        return 'Cuádriceps';
      case MuscleGroup.hamstrings:
        return 'Isquiotibiales';
      case MuscleGroup.glutes:
        return 'Glúteos';
      case MuscleGroup.calves:
        return 'Pantorrillas';
      case MuscleGroup.cardio:
        return 'Cardio';
    }
  }

  String get value {
    return name;
  }

  static MuscleGroup fromValue(String value) {
    return MuscleGroup.values.firstWhere(
      (group) => group.name == value,
      orElse: () => MuscleGroup.chest,
    );
  }

  /// Emoji asociado al grupo muscular
  String get emoji {
    switch (this) {
      case MuscleGroup.chest:
        return '💪';
      case MuscleGroup.back:
        return '🦾';
      case MuscleGroup.shoulders:
        return '🤸';
      case MuscleGroup.biceps:
        return '💪';
      case MuscleGroup.triceps:
        return '💪';
      case MuscleGroup.forearms:
        return '✊';
      case MuscleGroup.abs:
        return '🔥';
      case MuscleGroup.quads:
        return '🦵';
      case MuscleGroup.hamstrings:
        return '🦵';
      case MuscleGroup.glutes:
        return '🍑';
      case MuscleGroup.calves:
        return '👟';
      case MuscleGroup.cardio:
        return '❤️';
    }
  }
}
