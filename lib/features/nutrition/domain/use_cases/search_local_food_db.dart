import '../entities/food_analysis_result.dart';
import '../repositories/nutrition_repository.dart';

/// Use case para buscar alimentos en la base de datos local
class SearchLocalFoodDb {
  final INutritionRepository _repository;

  SearchLocalFoodDb(this._repository);

  /// Busca alimentos en la base de datos local (nutrition_database.json)
  ///
  /// Utiliza búsqueda fuzzy con algoritmo de Levenshtein
  Future<FoodAnalysisResult?> call(String query) async {
    if (query.trim().isEmpty) {
      return null;
    }

    return await _repository.searchLocalFoodDb(query);
  }
}
