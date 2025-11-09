import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/food_item_entity.dart';
import '../../domain/entities/meal_entity.dart';
import '../../domain/entities/nutrition_goals_entity.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../models/food_item_model.dart';
import '../models/meal_model.dart';
import '../models/nutrition_goals_model.dart';

/// DataSource local para operaciones de nutrición con Drift
class NutritionLocalDataSource {
  final AppDatabase _database;

  NutritionLocalDataSource(this._database);

  // ==================== MEALS ====================

  Future<MealEntity> createMeal({
    required DateTime date,
    required String mealType,
    String? notes,
  }) async {
    final companion = MealsCompanion.insert(
      date: date,
      mealType: mealType,
      totalCalories: 0,
      totalProtein: 0,
      totalCarbs: 0,
      totalFats: 0,
      notes: Value(notes),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final id = await _database.insertMeal(companion);
    final meal = await _database.getMealById(id);

    return MealModel.toEntity(meal!);
  }

  Future<MealEntity?> getMealById(int id) async {
    final meal = await _database.getMealById(id);
    if (meal == null) return null;

    final foodItems = await _database.getFoodItemsByMealId(id);
    return MealModel.toEntity(meal, foodItems: foodItems);
  }

  Future<List<MealEntity>> getMealsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final meals = await (_database.select(_database.meals)
          ..where((m) =>
              m.date.isBiggerOrEqualValue(startOfDay) &
              m.date.isSmallerThanValue(endOfDay) &
              m.deletedAt.isNull()))
        .get();

    return Future.wait(
      meals.map((meal) async {
        final foodItems = await _database.getFoodItemsByMealId(meal.id);
        return MealModel.toEntity(meal, foodItems: foodItems);
      }),
    );
  }

  Future<List<MealEntity>> getMealsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final meals = await (_database.select(_database.meals)
          ..where((m) =>
              m.date.isBiggerOrEqualValue(start) &
              m.date.isSmallerOrEqualValue(end) &
              m.deletedAt.isNull()))
        .get();

