import '../entities/workout_entity.dart';
import '../repositories/fitness_repository.dart';

/// Use Case: Crear Workout
///
/// Crea un nuevo workout en el sistema
class CreateWorkout {
  final FitnessRepository _repository;

  CreateWorkout(this._repository);

  /// Ejecuta el caso de uso
  ///
  /// Returns: ID del workout creado
  Future<int> call(WorkoutEntity workout) async {
    // Asegurar que las fechas de creación/actualización estén establecidas
    final workoutWithTimestamps = workout.copyWith(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await _repository.createWorkout(workoutWithTimestamps);
  }
}
