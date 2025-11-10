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
      model: 'gemini-flash-latest', // Usa la versión más reciente de Gemini Flash (2.5)
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.2, // Temperatura moderada para respuestas más creativas pero consistentes
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
        responseMimeType: 'application/json', // Forzar respuesta JSON
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
        SafetySetting(
          HarmCategory.sexuallyExplicit,
          HarmBlockThreshold.none,
        ),
        SafetySetting(
          HarmCategory.dangerousContent,
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

    // Usar la configuración del modelo ya configurada (no sobreescribir)
    final response = await _geminiModel!.generateContent(content);

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
Eres un nutricionista experto con acceso a bases de datos nutricionales (USDA, FatSecret, tablas nutricionales oficiales).

Analiza este alimento: "$input"

Debes responder SIEMPRE con un JSON válido siguiendo este formato EXACTO:

{
  "name": "nombre del alimento en español",
  "quantity": número_en_gramos,
  "unit": "g",
  "calories": número_calorías,
  "protein": número_proteínas_gramos,
  "carbs": número_carbohidratos_gramos,
  "fats": número_grasas_gramos,
  "confidence": número_entre_0_y_1
}

REGLAS CRÍTICAS:
1. Si no se especifica cantidad, usa 100g
2. Si dice "1 manzana", "2 huevos", etc., estima gramos (1 manzana = 180g, 1 huevo = 50g, 1 plátano = 120g)
3. USA TU CONOCIMIENTO NUTRICIONAL: Conoces las calorías y macros de miles de alimentos comunes
4. Ejemplos que DEBES conocer:
   - Pollo: 165 cal, 31g proteína, 0g carbs, 3.6g grasas (por 100g)
   - Arroz cocido: 130 cal, 2.7g proteína, 28g carbs, 0.3g grasas (por 100g)
   - Huevo: 155 cal, 13g proteína, 1.1g carbs, 11g grasas (por 100g)
   - Plátano: 89 cal, 1.1g proteína, 23g carbs, 0.3g grasas (por 100g)
5. Confidence: 1.0 si es alimento común, 0.8 si es estimación, 0.6 si es aproximación
6. Los valores NUNCA pueden ser 0 a menos que el alimento realmente carezca de ese macro (ej: pollo 0g carbs)
7. Calcula proporcionalmente si la cantidad es diferente de 100g

IMPORTANTE: Tu respuesta DEBE ser SOLO el JSON, sin markdown ni explicaciones.
''';
  }

  /// Extrae JSON de la respuesta de texto
  Map<String, dynamic> _extractJson(String text) {
    // Limpiar texto de markdown y espacios
    String cleaned = text.trim();

    // Remover bloques de código markdown si existen
    cleaned = cleaned.replaceAll(RegExp(r'```json\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'```\s*'), '');

    // Intentar parsear directamente
    try {
      return jsonDecode(cleaned);
    } catch (_) {
      // Buscar JSON dentro del texto (incluso con nested objects)
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
      if (jsonMatch != null) {
        try {
          return jsonDecode(jsonMatch.group(0)!);
        } catch (_) {
          // Intentar regex más estricto para JSON simple
          final simpleJsonMatch = RegExp(
            r'\{\s*"name"\s*:\s*"[^"]+"\s*,\s*"quantity"\s*:\s*\d+\.?\d*\s*,\s*"unit"\s*:\s*"[^"]+"\s*,\s*"calories"\s*:\s*\d+\.?\d*\s*,\s*"protein"\s*:\s*\d+\.?\d*\s*,\s*"carbs"\s*:\s*\d+\.?\d*\s*,\s*"fats"\s*:\s*\d+\.?\d*\s*,\s*"confidence"\s*:\s*\d+\.?\d*\s*\}',
          ).firstMatch(cleaned);
          if (simpleJsonMatch != null) {
            return jsonDecode(simpleJsonMatch.group(0)!);
          }
        }
      }
      throw FormatException('No valid JSON found in response: $text');
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
