# 🤖 Estrategia de IA (Gemini + Fallback)

## Visión General

Sistema inteligente de 3 capas para análisis de alimentos y recomendaciones de fitness:
1. **Cache local** (prioridad máxima, instantáneo)
2. **Gemini API** (online, preciso)
3. **Base de datos local + entrada manual** (offline, funcional)

---

## Flujo de Análisis de Alimentos

```
┌─────────────────────────────────────────┐
│ Usuario ingresa: "pollo 200g"           │
└──────────────┬──────────────────────────┘
               ↓
┌──────────────────────────────────────────┐
│ 1. Normalizar input y calcular hash     │
│    "pollo200g" → hash(SHA256)           │
└──────────────┬───────────────────────────┘
               ↓
┌──────────────────────────────────────────┐
│ 2. Buscar en AiCache (SQLite)           │
│    SELECT * WHERE queryHash = ?         │
└──────────────┬───────────────────────────┘
               ↓
         ┌─────┴─────┐
         │ ¿Existe?  │
         └─────┬─────┘
               │
       ┌───────┴───────┐
       │ SÍ            │ NO
       ↓               ↓
┌──────────────┐  ┌───────────────────────┐
│ Usar cache   │  │ 3. Verificar internet │
│ Actualizar   │  └───────┬───────────────┘
│ lastUsed     │          │
└──────────────┘    ┌─────┴─────┐
                    │ ¿Online?  │
                    └─────┬─────┘
                          │
                  ┌───────┴────────┐
                  │ SÍ             │ NO
                  ↓                ↓
          ┌────────────────┐  ┌──────────────────────┐
          │ 4. Gemini API  │  │ 5. DB Local          │
          │ Guardar cache  │  │ nutrition_db.json    │
          │ Retornar       │  └──────┬───────────────┘
          └────────────────┘         │
                              ┌──────┴──────┐
                              │ ¿Match?     │
                              └──────┬──────┘
                                     │
                             ┌───────┴────────┐
                             │ SÍ             │ NO
                             ↓                ↓
                      ┌─────────────┐  ┌──────────────┐
                      │ Usar local  │  │ 6. Manual    │
                      └─────────────┘  │ Formulario   │
                                       └──────────────┘
```

---

## Implementación: AI Service

### Interfaz Principal

```dart
abstract class IAiService {
  /// Analiza un alimento y retorna valores nutricionales
  Future<FoodAnalysisResult> analyzeFood(String input);

  /// Obtiene recomendaciones de entrenamiento basadas en historial
  Future<WorkoutRecommendation> getWorkoutRecommendations(List<Workout> history);

  /// Verifica conectividad
  Future<bool> isOnline();
}
```

### Flujo de Análisis de Alimentos

```dart
class AiService implements IAiService {
  final GenerativeModel _geminiModel;
  final AppDatabase _database;
  final LocalNutritionDatabase _localDb;

  @override
  Future<FoodAnalysisResult> analyzeFood(String input) async {
    // 1. Normalizar y crear hash
    final normalizedInput = _normalizeInput(input);
    final hash = _hashInput(normalizedInput);

    // 2. Buscar en cache
    final cached = await _database.aiCacheDao.findByHash(hash);
    if (cached != null) {
      await _database.aiCacheDao.updateLastUsed(cached.id);
      return FoodAnalysisResult.fromCache(cached);
    }

    // 3. Verificar conectividad
    if (await isOnline()) {
      try {
        // 4. Llamar a Gemini
        final result = await _analyzeWithGemini(normalizedInput);

        // Guardar en cache
        await _database.aiCacheDao.insert(
          queryType: 'food_analysis',
          queryInput: normalizedInput,
          queryHash: hash,
          aiResponse: jsonEncode(result.toJson()),
        );

        return result;
      } catch (e) {
        // Si falla Gemini, continuar con fallback
        debugPrint('Gemini API error: $e');
      }
    }

    // 5. Buscar en DB local
    final localMatch = await _localDb.searchFood(normalizedInput);
    if (localMatch != null) {
      return FoodAnalysisResult.fromLocalDb(localMatch);
    }

    // 6. Modo manual
    return FoodAnalysisResult.requiresManualInput();
  }

  String _normalizeInput(String input) {
    return input
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }

  String _hashInput(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }
}
```

