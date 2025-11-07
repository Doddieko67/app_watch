import '../entities/food_analysis_result.dart';
import '../repositories/nutrition_repository.dart';

/// Use case para analizar un alimento con IA
///
/// Flujo: Cache → Gemini API → DB Local → Manual
class AnalyzeFoodWithAI {
  final INutritionRepository _repository;

  AnalyzeFoodWithAI(this._repository);

  /// Ejecuta el análisis completo de un alimento
  ///
  /// El flujo de fallback es:
  /// 1. Buscar en cache (instantáneo)
  /// 2. Si no está en cache, llamar a Gemini (online)
  /// 3. Si Gemini falla, buscar en DB local (offline)
  /// 4. Si no hay match, retornar que requiere entrada manual
  Future<FoodAnalysisResult> call(String input) async {
    if (input.trim().isEmpty) {
      throw ArgumentError('Input cannot be empty');
    }

    // El repository maneja todo el flujo de fallback
    return await _repository.analyzeFood(input);
  }
}
