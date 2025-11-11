import 'package:freezed_annotation/freezed_annotation.dart';
import 'food_item_entity.dart';

part 'meal_entity.freezed.dart';

/// Entidad que representa una comida registrada en un día específico
/// Sin tipos de comida - solo fecha/hora y alimentos
@freezed
class MealEntity with _$MealEntity {
  const factory MealEntity({
    /// ID único de la comida
    required int id,

    /// Fecha y hora de la comida
    required DateTime date,

    /// Total de calorías calculadas
    required double totalCalories,

    /// Total de proteínas calculadas
    required double totalProtein,

    /// Total de carbohidratos calculados
    required double totalCarbs,

    /// Total de grasas calculadas
    required double totalFats,

    /// Notas adicionales (opcional)
    String? notes,

    /// Items de comida asociados (lazy loading)
    @Default([]) List<FoodItemEntity> foodItems,

    /// Fecha de creación
    required DateTime createdAt,

    /// Fecha de última actualización
    required DateTime updatedAt,

    /// Fecha de eliminación (soft delete)
    DateTime? deletedAt,
  }) = _MealEntity;
}