---

## Prompts Optimizados para Gemini

### Análisis de Alimentos

```dart
static const String foodAnalysisPrompt = '''
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

Alimento: {{INPUT}}
''';
```

### Recomendaciones de Entrenamiento

```dart
static const String workoutRecommendationPrompt = '''
Eres un entrenador personal experto. Analiza el historial de entrenamientos y genera recomendaciones.

Historial de los últimos 7 días (JSON):
{{WORKOUT_HISTORY}}

Genera recomendaciones en formato JSON:

{
  "recommendations": [
    {
      "type": "progressive_overload" | "deload" | "variation" | "rest",
      "exercise": "nombre del ejercicio",
      "current_weight": peso actual en kg,
      "suggested_weight": peso sugerido en kg,
      "reason": "explicación breve en español",
      "priority": "high" | "medium" | "low"
    }
  ],
  "overall_assessment": "evaluación general del progreso en español",
  "confidence": valor entre 0.0 y 1.0
}

Criterios:
- Progressive overload: Si el peso se ha mantenido 3+ sesiones y las reps son consistentes
- Deload: Si hay caída en rendimiento o exceso de volumen
- Variation: Si un músculo está estancado
- Rest: Si hay entrenamientos consecutivos sin descanso

SOLO retorna el JSON válido, sin explicaciones adicionales.
''';
```

---

## Base de Datos Local de Alimentos

### Estructura del JSON

Archivo: `assets/nutrition_database.json`

```json
{
  "version": "1.0.0",
  "last_updated": "2025-11-06",
  "foods": [
    {
      "id": "food_001",
      "name": "Pollo a la plancha",
      "aliases": [
        "pollo",
        "pechuga de pollo",
        "chicken breast",
        "pechuga",
        "pollo plancha"
      ],
      "calories_per_100g": 165,
      "protein_per_100g": 31,
      "carbs_per_100g": 0,
      "fats_per_100g": 3.6,
      "category": "protein",
      "common_serving_sizes": [
        { "description": "1 pechuga mediana", "grams": 150 },
        { "description": "1 taza picada", "grams": 140 }
      ]
    },
    {
      "id": "food_002",
      "name": "Arroz blanco cocido",
      "aliases": [
        "arroz",
        "arroz blanco",
        "white rice",
        "arroz cocido"
      ],
      "calories_per_100g": 130,
      "protein_per_100g": 2.7,
      "carbs_per_100g": 28,
      "fats_per_100g": 0.3,
      "category": "carbs",
      "common_serving_sizes": [
        { "description": "1 taza", "grams": 158 },
        { "description": "1 plato", "grams": 200 }
      ]
    },
    {
      "id": "food_003",
      "name": "Huevo cocido",
      "aliases": [
        "huevo",
        "egg",
        "huevo duro",
        "huevo hervido"
      ],
      "calories_per_100g": 155,
      "protein_per_100g": 13,
      "carbs_per_100g": 1.1,
      "fats_per_100g": 11,
      "category": "protein",
      "common_serving_sizes": [
        { "description": "1 huevo grande", "grams": 50 },
        { "description": "1 huevo mediano", "grams": 44 }
      ]
    }
    // ... 497 alimentos más
  ],
  "categories": {
    "protein": ["Carnes", "Huevos", "Pescados", "Mariscos"],
    "carbs": ["Granos", "Cereales", "Pastas", "Panes"],
    "fats": ["Aceites", "Frutos secos", "Aguacate"],
    "vegetables": ["Verduras", "Hortalizas"],
    "fruits": ["Frutas"],
    "dairy": ["Lácteos", "Quesos", "Yogures"]
  }
}
```

### Búsqueda Fuzzy

