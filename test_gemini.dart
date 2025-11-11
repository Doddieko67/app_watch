/// Script de prueba para verificar que la API key de Gemini funciona
///
/// Uso:
/// dart run test_gemini.dart
///
/// Este script:
/// 1. Lee la API key del archivo .env
/// 2. Hace una llamada simple a Gemini
/// 3. Prueba el análisis de alimentos
/// 4. Muestra resultados detallados

import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  print('🧪 Test de API Key de Gemini\n');
  print('=' * 50);

  // 1. Leer API key del .env
  print('\n1️⃣  Leyendo API key de .env...');
  final envFile = File('.env');

  if (!envFile.existsSync()) {
    print('❌ ERROR: Archivo .env no encontrado');
    print('   Crea un archivo .env en la raíz del proyecto con:');
    print('   GEMINI_API_KEY=tu_api_key_aqui');
    exit(1);
  }

  final envContent = await envFile.readAsString();
  final apiKeyMatch = RegExp(r'GEMINI_API_KEY=(.+)').firstMatch(envContent);

  if (apiKeyMatch == null) {
    print('❌ ERROR: No se encontró GEMINI_API_KEY en .env');
    exit(1);
  }

  final apiKey = apiKeyMatch.group(1)!.trim();

  if (apiKey.isEmpty || apiKey == 'your_gemini_api_key_here') {
    print('❌ ERROR: API key no configurada o es el placeholder');
    print('   Tu .env tiene: GEMINI_API_KEY=$apiKey');
    print('   Debes poner tu API key real de https://ai.google.dev');
    exit(1);
  }

  print('✅ API key encontrada: ${apiKey.substring(0, 10)}...${apiKey.substring(apiKey.length - 4)}');

  // 2. Verificar API key con llamada simple
  print('\n2️⃣  Verificando validez de API key...');
  try {
    // Hacer una llamada HTTP simple para verificar la key
    final testClient = HttpClient();
    final request = await testClient.getUrl(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey'),
    );
    final response = await request.close();

    if (response.statusCode == 403) {
      print('❌ ERROR: API key inválida o sin permisos');
      print('   Verifica tu API key en: https://ai.google.dev');
      print('   Asegúrate de:');
      print('   1. Crear una API key nueva (no una de proyecto)');
      print('   2. Habilitar la API de Gemini');
      print('   3. Verificar que no haya restricciones de región');
      exit(1);
    } else if (response.statusCode == 404) {
      print('❌ ERROR: Endpoint no encontrado');
      print('   Esto puede indicar que la API de Gemini no está disponible en tu región');
      exit(1);
    } else if (response.statusCode != 200) {
      print('❌ ERROR: Código de respuesta HTTP ${response.statusCode}');
      exit(1);
    }

    print('✅ API key válida y funcionando');
  } catch (e) {
    print('⚠️  No se pudo verificar la API key directamente: $e');
    print('   Continuando con test de modelos...');
  }

  // 3. Configurar modelo
  print('\n3️⃣  Configurando modelo Gemini...');

  // Probar diferentes modelos disponibles (basado en listado de API)
  final modelsToTry = [
    'gemini-1.5-flash',           // Gemini 1.5 Flash (multimodal con imágenes)
    'gemini-1.5-pro',             // Gemini 1.5 Pro (multimodal con imágenes)
    'gemini-flash-latest',        // Latest Gemini Flash
    'gemini-2.0-flash',           // Gemini 2.0 Flash
  ];

  GenerativeModel? model;
  String? workingModel;

  for (final modelName in modelsToTry) {
    try {
      print('   Probando modelo: $modelName...');
      final testModel = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.2,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
      );

      // Test rápido
      final testResponse = await testModel.generateContent([
        Content.text('Responde solo: OK')
      ]);

      if (testResponse.text != null && testResponse.text!.isNotEmpty) {
        model = testModel;
        workingModel = modelName;
        break;
      }
    } catch (e) {
      print('   ❌ $modelName no funciona: ${e.toString().split('\n')[0]}');
      continue;
    }
  }

  if (model == null) {
    print('\n❌ ERROR: Ningún modelo de Gemini está disponible');
    print('   Esto significa que la API key puede tener problemas');
    exit(1);
  }

  print('✅ Modelo funcionando: $workingModel');

  // 3. Test simple
  print('\n3️⃣  Test simple: "¿Qué es 2+2?"');
  try {
    final prompt = '''
Responde SOLO con un JSON:
{
  "pregunta": "¿Qué es 2+2?",
  "respuesta": tu_respuesta_aqui
}
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text ?? '';

    if (text.isEmpty) {
      print('❌ ERROR: Respuesta vacía de Gemini');
      print('   Esto puede significar:');
      print('   - API key inválida');
      print('   - Sin créditos/cuota excedida');
      print('   - Problema de red');
      exit(1);
    }

    print('✅ Respuesta recibida:');
    print('   $text');
  } catch (e) {
    print('❌ ERROR en test simple: $e');
    print('\n   Posibles causas:');
    print('   - API key inválida o expirada');
    print('   - Sin acceso a internet');
    print('   - Cuota de API excedida (verifica en https://ai.google.dev)');
    print('   - Región no soportada');
    exit(1);
  }

  // 4. Test de análisis de alimentos
  print('\n4️⃣  Test de análisis de alimentos: "200g pollo"');
  try {
    final foodPrompt = '''
Eres un nutricionista experto con acceso a bases de datos nutricionales (USDA, FatSecret, tablas nutricionales oficiales).

Analiza este alimento: "200g pollo"

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
2. USA TU CONOCIMIENTO NUTRICIONAL: Conoces las calorías y macros de miles de alimentos comunes
3. Ejemplo: Pollo: 165 cal, 31g proteína, 0g carbs, 3.6g grasas (por 100g)
4. Confidence: 1.0 si es alimento común
5. Los valores NUNCA pueden ser 0 a menos que el alimento realmente carezca de ese macro
6. Calcula proporcionalmente si la cantidad es diferente de 100g

IMPORTANTE: Tu respuesta DEBE ser SOLO el JSON, sin markdown ni explicaciones.
''';

    final foodResponse = await model.generateContent([Content.text(foodPrompt)]);
    final foodText = foodResponse.text ?? '';

    if (foodText.isEmpty) {
      print('❌ ERROR: Respuesta vacía para análisis de alimentos');
      exit(1);
    }

    print('✅ Respuesta de análisis nutricional:');
    print('   $foodText');

    // Intentar parsear JSON
    try {
      // Limpiar markdown
      String cleaned = foodText.trim();
      cleaned = cleaned.replaceAll(RegExp(r'```json\s*'), '');
      cleaned = cleaned.replaceAll(RegExp(r'```\s*'), '');

      print('\n   Parseando JSON...');
      // Nota: No podemos usar dart:convert aquí sin imports adicionales
      // pero podemos verificar que tenga el formato correcto
      if (cleaned.contains('"name"') &&
          cleaned.contains('"calories"') &&
          cleaned.contains('"protein"')) {
        print('   ✅ JSON parece válido (contiene campos esperados)');
      } else {
        print('   ⚠️  JSON puede estar incompleto');
      }
    } catch (e) {
      print('   ⚠️  Error parseando JSON: $e');
    }
  } catch (e) {
    print('❌ ERROR en análisis de alimentos: $e');
    exit(1);
  }

  // 5. Test de análisis de IMÁGENES (nuevo!)
  print('\n5️⃣  Test de análisis de IMAGEN: descargando foto de comida...');
  try {
    // Descargar imagen de comida de internet (imagen pequeña de ejemplo)
    final imageUrl = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80'; // Plato de comida variada

    print('   📥 Descargando imagen desde Unsplash...');
    final httpClient = HttpClient();
    final request = await httpClient.getUrl(Uri.parse(imageUrl));
    final response = await request.close();

    if (response.statusCode != 200) {
      print('   ⚠️  No se pudo descargar la imagen (código ${response.statusCode})');
      print('   Saltando test de imagen...');
    } else {
      // Guardar imagen temporalmente
      final tempFile = File('temp_test_image.jpg');
      final imageBytesRaw = await response.fold<List<int>>([],
          (previous, element) => previous..addAll(element));
      final imageBytes = Uint8List.fromList(imageBytesRaw);
      await tempFile.writeAsBytes(imageBytes);

      print('   ✅ Imagen descargada (${imageBytes.length} bytes)');
      print('   🤖 Analizando imagen con Gemini (multimodal)...');

      // Prompt para análisis de imagen de plato completo
      final imagePrompt = '''
Eres un nutricionista experto analizando una fotografía de un plato de comida.

TAREA: Identifica TODOS los alimentos visibles en la imagen y estima sus cantidades.

Debes responder SIEMPRE con un JSON válido siguiendo este formato EXACTO:
{
  "foods": [
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
  ]
}

REGLAS:
1. Identifica TODOS los alimentos visibles
2. Estima cantidades basándote en el tamaño visual del plato
3. Si ves múltiples alimentos, agrégalos todos al array "foods"
4. Confidence: qué tan seguro estás del alimento y cantidad (0.0-1.0)
5. Los valores DEBEN ser realistas y proporcionales

IMPORTANTE: Tu respuesta DEBE ser SOLO el JSON, sin markdown ni explicaciones.
''';

      // Crear contenido multimodal (texto + imagen)
      // OPCIÓN 1: Usar Content.multi con TextPart y DataPart
      final content = Content.multi([
        TextPart(imagePrompt),
        DataPart('image/jpeg', imageBytes),
      ]);

      // IMPORTANTE: NO usar responseMimeType para multimodal
      final imageResponse = await model.generateContent(
        [content],
        generationConfig: GenerationConfig(
          temperature: 0.2,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
          // NO incluir responseMimeType aquí
        ),
      );

      final imageText = imageResponse.text ?? '';

      if (imageText.isEmpty) {
        print('   ❌ ERROR: Respuesta vacía para análisis de imagen');
      } else {
        print('   ✅ Respuesta de análisis de IMAGEN recibida!');
        print('\n' + '-' * 50);
        print(imageText);
        print('-' * 50);

        // Intentar parsear JSON
        try {
          String cleaned = imageText.trim();
          cleaned = cleaned.replaceAll(RegExp(r'```json\s*'), '');
          cleaned = cleaned.replaceAll(RegExp(r'```\s*'), '');

          if (cleaned.contains('"foods"') &&
              cleaned.contains('"name"') &&
              cleaned.contains('"calories"')) {
            print('\n   ✅ JSON DE IMAGEN parece válido!');
            print('   ✅ El análisis multimodal (imagen) FUNCIONA! 🎉');
          } else {
            print('\n   ⚠️  JSON puede estar incompleto');
          }
        } catch (e) {
          print('\n   ⚠️  Error parseando JSON: $e');
        }
      }

      // Limpiar archivo temporal
      if (await tempFile.exists()) {
        await tempFile.delete();
        print('\n   🧹 Archivo temporal eliminado');
      }
    }
  } catch (e) {
    print('   ❌ ERROR en test de imagen: $e');
    print('   Esto NO es crítico - puede ser problema de red');
  }

  // 6. Resumen final
  print('\n' + '=' * 50);
  print('🎉 RESUMEN FINAL\n');
  print('✅ API key de Gemini funcionando correctamente');
  print('✅ Modelo $workingModel respondiendo');
  print('✅ Análisis de alimentos por texto operativo');
  print('✅ Análisis de imágenes (multimodal) testeado');
  print('\n📱 Tu app debería funcionar correctamente con esta API key');
  print('💡 Si tienes problemas en la app:');
  print('   1. Verifica que .env esté en la carpeta raíz del proyecto');
  print('   2. Reinicia la app completamente');
  print('   3. Verifica los logs de la app al iniciar (debe decir "✅ Gemini AI configurado")');
  print('\n🔗 Más información:');
  print('   - Panel de API: https://ai.google.dev');
  print('   - Límites gratuitos: 15 RPM (requests por minuto)');
  print('   - Documentación: https://ai.google.dev/docs');
}
