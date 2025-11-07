import '../entities/meal_entity.dart';
import '../repositories/nutrition_repository.dart';

/// Use case para registrar una nueva comida
class LogMeal {
  final INutritionRepository _repository;

  LogMeal(this._repository);

  /// Ejecuta el caso de uso para crear una nueva comida
  Future<MealEntity> call({
    required DateTime date,
    required String mealType,
    String? notes,
  }) async {
    // Validar tipo de comida
    if (!['breakfast', 'lunch', 'dinner', 'snack'].contains(mealType)) {
      throw ArgumentError('Invalid meal type: $mealType');
    }

    // Crear la comida
    return await _repository.createMeal(
      date: date,
      mealType: mealType,
      notes: notes,
    );
  }
}
