import 'package:freezed_annotation/freezed_annotation.dart';
import 'food_item_entity.dart';

part 'meal_entity.freezed.dart';

/// Tipo de comida
enum MealType {
  breakfast('Desayuno'),
  lunch('Almuerzo'),
  dinner('Cena'),
  snack('Snack');

  const MealType(this.displayName);
  final String displayName;
}

/// Entidad que representa una comida (desayuno, almuerzo, cena, snack)
@freezed
class MealEntity with _$MealEntity {
  const factory MealEntity({
    /// ID único de la comida
    required int id,

    /// Fecha y hora de la comida
    required DateTime date,

    /// Tipo de comida (breakfast, lunch, dinner, snack)
    required String mealType,

    /// Total de calorías calculadas
    required double totalCalories,

    /// Total de proteínas calculadas
    required double totalProtein,

    /// Total de carbohidratos calculados
    required double totalCarbs,

    /// Total de grasas calculadas
    required double totalFats,

    /// Notas adicionales
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

  const MealEntity._();

  /// Convierte el string de mealType a enum
  MealType get mealTypeEnum {
    switch (mealType) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'dinner':
        return MealType.dinner;
      case 'snack':
        return MealType.snack;
      default:
        return MealType.snack;
    }
  }
}