```dart
class LocalNutritionDatabase {
  late final List<FoodItem> _foods;

  Future<void> load() async {
    final jsonString = await rootBundle.loadString('assets/nutrition_database.json');
    final json = jsonDecode(jsonString);
    _foods = (json['foods'] as List)
        .map((e) => FoodItem.fromJson(e))
        .toList();
  }

  Future<FoodItem?> searchFood(String query) async {
    final normalized = _normalizeQuery(query);

    // Búsqueda exacta
    for (final food in _foods) {
      if (food.name.toLowerCase() == normalized ||
          food.aliases.any((alias) => alias.toLowerCase() == normalized)) {
        return food;
      }
    }

    // Búsqueda fuzzy (Levenshtein distance)
    FoodItem? bestMatch;
    int bestDistance = 999;

    for (final food in _foods) {
      final distance = _levenshteinDistance(normalized, food.name.toLowerCase());
      if (distance < bestDistance && distance <= 3) {
        bestDistance = distance;
        bestMatch = food;
      }

      // También buscar en aliases
      for (final alias in food.aliases) {
        final aliasDistance = _levenshteinDistance(normalized, alias.toLowerCase());
        if (aliasDistance < bestDistance && aliasDistance <= 3) {
          bestDistance = aliasDistance;
          bestMatch = food;
        }
      }
    }

    return bestMatch;
  }

  int _levenshteinDistance(String s1, String s2) {
    // Implementación del algoritmo de Levenshtein
    // ... (código estándar)
  }
}
```

---

## Manejo de Errores

```dart
class FoodAnalysisResult {
  final FoodData? data;
  final FoodAnalysisSource source;
  final bool requiresManualInput;
  final String? errorMessage;

  const FoodAnalysisResult({
    this.data,
    required this.source,
    this.requiresManualInput = false,
    this.errorMessage,
  });

  factory FoodAnalysisResult.fromCache(AiCacheData cache) => FoodAnalysisResult(
    data: FoodData.fromJson(jsonDecode(cache.aiResponse)),
    source: FoodAnalysisSource.cache,
  );

  factory FoodAnalysisResult.fromGemini(Map<String, dynamic> json) => FoodAnalysisResult(
    data: FoodData.fromJson(json),
    source: FoodAnalysisSource.gemini,
  );

  factory FoodAnalysisResult.fromLocalDb(FoodItem item) => FoodAnalysisResult(
    data: FoodData.fromLocalItem(item),
    source: FoodAnalysisSource.localDb,
  );

  factory FoodAnalysisResult.requiresManualInput() => const FoodAnalysisResult(
    requiresManualInput: true,
    source: FoodAnalysisSource.manual,
  );

  factory FoodAnalysisResult.error(String message) => FoodAnalysisResult(
    source: FoodAnalysisSource.error,
    errorMessage: message,
  );
}

enum FoodAnalysisSource {
  cache,    // Desde AiCache (instantáneo)
  gemini,   // Desde Gemini API (online)
  localDb,  // Desde nutrition_database.json (offline)
  manual,   // Entrada manual del usuario
  error,    // Error en el proceso
}
```

---

## Configuración de Gemini API

### Setup del Modelo

```dart
class AiServiceImpl implements IAiService {
  late final GenerativeModel _model;

  AiServiceImpl(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-flash-latest', // Gemini 2.5 Flash (actualizado)
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.2, // Moderada para balance precisión/creatividad
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
        responseMimeType: 'application/json', // Crítico: fuerza respuesta JSON
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
}
```

### Límites y Rate Limiting

- **Caché local primero:** Reducir llamadas a API
- **Retry logic:** 3 intentos con backoff exponencial
- **Timeout:** 10 segundos máximo
- **Fallback inmediato:** Si falla, ir a DB local

---

## Métricas de Éxito

- 🎯 **Cache hit rate:** >70% después de 2 semanas de uso
- ⚡ **Respuesta de cache:** <100ms
- 🌐 **Respuesta de Gemini:** <3 segundos
- 📊 **Precisión de DB local:** >85% de matches relevantes
- 💾 **Tamaño de cache:** Limpiar entradas no usadas en 60+ días

---

## Mejoras Implementadas (Fase 6.10)

### ✅ Fix Crítico de Gemini AI

**Problema:** El método `_analyzeWithGemini()` estaba sobrescribiendo la configuración del modelo, eliminando el parámetro crítico `responseMimeType: 'application/json'`.

**Impacto:** Análisis de alimentos como "pay de limón" fallaban constantemente, retornando respuestas inconsistentes.

