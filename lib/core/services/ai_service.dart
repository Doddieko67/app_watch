import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../features/nutrition/domain/entities/food_analysis_result.dart';
import '../database/app_database.dart';
import 'local_nutrition_database.dart';

/// Servicio de IA para análisis de alimentos
///
/// Implementa flujo de fallback:
/// 1. Cache (instantáneo)
/// 2. Gemini API (online, preciso)
/// 3. DB Local (offline, funcional)
/// 4. Manual (usuario ingresa datos)
class AiService {
  final AppDatabase _database;
  final LocalNutritionDatabase _localDb;
  GenerativeModel? _geminiModel;

  AiService(this._database, this._localDb);

  /// Configura el modelo de Gemini con API key
  void configureGemini(String apiKey) {
    _geminiModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.1, // Baja temperatura para respuestas consistentes
        topK: 1,
        topP: 1,
        maxOutputTokens: 500,
      ),
      safetySettings: [
        SafetySetting(
          HarmCategory.harassment,
          HarmBlockThreshold.none,
        ),
        SafetySetting(
          HarmCategory.hateSpeech,
          HarmBlockThreshold.none,
        ),
      ],
    );
  }

  /// Analiza un alimento con flujo de fallback completo
  Future<FoodAnalysisResult> analyzeFood(String input) async {
    // 1. Normalizar y crear hash
    final normalizedInput = _normalizeInput(input);
    final hash = _hashInput(normalizedInput);

    // 2. Buscar en cache
    final cached = await _database.findByHash(hash);
    if (cached != null) {
      // No actualizamos lastUsed por ahora para simplificar
      return FoodAnalysisResult(
        data: FoodData.fromJson(jsonDecode(cached.aiResponse)),
        source: FoodAnalysisSource.cache,
        confidence: 1.0,
      );
    }

    // 3. Verificar conectividad y llamar a Gemini
    if (_geminiModel != null && await _isOnline()) {
      try {
        final result = await _analyzeWithGemini(normalizedInput);

        // Guardar en cache
        await _database.insertCacheEntry(
          AiCacheCompanion.insert(
            queryType: 'food_analysis',
            queryInput: normalizedInput,
            queryHash: hash,
            aiResponse: jsonEncode(result.data!.toJson()),
          ),
        );

        return result;
      } catch (e) {
        // Si falla Gemini, continuar con fallback
        print('Gemini API error: $e');
      }
    }

    // 4. Buscar en DB local
    final localMatch = await _localDb.searchFood(normalizedInput);
    if (localMatch != null) {
      return FoodAnalysisResult(
        data: localMatch,
        source: FoodAnalysisSource.localDb,
        confidence: 0.8,
      );
    }

    // 5. Requiere entrada manual
    return const FoodAnalysisResult(
      requiresManualInput: true,
      source: FoodAnalysisSource.manual,
    );
  }

  /// Analiza un alimento con Gemini
  Future<FoodAnalysisResult> _analyzeWithGemini(String input) async {
    if (_geminiModel == null) {
      throw Exception('Gemini model not configured');
    }

    final prompt = _buildFoodAnalysisPrompt(input);
    final content = [Content.text(prompt)];

    final response = await _geminiModel!.generateContent(
      content,
      generationConfig: GenerationConfig(
        temperature: 0.1,
        maxOutputTokens: 500,
      ),
    );

    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('Empty response from Gemini');
    }

    // Parsear respuesta JSON
    final jsonResponse = _extractJson(text);
    final data = FoodData.fromJson(jsonResponse);
    final confidence = jsonResponse['confidence'] as num? ?? 0.9;

    return FoodAnalysisResult(
      data: data,
      source: FoodAnalysisSource.gemini,
      confidence: confidence.toDouble(),
    );
  }

  /// Construye el prompt para análisis de alimentos
  String _buildFoodAnalysisPrompt(String input) {
    return '''
Analiza el siguiente alimento y devuelve ÚNICAMENTE un JSON con este formato exacto:

{
  "name": "nombre normalizado del alimento",
  "quantity": cantidad numérica en gramos,
  "unit": "g",
  "calories": valor numérico de calorías,
  "protein": valor numérico de proteínas en gramos,
  "carbs": valor numérico de carbohidratos en gramos,
  "fats": valor numérico de grasas en gramos,
  "confidence": valor entre 0.0 y 1.0 indicando certeza
}

Reglas:
- Si el input no especifica cantidad, asume 100g
- Si es una unidad (ej: "1 manzana"), convierte a gramos estimados
- Usa valores nutricionales estándar de bases de datos oficiales (USDA)
- Si hay ambigüedad, elige la opción más común
- La confianza debe ser 1.0 solo para alimentos exactos en bases de datos
- NO incluyas explicaciones, razonamientos ni texto adicional
- SOLO retorna el JSON válido

Alimento: $input
''';
  }

  /// Extrae JSON de la respuesta de texto
  Map<String, dynamic> _extractJson(String text) {
    // Intentar parsear directamente
    try {
      return jsonDecode(text.trim());
    } catch (_) {
      // Buscar JSON dentro del texto
      final jsonMatch = RegExp(r'\{[^{}]*\}').firstMatch(text);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!);
      }
      throw FormatException('No valid JSON found in response');
    }
  }

  /// Normaliza el input del usuario
  String _normalizeInput(String input) {
    return input
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n');
  }

  /// Crea hash SHA256 del input
  String _hashInput(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  /// Verifica conectividad a internet
  Future<bool> _isOnline() async {
    try {
      // Intento simple de verificación
      return true; // Por ahora siempre asumimos online, se puede mejorar
    } catch (_) {
      return false;
    }
  }

  /// Verifica si Gemini está configurado
  bool get isGeminiConfigured => _geminiModel != null;
}
