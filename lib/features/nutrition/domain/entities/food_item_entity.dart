import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_item_entity.freezed.dart';

/// Entidad que representa un ítem de comida individual
@freezed
class FoodItemEntity with _$FoodItemEntity {
  const factory FoodItemEntity({
    /// ID único del ítem
    required int id,

    /// ID de la comida a la que pertenece
    required int mealId,

    /// Nombre del alimento
    required String name,

    /// Cantidad (en gramos o unidades)
    required double quantity,

    /// Unidad de medida (g, ml, unidad)
    required String unit,

    /// Calorías
    required double calories,

    /// Proteínas en gramos
    required double protein,

    /// Carbohidratos en gramos
    required double carbs,

    /// Grasas en gramos
    required double fats,

    /// Fuente de datos (ai, cache, local_db, manual)
    required String source,

    /// Respuesta completa de AI (JSON) para cache
    String? aiResponse,

    /// Fecha de creación
    required DateTime createdAt,

    /// Fecha de última actualización
    required DateTime updatedAt,

    /// Fecha de eliminación (soft delete)
    DateTime? deletedAt,
  }) = _FoodItemEntity;
}