**Solución:**
```dart
// ❌ ANTES (causaba problemas):
final response = await _geminiModel!.generateContent(
  content,
  generationConfig: GenerationConfig(
    temperature: 0.1,
    maxOutputTokens: 500,
  ),
);

// ✅ DESPUÉS (corregido):
final response = await _geminiModel!.generateContent(content);
// Usa la configuración completa del modelo con responseMimeType
```

**Configuración actualizada:**
```dart
void configureGemini(String apiKey) {
  _geminiModel = GenerativeModel(
    model: 'gemini-flash-latest', // Gemini 2.5 Flash
    apiKey: apiKey,
    generationConfig: GenerationConfig(
      temperature: 0.2,
      topK: 40,
      topP: 0.95,
      maxOutputTokens: 1024,
      responseMimeType: 'application/json', // ← Crítico para respuestas consistentes
    ),
    safetySettings: [ /* ... */ ],
  );
}
```

**Resultado:** Análisis proporcional funciona perfectamente (100g, 150g, 1 rebanada, etc.)

### ✅ Sistema de Autocompletado de Alimentos

**Widget:** `FoodAutocompleteField`
- Muestra 50 alimentos recientes únicos
- Búsqueda en tiempo real mientras escribes
- Información nutricional resumida en cada sugerencia
- Badge de fuente visible (Cache/IA/DB/Manual)

**Provider utilizado:**
```dart
final recentFoodsProvider = FutureProvider<List<FoodItemEntity>>((ref) async {
  final repository = ref.watch(nutritionRepositoryProvider);
  return repository.getRecentUniqueFoods(limit: 50);
});
```

**UX:**
```
Usuario escribe "pollo" →
  • 🕐 Pollo a la plancha | 200g • 330 kcal • P: 62g [IA]
  • 🕐 Pollo al horno     | 150g • 248 kcal • P: 47g [CACHE]
```

### ✅ Agregar Múltiples Alimentos Rápidamente

**Mejora:** Botón "Guardar + Otro" en `AddFoodItemScreen`

**Flujo:**
1. Agregar "200g pollo" → Analizar → **Guardar + Otro**
2. Formulario se limpia automáticamente
3. Agregar "100g arroz" → Analizar → **Guardar + Otro**
4. Agregar "1 manzana" → Analizar → **Guardar** (cierra)

**Métrica:** Reduce clics en 33% y pantallas en 67%

### ✅ Edición de Alimentos Individuales

**Nueva pantalla:** `EditFoodItemScreen` (~400 líneas)

**Características:**
- Editar nombre, cantidad, calorías, proteína, carbos, grasas
- Muestra badge de fuente original y fecha de registro
- Botón de eliminar con confirmación
- Recalcula totales de comida automáticamente
- Invalida providers para actualizar UI

**Función helper:**
```dart
FoodAnalysisSource _convertToFoodAnalysisSource(String source) {
  switch (source.toLowerCase()) {
    case 'cache': return FoodAnalysisSource.cache;
    case 'gemini':
    case 'ai': return FoodAnalysisSource.gemini;
    case 'local_db': return FoodAnalysisSource.localDb;
    case 'manual': return FoodAnalysisSource.manual;
    default: return FoodAnalysisSource.manual;
  }
}
```

### ✅ Alimentos Clickeables

**Mejora en `MealDetailScreen`:**
- Alimentos ahora son clickeables con InkWell
- Icono de edición (✏️) visible
- Tap → Abre `EditFoodItemScreen`
- Método `_buildFoodItemCard()` con funcionalidad de edición

### 📊 Métricas de Mejora

| Métrica                        | Antes | Después | Mejora |
|--------------------------------|-------|---------|--------|
| Clics para agregar 3 alimentos | 12    | 8       | -33%   |
| Pantallas necesarias           | 6     | 2       | -67%   |
| Editar alimento individual     | ❌    | ✅      | +100%  |
| Autocompletado                 | ❌    | ✅      | +100%  |
| Análisis con Gemini funciona   | ❌    | ✅      | +100%  |

---

**Última actualización:** 2025-11-10
**Documentación completa:** Ver `NUTRITION_IMPROVEMENTS.md` y `NUTRITION_AI_FIX.md`
