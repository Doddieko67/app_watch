import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/nutrition_goals_entity.dart';

/// Mapper para convertir entre NutritionGoal (Drift) y NutritionGoalsEntity (Domain)
class NutritionGoalsModel {
  /// Convierte de NutritionGoal (Drift) a NutritionGoalsEntity (Domain)
  static NutritionGoalsEntity toEntity(NutritionGoal data) {
    return NutritionGoalsEntity(
      id: data.id,
      dailyCalories: data.dailyCalories,
      dailyProtein: data.dailyProtein,
      dailyCarbs: data.dailyCarbs,
      dailyFats: data.dailyFats,
      isActive: data.isActive,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  /// Convierte de NutritionGoalsEntity (Domain) a NutritionGoalsCompanion (Drift insert/update)
  static NutritionGoalsCompanion toCompanion(
    NutritionGoalsEntity entity, {
    bool isUpdate = false,
  }) {
    return NutritionGoalsCompanion.insert(
      id: isUpdate ? Value(entity.id) : const Value.absent(),
      dailyCalories: entity.dailyCalories,
      dailyProtein: entity.dailyProtein,
      dailyCarbs: entity.dailyCarbs,
      dailyFats: entity.dailyFats,
      isActive: Value(entity.isActive),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }
}
