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
    required WorkoutSplit split,
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

/// Enum de Tipo de Split de Entrenamiento
enum WorkoutSplit {
  push,
  pull,
  legs,
  upperBody,
  lowerBody,
  fullBody,
  custom;

  String get displayName {
    switch (this) {
      case WorkoutSplit.push:
        return 'Push (Empuje)';
      case WorkoutSplit.pull:
        return 'Pull (Jalón)';
      case WorkoutSplit.legs:
        return 'Piernas';
      case WorkoutSplit.upperBody:
        return 'Tren Superior';
      case WorkoutSplit.lowerBody:
        return 'Tren Inferior';
      case WorkoutSplit.fullBody:
        return 'Cuerpo Completo';
      case WorkoutSplit.custom:
        return 'Personalizado';
    }
  }

  String get value {
    switch (this) {
      case WorkoutSplit.push:
        return 'push';
      case WorkoutSplit.pull:
        return 'pull';
      case WorkoutSplit.legs:
        return 'legs';
      case WorkoutSplit.upperBody:
        return 'upper_body';
      case WorkoutSplit.lowerBody:
        return 'lower_body';
      case WorkoutSplit.fullBody:
        return 'full_body';
      case WorkoutSplit.custom:
        return 'custom';
    }
  }

  static WorkoutSplit fromValue(String value) {
    switch (value) {
      case 'push':
        return WorkoutSplit.push;
      case 'pull':
        return WorkoutSplit.pull;
      case 'legs':
        return WorkoutSplit.legs;
      case 'upper_body':
        return WorkoutSplit.upperBody;
      case 'lower_body':
        return WorkoutSplit.lowerBody;
      case 'full_body':
        return WorkoutSplit.fullBody;
      case 'custom':
        return WorkoutSplit.custom;
      default:
        return WorkoutSplit.custom;
    }
  }

  /// Color asociado al split
  String get color {
    switch (this) {
      case WorkoutSplit.push:
        return '#E91E63'; // Rosa
      case WorkoutSplit.pull:
        return '#2196F3'; // Azul
      case WorkoutSplit.legs:
        return '#4CAF50'; // Verde
      case WorkoutSplit.upperBody:
        return '#FF9800'; // Naranja
      case WorkoutSplit.lowerBody:
        return '#9C27B0'; // Morado
      case WorkoutSplit.fullBody:
        return '#F44336'; // Rojo
      case WorkoutSplit.custom:
        return '#607D8B'; // Gris azulado
    }
  }
}
