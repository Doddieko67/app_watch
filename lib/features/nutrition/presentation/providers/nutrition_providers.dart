import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/services/local_nutrition_database.dart';
import '../../domain/repositories/nutrition_repository.dart' as domain;
import '../../data/datasources/nutrition_local_datasource.dart';
import '../../data/repositories/nutrition_repository_impl.dart';
import '../../domain/entities/meal_entity.dart';
import '../../domain/entities/nutrition_goals_entity.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../../domain/use_cases/add_food_to_meal.dart';
import '../../domain/use_cases/analyze_food_with_ai.dart';
import '../../domain/use_cases/get_daily_nutrition.dart';
import '../../domain/use_cases/log_meal.dart';

// ==================== CORE PROVIDERS ====================

/// Provider para LocalNutritionDatabase
final localNutritionDatabaseProvider = Provider<LocalNutritionDatabase>((ref) {
  final db = LocalNutritionDatabase();
  db.load(); // Cargar al inicializar
  return db;
});

/// Provider para AiService
final aiServiceProvider = Provider<AiService>((ref) {
  final database = ref.watch(appDatabaseProvider);
  final localDb = ref.watch(localNutritionDatabaseProvider);
  return AiService(database, localDb);
});

/// Provider para NutritionLocalDataSource
final nutritionLocalDataSourceProvider =
    Provider<NutritionLocalDataSource>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return NutritionLocalDataSource(database);
});

/// Provider para NutritionRepository
final nutritionRepositoryProvider = Provider<INutritionRepository>((ref) {
  final localDataSource = ref.watch(nutritionLocalDataSourceProvider);
  final aiService = ref.watch(aiServiceProvider);
  return NutritionRepositoryImpl(localDataSource, aiService);
});

// ==================== USE CASES PROVIDERS ====================

final logMealUseCaseProvider = Provider<LogMeal>((ref) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return LogMeal(repository);
});

final analyzeFoodUseCaseProvider = Provider<AnalyzeFoodWithAI>((ref) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return AnalyzeFoodWithAI(repository);
});

final getDailyNutritionUseCaseProvider = Provider<GetDailyNutrition>((ref) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return GetDailyNutrition(repository);
});

final addFoodToMealUseCaseProvider = Provider<AddFoodToMeal>((ref) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return AddFoodToMeal(repository);
});

// ==================== STATE PROVIDERS ====================

/// Provider para la fecha seleccionada en la vista de nutrición
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Provider para obtener comidas del día actual
final todayMealsProvider = FutureProvider<List<MealEntity>>((ref) async {
  final repository = ref.watch(nutritionRepositoryProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return repository.getMealsByDate(selectedDate);
});

/// Provider para resumen nutricional del día
final dailyNutritionSummaryProvider =
    FutureProvider<domain.DailyNutritionSummary>((ref) async {
  final useCase = ref.watch(getDailyNutritionUseCaseProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  return useCase(selectedDate);
});

/// Provider para objetivos nutricionales activos
final activeNutritionGoalsProvider =
    FutureProvider<NutritionGoalsEntity?>((ref) async {
  final repository = ref.watch(nutritionRepositoryProvider);
  return repository.getActiveNutritionGoals();
});

/// Provider para comidas de un rango de fechas (útil para gráficas)
final weeklyNutritionSummaryProvider =
    FutureProvider<List<domain.DailyNutritionSummary>>((ref) async {
  final useCase = ref.watch(getDailyNutritionUseCaseProvider);
  final today = DateTime.now();
  final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  return useCase.getWeeklySummary(startOfWeek);
});

/// Provider para alimentos más frecuentes
final mostFrequentFoodsProvider =
    FutureProvider<List<domain.FoodFrequency>>((ref) async {
  final repository = ref.watch(nutritionRepositoryProvider);
  return repository.getMostFrequentFoods(limit: 10);
});
