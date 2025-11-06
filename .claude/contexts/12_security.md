# 🔐 Consideraciones de Seguridad

## API Keys

### Almacenamiento Seguro

**NUNCA** guardar API keys en:
- Código fuente
- SharedPreferences
- Archivos de configuración commiteados

**SÍ** usar:

```dart
// Usar flutter_secure_storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  // Guardar API key
  static Future<void> saveApiKey(String key) async {
    await _storage.write(key: 'gemini_api_key', value: key);
  }

  // Leer API key
  static Future<String?> getApiKey() async {
    return await _storage.read(key: 'gemini_api_key');
  }

  // Eliminar API key
  static Future<void> deleteApiKey() async {
    await _storage.delete(key: 'gemini_api_key');
  }

  // Verificar si existe
  static Future<bool> hasApiKey() async {
    final key = await getApiKey();
    return key != null && key.isNotEmpty;
  }
}
```

### Configuración por Usuario

Permitir al usuario configurar su propia API key en Settings:

```dart
class ApiKeyConfigScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final obscureText = useState(true);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurar API Key')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API Key de Gemini',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Obtén tu API key gratuita en ai.google.dev',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: obscureText.value,
              decoration: InputDecoration(
                labelText: 'API Key',
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    obscureText.value = !obscureText.value;
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                await SecureStorageService.saveApiKey(
                  controller.text.trim(),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('API Key guardada')),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Base de Datos

### Encriptación (Opcional)

Por defecto, SQLite no está encriptado. Para encriptar:

```yaml
dependencies:
  # En lugar de sqlite3_flutter_libs
  sqlcipher_flutter_libs: ^0.6.0
```

```dart
// Abrir DB con contraseña
final database = NativeDatabase.createInBackground(
  File(dbPath),
  setup: (rawDb) {
    rawDb.execute("PRAGMA key = 'your-encryption-key';");
  },
);
```

**Consideraciones:**
- Impacto en performance (~20% más lento)
- Gestión de la contraseña (¿dónde guardarla?)
- Difícil recuperar datos si se pierde la key

**Recomendación inicial:** No encriptar, agregar como feature premium después.

### Soft Deletes

Implementar soft deletes en todas las tablas:

```dart
// En lugar de eliminar permanentemente
await (delete(reminders)..where((r) => r.id.equals(id))).go();

// Marcar como eliminado
await (update(reminders)..where((r) => r.id.equals(id)))
  .write(RemindersCompanion(
    deletedAt: Value(DateTime.now()),
  ));
```

**Ventajas:**
- Recuperación de datos accidental
- Sincronización futura (saber qué se eliminó)
- Auditoría

### Limpieza Periódica

```dart
// Limpiar registros eliminados hace más de 30 días
Future<void> cleanOldDeletedRecords() async {
  final cutoffDate = DateTime.now().subtract(const Duration(days: 30));

  await (delete(reminders)
        ..where((r) => r.deletedAt.isSmallerThanValue(cutoffDate)))
      .go();

  await (delete(workouts)
        ..where((w) => w.deletedAt.isSmallerThanValue(cutoffDate)))
      .go();

  // ... otras tablas
}
```

---

## Validación de Inputs

### Sanitización de Datos del Usuario

```dart
class InputValidator {
  // Título de recordatorio
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El título no puede estar vacío';
    }
    if (value.length > 200) {
      return 'El título no puede tener más de 200 caracteres';
    }
    // Remover caracteres peligrosos (opcional)
    final sanitized = value.trim().replaceAll(RegExp(r'[<>]'), '');
    if (sanitized != value.trim()) {
      return 'El título contiene caracteres no permitidos';
    }
    return null;
  }

  // Email (si se agrega registro)
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email no puede estar vacío';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  // Números (peso, calorías, etc.)
  static String? validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName no puede estar vacío';
    }
    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName debe ser un número';
    }
    if (number <= 0) {
      return '$fieldName debe ser mayor a 0';
    }
    if (number > 99999) {
      return '$fieldName es demasiado grande';
    }
    return null;
  }
}
```

### SQL Injection

Drift protege automáticamente contra SQL injection al usar queries tipadas:

```dart
// ✅ Seguro (Drift)
final reminders = await (select(reminders)
      ..where((r) => r.title.equals(userInput)))
    .get();

