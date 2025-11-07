import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/meal_entity.dart';
import 'food_item_model.dart';

/// Mapper para convertir entre Meal (Drift) y MealEntity (Domain)
class MealModel {
  /// Convierte de Meal (Drift) a MealEntity (Domain)
  static MealEntity toEntity(
    Meal data, {
    List<FoodItem>? foodItems,
  }) {
    return MealEntity(
      id: data.id,
      date: data.date,
      mealType: data.mealType,
      totalCalories: data.totalCalories,
      totalProtein: data.totalProtein,
      totalCarbs: data.totalCarbs,
      totalFats: data.totalFats,
      notes: data.notes,
      foodItems: foodItems != null
          ? foodItems.map(FoodItemModel.toEntity).toList()
          : [],
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      deletedAt: data.deletedAt,
    );
  }

  /// Convierte de MealEntity (Domain) a MealsCompanion (Drift insert/update)
  static MealsCompanion toCompanion(MealEntity entity, {bool isUpdate = false}) {
    return MealsCompanion.insert(
      id: isUpdate ? Value(entity.id) : const Value.absent(),
      date: entity.date,
      mealType: entity.mealType,
      totalCalories: entity.totalCalories,
      totalProtein: entity.totalProtein,
      totalCarbs: entity.totalCarbs,
      totalFats: entity.totalFats,
      notes: Value(entity.notes),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      deletedAt: Value(entity.deletedAt),
      syncStatus: const Value(0),
    );
  }
}
