import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/services/secure_storage_service.dart';
import 'features/nutrition/presentation/providers/nutrition_providers.dart';

void main() async {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno (.env)
  await dotenv.load(fileName: '.env');

  // Inicializar locale data para formateo de fechas en español
  await initializeDateFormatting('es_ES', null);

  // NotificationService se inicializa automáticamente cuando se usa por primera vez
  // (lazy initialization para evitar errores de contexto en Android)

  runApp(
    const ProviderScope(
      child: AppInitializer(),
    ),
  );
}

/// Widget que inicializa servicios antes de mostrar la app
class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({super.key});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeGeminiAi();
  }

  /// Inicializa Gemini AI con la API key configurada
  Future<void> _initializeGeminiAi() async {
    try {
      final apiKey = await SecureStorageService.getGeminiApiKey();
      if (apiKey != null && apiKey.isNotEmpty) {
        final aiService = ref.read(aiServiceProvider);
        aiService.configureGemini(apiKey);
        debugPrint('✅ Gemini AI configurado correctamente');
      } else {
        debugPrint('⚠️  No se encontró API key de Gemini. Configúrala en Settings.');
      }
    } catch (e) {
      debugPrint('❌ Error al inicializar Gemini AI: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}
