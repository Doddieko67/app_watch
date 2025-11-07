import '../entities/food_analysis_result.dart';
import '../entities/food_item_entity.dart';
import '../entities/meal_entity.dart';
import '../entities/nutrition_goals_entity.dart';

/// Repository interface para el módulo de nutrición
abstract class INutritionRepository {
  // ==================== MEALS ====================

  /// Crea una nueva comida
  Future<MealEntity> createMeal({
    required DateTime date,
    required String mealType,
    String? notes,
  });

  /// Obtiene una comida por ID
  Future<MealEntity?> getMealById(int id);

  /// Obtiene todas las comidas de una fecha
  Future<List<MealEntity>> getMealsByDate(DateTime date);

  /// Obtiene comidas en un rango de fechas
  Future<List<MealEntity>> getMealsByDateRange(DateTime start, DateTime end);

  /// Actualiza una comida
  Future<MealEntity> updateMeal(MealEntity meal);

  /// Elimina una comida (soft delete)
  Future<void> deleteMeal(int id);

  /// Recalcula los totales de macros de una comida
  Future<MealEntity> recalculateMealTotals(int mealId);

  // ==================== FOOD ITEMS ====================

  /// Agrega un ítem de comida a una comida
  Future<FoodItemEntity> addFoodItem({
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
  });

  /// Obtiene todos los ítems de una comida
  Future<List<FoodItemEntity>> getFoodItemsByMealId(int mealId);

  /// Actualiza un ítem de comida
  Future<FoodItemEntity> updateFoodItem(FoodItemEntity foodItem);

  /// Elimina un ítem de comida (soft delete)
  Future<void> deleteFoodItem(int id);

  // ==================== NUTRITION GOALS ====================

  /// Crea objetivos nutricionales
  Future<NutritionGoalsEntity> createNutritionGoals({
    required double dailyCalories,
    required double dailyProtein,
    required double dailyCarbs,
    required double dailyFats,
  });

  /// Obtiene los objetivos nutricionales activos
  Future<NutritionGoalsEntity?> getActiveNutritionGoals();

  /// Actualiza objetivos nutricionales
  Future<NutritionGoalsEntity> updateNutritionGoals(
    NutritionGoalsEntity goals,
  );

  /// Desactiva objetivos nutricionales anteriores
  Future<void> deactivateOldGoals();

  // ==================== AI & ANALYSIS ====================

  /// Analiza un alimento con IA (flujo completo de fallback)
  Future<FoodAnalysisResult> analyzeFood(String input);

  /// Busca en cache de IA
  Future<FoodAnalysisResult?> getCachedFoodAnalysis(String input);

  /// Busca en base de datos local de alimentos
  Future<FoodAnalysisResult?> searchLocalFoodDb(String query);

  // ==================== STATISTICS ====================

  /// Obtiene nutrición total del día
  Future<DailyNutritionSummary> getDailyNutrition(DateTime date);

  /// Obtiene resumen nutricional de un rango de fechas
  Future<List<DailyNutritionSummary>> getNutritionSummaryByDateRange(
    DateTime start,
    DateTime end,
  );

  /// Obtiene alimentos más frecuentes
  Future<List<FoodFrequency>> getMostFrequentFoods({int limit = 10});
}

/// Resumen nutricional diario
class DailyNutritionSummary {
  final DateTime date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;
  final int mealsCount;
  final NutritionGoalsEntity? goals;

  DailyNutritionSummary({
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
    required this.mealsCount,
    this.goals,
  });

  /// Porcentaje de calorías consumidas vs objetivo
  double get caloriesProgress {
    if (goals == null || goals!.dailyCalories == 0) return 0;
    return (totalCalories / goals!.dailyCalories * 100).clamp(0, 100);
  }

  /// Porcentaje de proteínas consumidas vs objetivo
  double get proteinProgress {
    if (goals == null || goals!.dailyProtein == 0) return 0;
    return (totalProtein / goals!.dailyProtein * 100).clamp(0, 100);
  }

  /// Porcentaje de carbohidratos consumidos vs objetivo
  double get carbsProgress {
    if (goals == null || goals!.dailyCarbs == 0) return 0;
    return (totalCarbs / goals!.dailyCarbs * 100).clamp(0, 100);
  }

  /// Porcentaje de grasas consumidas vs objetivo
  double get fatsProgress {
    if (goals == null || goals!.dailyFats == 0) return 0;
    return (totalFats / goals!.dailyFats * 100).clamp(0, 100);
  }
}

/// Frecuencia de alimentos
class FoodFrequency {
  final String foodName;
  final int count;
  final double avgQuantity;

  FoodFrequency({
    required this.foodName,
    required this.count,
    required this.avgQuantity,
  });
}
