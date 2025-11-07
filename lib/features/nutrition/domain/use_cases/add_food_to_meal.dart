import '../entities/food_item_entity.dart';
import '../entities/meal_entity.dart';
import '../repositories/nutrition_repository.dart';

/// Use case para agregar un ítem de comida a una comida
class AddFoodToMeal {
  final INutritionRepository _repository;

  AddFoodToMeal(this._repository);

  /// Agrega un ítem de comida a una comida existente
  /// y recalcula los totales de macros
  Future<MealEntity> call({
    required int mealId,
    required String name,
    required double quantity,
    required String unit,
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
    required String source,
    String? aiResponse,
  }) async {
    // Validar datos
    if (name.trim().isEmpty) {
      throw ArgumentError('Food name cannot be empty');
    }
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be greater than 0');
    }

    // Agregar el ítem
    await _repository.addFoodItem(
      mealId: mealId,
      name: name,
      quantity: quantity,
      unit: unit,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
      source: source,
      aiResponse: aiResponse,
    );

    // Recalcular totales de la comida
    return await _repository.recalculateMealTotals(mealId);
  }
}
