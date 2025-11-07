import '../entities/food_analysis_result.dart';
import '../repositories/nutrition_repository.dart';

/// Use case para obtener análisis de alimentos desde cache
class GetCachedFood {
  final INutritionRepository _repository;

  GetCachedFood(this._repository);

  /// Busca en el cache de IA por un input específico
  Future<FoodAnalysisResult?> call(String input) async {
    if (input.trim().isEmpty) {
      return null;
    }

    return await _repository.getCachedFoodAnalysis(input);
  }
}
