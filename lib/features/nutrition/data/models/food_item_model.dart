import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/food_item_entity.dart';

/// Mapper para convertir entre FoodItem (Drift) y FoodItemEntity (Domain)
class FoodItemModel {
  /// Convierte de FoodItem (Drift) a FoodItemEntity (Domain)
  static FoodItemEntity toEntity(FoodItem data) {
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

  /// Convierte de FoodItemEntity (Domain) a FoodItemsCompanion (Drift insert/update)
  static FoodItemsCompanion toCompanion(
    FoodItemEntity entity, {
    bool isUpdate = false,
  }) {
    return FoodItemsCompanion.insert(
      id: isUpdate ? Value(entity.id) : const Value.absent(),
      mealId: entity.mealId,
      name: entity.name,
      quantity: entity.quantity,
      unit: entity.unit,
      calories: entity.calories,
      protein: entity.protein,
      carbs: entity.carbs,
      fats: entity.fats,
      source: entity.source,
      aiResponse: Value(entity.aiResponse),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      deletedAt: Value(entity.deletedAt),
      syncStatus: const Value(0),
    );
  }
}