    return Future.wait(
      meals.map((meal) async {
        final foodItems = await _database.getFoodItemsByMealId(meal.id);
        return MealModel.toEntity(meal, foodItems: foodItems);
      }),
    );
  }

  Future<MealEntity> updateMeal(MealEntity meal) async {
    final companion = MealModel.toCompanion(
      meal.copyWith(updatedAt: DateTime.now()),
      isUpdate: true,
    );

    await _database.into(_database.meals).insertOnConflictUpdate(companion);
    final updated = await _database.getMealById(meal.id);
    final foodItems = await _database.getFoodItemsByMealId(meal.id);

    return MealModel.toEntity(updated!, foodItems: foodItems);
  }

  Future<void> deleteMeal(int id) async {
    await (_database.update(_database.meals)..where((m) => m.id.equals(id)))
        .write(MealsCompanion(deletedAt: Value(DateTime.now())));
  }

  Future<MealEntity> recalculateMealTotals(int mealId) async {
    // Get all food items
    final items = await (_database.select(_database.foodItems)
          ..where((f) => f.mealId.equals(mealId) & f.deletedAt.isNull()))
        .get();

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (final item in items) {
      totalCalories += item.calories;
      totalProtein += item.protein;
      totalCarbs += item.carbs;
      totalFats += item.fats;
    }

    final meal = await _database.getMealById(mealId);

    if (meal == null) {
      throw Exception('Meal not found');
    }

    final updatedMeal = meal.copyWith(
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFats: totalFats,
      updatedAt: DateTime.now(),
    );

    await _database.updateMeal(updatedMeal);

    final foodItems = await _database.getFoodItemsByMealId(mealId);
    return MealModel.toEntity(updatedMeal, foodItems: foodItems);
  }

  // ==================== FOOD ITEMS ====================

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
  }) async {
    final companion = FoodItemsCompanion.insert(
      mealId: mealId,
      name: name,
      quantity: quantity,
      unit: unit,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
      source: source,
      aiResponse: Value(aiResponse),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final id = await _database.insertFoodItem(companion);
    final foodItem =
        await (_database.select(_database.foodItems)..where((f) => f.id.equals(id)))
            .getSingle();

    return FoodItemModel.toEntity(foodItem);
  }

  Future<List<FoodItemEntity>> getFoodItemsByMealId(int mealId) async {
    final items = await _database.getFoodItemsByMealId(mealId);
    return items.map((item) => FoodItemModel.toEntity(item)).toList();
  }

  Future<FoodItemEntity> updateFoodItem(FoodItemEntity foodItem) async {
    final companion = FoodItemModel.toCompanion(
      foodItem.copyWith(updatedAt: DateTime.now()),
      isUpdate: true,
    );

    await _database
        .into(_database.foodItems)
        .insertOnConflictUpdate(companion);

    final updated =
        await (_database.select(_database.foodItems)..where((f) => f.id.equals(foodItem.id)))
            .getSingle();

    return FoodItemModel.toEntity(updated);
  }

  Future<void> deleteFoodItem(int id) async {
    await (_database.update(_database.foodItems)..where((f) => f.id.equals(id)))
        .write(FoodItemsCompanion(deletedAt: Value(DateTime.now())));
  }

  // ==================== NUTRITION GOALS ====================

  Future<NutritionGoalsEntity> createNutritionGoals({
    required double dailyCalories,
    required double dailyProtein,
    required double dailyCarbs,
    required double dailyFats,
  }) async {
    // Desactivar objetivos anteriores
    await deactivateOldGoals();

    final companion = NutritionGoalsCompanion.insert(
      dailyCalories: dailyCalories,
      dailyProtein: dailyProtein,
      dailyCarbs: dailyCarbs,
      dailyFats: dailyFats,
      isActive: const Value(true),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final id = await _database.insertNutritionGoal(companion);
    final goal =
        await (_database.select(_database.nutritionGoals)..where((g) => g.id.equals(id)))
            .getSingle();

    return NutritionGoalsModel.toEntity(goal);
  }

  Future<NutritionGoalsEntity?> getActiveNutritionGoals() async {
    final goal = await _database.getActiveNutritionGoal();
    return goal != null ? NutritionGoalsModel.toEntity(goal) : null;
  }

  Future<NutritionGoalsEntity> updateNutritionGoals(
    NutritionGoalsEntity goals,
  ) async {
    final companion = NutritionGoalsModel.toCompanion(
      goals.copyWith(updatedAt: DateTime.now()),
      isUpdate: true,
    );

    await _database
        .into(_database.nutritionGoals)
        .insertOnConflictUpdate(companion);

    final updated =
        await (_database.select(_database.nutritionGoals)..where((g) => g.id.equals(goals.id)))
            .getSingle();

    return NutritionGoalsModel.toEntity(updated);
  }

  Future<void> deactivateOldGoals() async {
    await (_database.update(_database.nutritionGoals)
          ..where((g) => g.isActive.equals(true)))
        .write(const NutritionGoalsCompanion(isActive: Value(false)));
  }

  // ==================== STATISTICS ====================

  Future<DailyNutritionSummary> getDailyNutrition(DateTime date) async {
    final meals = await getMealsByDate(date);

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (final meal in meals) {
      totalCalories += meal.totalCalories;
      totalProtein += meal.totalProtein;
      totalCarbs += meal.totalCarbs;
      totalFats += meal.totalFats;
    }

    final goals = await getActiveNutritionGoals();

    return DailyNutritionSummary(
      date: date,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFats: totalFats,
      mealsCount: meals.length,
      goals: goals,
    );
  }

  Future<List<DailyNutritionSummary>> getNutritionSummaryByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final summaries = <DailyNutritionSummary>[];
    final goals = await getActiveNutritionGoals();

    for (var date = start;
        date.isBefore(end) || date.isAtSameMomentAs(end);
        date = date.add(const Duration(days: 1))) {
      final summary = await getDailyNutrition(date);
      summaries.add(summary);
    }

    return summaries;
  }

  Future<List<FoodFrequency>> getMostFrequentFoods({int limit = 10}) async {
    // Por ahora retornamos lista vacía - se puede implementar con queries más complejas
    return [];
  }

  Future<List<FoodItemEntity>> getRecentUniqueFoods({int limit = 50}) async {
    // Query SQL para obtener alimentos únicos más recientes
    final query = _database.select(_database.foodItems)
      ..where((f) => f.deletedAt.isNull())
      ..orderBy([(f) => OrderingTerm.desc(f.createdAt)])
      ..limit(limit * 3); // Obtenemos más para filtrar duplicados

    final foodItems = await query.get();

    // Filtrar duplicados por nombre (mantener el más reciente de cada nombre)
    final uniqueFoods = <String, FoodItem>{};
    for (final food in foodItems) {
      if (!uniqueFoods.containsKey(food.name)) {
        uniqueFoods[food.name] = food;
      }
    }

    // Convertir a entities y limitar a 'limit'
    final entities = uniqueFoods.values
        .take(limit)
        .map((data) => _mapToEntity(data))
        .toList();

    return entities;
  }

  FoodItemEntity _mapToEntity(FoodItem data) {
    return FoodItemEntity(
      id: data.id,
      mealId: data.mealId,
      name: data.name,
      quantity: data.quantity,
      unit: data.unit,
      calories: data.calories,
      protein: data.protein,
      carbs: data.carbs,
      fats: data.fats,
      source: data.source,
      aiResponse: data.aiResponse,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      deletedAt: data.deletedAt,
    );
  }
}
