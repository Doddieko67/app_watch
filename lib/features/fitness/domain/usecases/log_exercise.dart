import '../entities/workout_entity.dart';
import '../repositories/fitness_repository.dart';

/// Use Case: Registrar Ejercicio
///
/// Registra un nuevo ejercicio en un workout existente
class LogExercise {
  final FitnessRepository _repository;

  LogExercise(this._repository);

  /// Ejecuta el caso de uso
  ///
  /// Returns: ID del ejercicio creado
  Future<int> call(ExerciseEntity exercise) async {
    // Asegurar que las fechas de creación/actualización estén establecidas
    final exerciseWithTimestamps = exercise.copyWith(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await _repository.createExercise(exerciseWithTimestamps);
  }
}
