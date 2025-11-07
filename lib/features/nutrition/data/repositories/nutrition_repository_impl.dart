import '../../../../core/services/ai_service.dart';
import '../../domain/entities/food_analysis_result.dart';
import '../../domain/entities/food_item_entity.dart';
import '../../domain/entities/meal_entity.dart';
import '../../domain/entities/nutrition_goals_entity.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../datasources/nutrition_local_datasource.dart';

/// Implementación del repositorio de nutrición
class NutritionRepositoryImpl implements INutritionRepository {
  final NutritionLocalDataSource _localDataSource;
  final AiService _aiService;

  NutritionRepositoryImpl(this._localDataSource, this._aiService);

  // ==================== MEALS ====================

  @override
  Future<MealEntity> createMeal({
    required DateTime date,
    required String mealType,
    String? notes,
  }) {
    return _localDataSource.createMeal(
      date: date,
      mealType: mealType,
      notes: notes,
    );
  }

  @override
  Future<MealEntity?> getMealById(int id) {
    return _localDataSource.getMealById(id);
  }

  @override
  Future<List<MealEntity>> getMealsByDate(DateTime date) {
    return _localDataSource.getMealsByDate(date);
  }

  @override
  Future<List<MealEntity>> getMealsByDateRange(DateTime start, DateTime end) {
    return _localDataSource.getMealsByDateRange(start, end);
  }

  @override
  Future<MealEntity> updateMeal(MealEntity meal) {
    return _localDataSource.updateMeal(meal);
  }

  @override
  Future<void> deleteMeal(int id) {
    return _localDataSource.deleteMeal(id);
  }

  @override
  Future<MealEntity> recalculateMealTotals(int mealId) {
    return _localDataSource.recalculateMealTotals(mealId);
  }

  // ==================== FOOD ITEMS ====================

  @override
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
  }) {
    return _localDataSource.addFoodItem(
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
  }

  @override
  Future<List<FoodItemEntity>> getFoodItemsByMealId(int mealId) {
    return _localDataSource.getFoodItemsByMealId(mealId);
  }

  @override
  Future<FoodItemEntity> updateFoodItem(FoodItemEntity foodItem) {
    return _localDataSource.updateFoodItem(foodItem);
  }

  @override
  Future<void> deleteFoodItem(int id) {
    return _localDataSource.deleteFoodItem(id);
  }

  // ==================== NUTRITION GOALS ====================

  @override
  Future<NutritionGoalsEntity> createNutritionGoals({
    required double dailyCalories,
    required double dailyProtein,
    required double dailyCarbs,
    required double dailyFats,
  }) {
    return _localDataSource.createNutritionGoals(
      dailyCalories: dailyCalories,
      dailyProtein: dailyProtein,
      dailyCarbs: dailyCarbs,
      dailyFats: dailyFats,
    );
  }

  @override
  Future<NutritionGoalsEntity?> getActiveNutritionGoals() {
    return _localDataSource.getActiveNutritionGoals();
  }

  @override
  Future<NutritionGoalsEntity> updateNutritionGoals(
    NutritionGoalsEntity goals,
  ) {
    return _localDataSource.updateNutritionGoals(goals);
  }

  @override
  Future<void> deactivateOldGoals() {
    return _localDataSource.deactivateOldGoals();
  }

  // ==================== AI & ANALYSIS ====================

  @override
  Future<FoodAnalysisResult> analyzeFood(String input) {
    // El AiService ya maneja el flujo completo de fallback
    return _aiService.analyzeFood(input);
  }

  @override
  Future<FoodAnalysisResult?> getCachedFoodAnalysis(String input) async {
    // Por ahora retornamos null, se puede implementar búsqueda directa en cache
    return null;
  }

  @override
  Future<FoodAnalysisResult?> searchLocalFoodDb(String query) async {
    // Por ahora retornamos null, se puede implementar búsqueda directa
    return null;
  }

  // ==================== STATISTICS ====================

  @override
  Future<DailyNutritionSummary> getDailyNutrition(DateTime date) {
    return _localDataSource.getDailyNutrition(date);
  }

  @override
  Future<List<DailyNutritionSummary>> getNutritionSummaryByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _localDataSource.getNutritionSummaryByDateRange(start, end);
  }

  @override
  Future<List<FoodFrequency>> getMostFrequentFoods({int limit = 10}) {
    return _localDataSource.getMostFrequentFoods(limit: limit);
  }
}