// ❌ Peligroso (raw SQL sin sanitizar)
final reminders = await customSelect(
  'SELECT * FROM reminders WHERE title = "$userInput"', // NO HACER ESTO
).get();

// ✅ Si usas raw SQL, usa parámetros
final reminders = await customSelect(
  'SELECT * FROM reminders WHERE title = ?',
  variables: [Variable.withString(userInput)],
).get();
```

---

## Permisos

### Android

En `AndroidManifest.xml`, declarar solo permisos necesarios:

```xml
<manifest>
    <!-- Necesarios -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.VIBRATE"/>

    <!-- Android 13+ -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

    <!-- NO necesarios (evitar) -->
    <!-- <uses-permission android:name="android.permission.READ_CONTACTS"/> -->
    <!-- <uses-permission android:name="android.permission.CAMERA"/> -->
</manifest>
```

### iOS

En `Info.plist`:

```xml
<key>NSUserNotificationsUsageDescription</key>
<string>Necesitamos enviar notificaciones para recordarte tus tareas y horarios de sueño</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Opcional: permite tomar fotos de comidas para análisis nutricional</string>
```

### Solicitar Permisos en Runtime

```dart
class PermissionService {
  static Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        // Android 13+
        final status = await Permission.notification.request();
        return status.isGranted;
      }
      return true; // Permisos automáticos en Android < 13
    } else if (Platform.isIOS) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return false;
  }

  static Future<void> showPermissionDeniedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso denegado'),
        content: const Text(
          'Las notificaciones son necesarias para recordarte tus tareas.\n\n'
          '¿Deseas ir a ajustes para habilitarlas?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Ir a Ajustes'),
          ),
        ],
      ),
    );
  }
}
```

---

## Exportación de Datos

### Advertir sobre Sensibilidad

```dart
Future<void> exportData(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Exportar datos'),
      content: const Text(
        '⚠️ Advertencia de Privacidad\n\n'
        'El backup contendrá toda tu información personal:\n'
        '• Recordatorios y tareas\n'
        '• Entrenamientos y ejercicios\n'
        '• Comidas y datos nutricionales\n'
        '• Registros de sueño y estudio\n\n'
        'NO compartas este archivo públicamente.\n'
        'NO se incluirá tu API key de Gemini.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Entiendo, Exportar'),
        ),
      ],
    ),
  );

  if (confirm == true && context.mounted) {
    // Proceder con exportación
  }
}
```

### No Incluir API Keys

```dart
Future<Map<String, dynamic>> exportData() async {
  // ...
  return {
    'version': '1.0.0',
    'data': {
      'reminders': reminders,
      // ...
    },
    // NO incluir:
    // 'gemini_api_key': apiKey, ❌
  };
}
```

---

## Logging y Debugging

### NO Loggear Datos Sensibles

```dart
// ❌ Malo: loggear datos sensibles
debugPrint('API Key: $apiKey');
debugPrint('User email: ${user.email}');

// ✅ Bueno: loggear solo metadata
debugPrint('API Key configured: ${apiKey != null}');
debugPrint('User logged in: ${user != null}');

// ✅ Bueno: sanitizar en producción
void logDebug(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
  // En producción, enviar a servicio de analytics sin datos personales
}
```

### Usar kDebugMode

```dart
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  print('Debug info: $details');
}

// O con assert (solo se ejecuta en debug)
assert(() {
  print('Debug-only log');
  return true;
}());
```

---

## Comunicación con APIs

### HTTPS Obligatorio

```dart
class ApiClient {
  static const baseUrl = 'https://api.example.com'; // ✅ HTTPS

