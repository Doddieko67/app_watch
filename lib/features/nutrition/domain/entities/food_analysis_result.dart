import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_analysis_result.freezed.dart';

/// Fuentes de análisis de alimentos
enum FoodAnalysisSource {
  cache, // Desde AiCache (instantáneo)
  gemini, // Desde Gemini API (online)
  localDb, // Desde nutrition_database.json (offline)
  manual, // Entrada manual del usuario
  error, // Error en el proceso
}

/// Resultado del análisis de alimentos con IA
@freezed
class FoodAnalysisResult with _$FoodAnalysisResult {
  const factory FoodAnalysisResult({
    /// Datos del análisis de alimentos
    FoodData? data,

    /// Fuente del análisis
    required FoodAnalysisSource source,

    /// Indica si requiere entrada manual
    @Default(false) bool requiresManualInput,

    /// Mensaje de error si lo hay
    String? errorMessage,

    /// Nivel de confianza del análisis (0.0 - 1.0)
    @Default(1.0) double confidence,
  }) = _FoodAnalysisResult;
}

/// Datos nutricionales de un alimento
@freezed
class FoodData with _$FoodData {
  const factory FoodData({
    /// Nombre normalizado del alimento
    required String name,

    /// Cantidad en gramos
    required double quantity,

    /// Unidad de medida
    @Default('g') String unit,

    /// Calorías totales
    required double calories,

    /// Proteínas en gramos
    required double protein,

    /// Carbohidratos en gramos
    required double carbs,

    /// Grasas en gramos
    required double fats,
  }) = _FoodData;

  factory FoodData.fromJson(Map<String, dynamic> json) {
    return FoodData(
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'g',
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
    );
  }

  const FoodData._();

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
      };
}
