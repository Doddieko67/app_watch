import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/services/notification_service.dart';

void main() async {
  // Asegurar que Flutter esté inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar locale data para formateo de fechas en español
  await initializeDateFormatting('es_ES', null);

  // Inicializar servicios
  await NotificationService().initialize();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
