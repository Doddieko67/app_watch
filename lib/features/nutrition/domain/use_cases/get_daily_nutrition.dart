import '../repositories/nutrition_repository.dart';

/// Use case para obtener el resumen nutricional del día
class GetDailyNutrition {
  final INutritionRepository _repository;

  GetDailyNutrition(this._repository);

  /// Obtiene el resumen nutricional completo de un día específico
  ///
  /// Incluye:
  /// - Total de calorías, proteínas, carbohidratos y grasas
  /// - Cantidad de comidas registradas
  /// - Objetivos nutricionales activos
  /// - Progreso hacia los objetivos
  Future<DailyNutritionSummary> call(DateTime date) async {
    // Normalizar la fecha a medianoche
    final normalizedDate = DateTime(date.year, date.month, date.day);

    return await _repository.getDailyNutrition(normalizedDate);
  }

  /// Obtiene el resumen de múltiples días
  Future<List<DailyNutritionSummary>> getWeeklySummary(DateTime startDate) async {
    final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
    final end = normalizedStart.add(const Duration(days: 7));

    return await _repository.getNutritionSummaryByDateRange(
      normalizedStart,
      end,
    );
  }
}
