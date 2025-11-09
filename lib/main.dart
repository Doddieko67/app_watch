import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

void main() async {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar locale data para formateo de fechas en español
  await initializeDateFormatting('es_ES', null);

  // NotificationService se inicializa automáticamente cuando se usa por primera vez
  // (lazy initialization para evitar errores de contexto en Android)

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
