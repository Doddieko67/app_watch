import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  print('🧪 Test específico: "Pay de limón"\n');

  // Leer API key
  final envFile = File('.env');
  final envContent = await envFile.readAsString();
  final apiKeyMatch = RegExp(r'GEMINI_API_KEY=(.+)').firstMatch(envContent);
  final apiKey = apiKeyMatch!.group(1)!.trim();

  // Configurar modelo
  final model = GenerativeModel(
    model: 'gemini-flash-latest',
    apiKey: apiKey,
    generationConfig: GenerationConfig(
      temperature: 0.2,
      topK: 40,
      topP: 0.95,
      maxOutputTokens: 1024,
      responseMimeType: 'application/json',
    ),
  );

  // Test 1: Pay de limón (sin cantidad específica)
  print('📊 Test 1: "pay de limón" (sin cantidad)\n');
  await testFood(model, 'pay de limón');

  print('\n' + '=' * 50 + '\n');

  // Test 2: Pay de limón con cantidad
  print('📊 Test 2: "150g pay de limón"\n');
  await testFood(model, '150g pay de limón');

  print('\n' + '=' * 50 + '\n');

  // Test 3: Una rebanada de pay de limón
  print('📊 Test 3: "1 rebanada de pay de limón"\n');
  await testFood(model, '1 rebanada de pay de limón');
}

Future<void> testFood(GenerativeModel model, String input) async {
  final prompt = '''
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

  try {
    print('Enviando a Gemini...');
    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text ?? '';

    if (text.isEmpty) {
      print('❌ ERROR: Respuesta vacía');
      return;
    }

    print('✅ Respuesta recibida:\n');
    print(text);
    print('\n');

    // Intentar parsear
    String cleaned = text.trim();
    cleaned = cleaned.replaceAll(RegExp(r'```json\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'```\s*'), '');

    print('JSON limpio:');
    print(cleaned);
  } catch (e) {
    print('❌ ERROR: $e');
  }
}