  // ❌ NO usar HTTP en producción
  // static const baseUrl = 'http://api.example.com';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
}
```

### Validar Certificados SSL (default en Flutter)

Flutter valida certificados SSL por defecto. NO bypass en producción:

```dart
// ❌ NUNCA hacer esto en producción
// (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
//     (client) {
//   client.badCertificateCallback = (cert, host, port) => true;
//   return client;
// };
```

### Rate Limiting

Implementar rate limiting para prevenir abuso:

```dart
class RateLimiter {
  final Map<String, DateTime> _lastRequests = {};
  final Duration minInterval;

  RateLimiter({this.minInterval = const Duration(seconds: 1)});

  Future<T> throttle<T>(String key, Future<T> Function() fn) async {
    final lastRequest = _lastRequests[key];
    if (lastRequest != null) {
      final elapsed = DateTime.now().difference(lastRequest);
      if (elapsed < minInterval) {
        await Future.delayed(minInterval - elapsed);
      }
    }

    _lastRequests[key] = DateTime.now();
    return await fn();
  }
}

// Uso
final rateLimiter = RateLimiter(minInterval: Duration(seconds: 2));

Future<void> analyzeFood(String input) async {
  return rateLimiter.throttle('gemini_api', () async {
    return await _geminiClient.analyze(input);
  });
}
```

---

## Dependencias

### Auditar Dependencias

Revisar periódicamente vulnerabilidades:

```bash
# Buscar vulnerabilidades conocidas
flutter pub outdated
dart pub audit

# Actualizar dependencias
flutter pub upgrade
```

### Usar Versiones Específicas

```yaml
# ✅ Bueno: versión específica con rango
dependencies:
  drift: ^2.16.0  # Acepta 2.16.x, pero no 3.0.0

# ❌ Evitar: versión "any"
dependencies:
  drift: any  # Puede traer breaking changes
```

---

## Backup y Recuperación

### Backups Locales Automáticos

```dart
class BackupService {
  static const _maxBackups = 5;

  Future<void> createAutoBackup() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupsDir = Directory('${directory.path}/backups');

    if (!await backupsDir.exists()) {
      await backupsDir.create(recursive: true);
    }

    // Crear nuevo backup
    final timestamp = DateTime.now().toIso8601String();
    final backupFile = File('${backupsDir.path}/backup_$timestamp.json');
    final data = await ExportService().exportToJson();
    await backupFile.writeAsString(data);

    // Limpiar backups antiguos
    await _cleanOldBackups(backupsDir);
  }

  Future<void> _cleanOldBackups(Directory backupsDir) async {
    final files = await backupsDir.list().toList();
    final backupFiles = files.whereType<File>().toList()
      ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    // Mantener solo los últimos N backups
    if (backupFiles.length > _maxBackups) {
      for (var i = _maxBackups; i < backupFiles.length; i++) {
        await backupFiles[i].delete();
      }
    }
  }
}
```

---

## Checklist de Seguridad

Antes de release:

- [ ] API keys no están en código
- [ ] API keys se guardan en flutter_secure_storage
- [ ] No hay datos sensibles en logs
- [ ] Validación de inputs implementada
- [ ] Permisos mínimos necesarios
- [ ] HTTPS para todas las conexiones
- [ ] Certificados SSL no bypasseados
- [ ] Soft deletes implementados
- [ ] Exportación advierte sobre privacidad
- [ ] Dependencias actualizadas y auditadas
- [ ] Backups automáticos configurados
- [ ] Rate limiting en APIs
- [ ] Inputs sanitizados
- [ ] No hay SQL injection
- [ ] Manejo de errores no expone internals

---

## Recursos

- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [Flutter Security Best Practices](https://docs.flutter.dev/security)
- [Drift Security](https://drift.simonbinder.eu/docs/advanced-features/encryption/)
