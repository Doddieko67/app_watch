import 'package:freezed_annotation/freezed_annotation.dart';

part 'nutrition_goals_entity.freezed.dart';

/// Entidad que representa los objetivos nutricionales diarios
@freezed
class NutritionGoalsEntity with _$NutritionGoalsEntity {
  const factory NutritionGoalsEntity({
    /// ID único del objetivo
    required int id,

    /// Calorías diarias objetivo
    required double dailyCalories,

    /// Proteínas diarias objetivo (gramos)
    required double dailyProtein,

    /// Carbohidratos diarios objetivo (gramos)
    required double dailyCarbs,

    /// Grasas diarias objetivo (gramos)
    required double dailyFats,

    /// Indica si está activo
    @Default(true) bool isActive,

    /// Fecha de creación
    required DateTime createdAt,

    /// Fecha de última actualización
    required DateTime updatedAt,
  }) = _NutritionGoalsEntity;

  const NutritionGoalsEntity._();

  /// Calcula el porcentaje de calorías consumidas vs objetivo
  double calculateCaloriesProgress(double consumed) {
    if (dailyCalories == 0) return 0;
    return (consumed / dailyCalories * 100).clamp(0, 100);
  }

  /// Calcula el porcentaje de proteínas consumidas vs objetivo
  double calculateProteinProgress(double consumed) {
    if (dailyProtein == 0) return 0;
    return (consumed / dailyProtein * 100).clamp(0, 100);
  }

  /// Calcula el porcentaje de carbohidratos consumidos vs objetivo
  double calculateCarbsProgress(double consumed) {
    if (dailyCarbs == 0) return 0;
    return (consumed / dailyCarbs * 100).clamp(0, 100);
  }

  /// Calcula el porcentaje de grasas consumidas vs objetivo
  double calculateFatsProgress(double consumed) {
    if (dailyFats == 0) return 0;
    return (consumed / dailyFats * 100).clamp(0, 100);
  }

  /// Calcula calorías restantes para el día
  double remainingCalories(double consumed) {
    return (dailyCalories - consumed).clamp(0, double.infinity);
  }
}
