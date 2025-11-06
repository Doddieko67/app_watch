# 📝 Convenciones de Código

## Nomenclatura

### Archivos
```dart
// snake_case para archivos
reminder_repository.dart
fitness_home_screen.dart
app_database.dart
```

### Clases
```dart
// PascalCase para clases
class ReminderRepository {}
class FitnessHomeScreen {}
class AppDatabase {}
```

### Variables y Funciones
```dart
// camelCase para variables y funciones
int reminderCount = 0;
String userName = 'John';
void fetchUserData() {}
Future<void> saveToDatabase() async {}
```

### Constantes
```dart
// lowerCamelCase para constantes (Dart no usa SCREAMING_CASE)
const int maxRetries = 3;
const double defaultPadding = 16.0;
const Duration animationDuration = Duration(milliseconds: 300);

// Excepción: constantes de configuración en mayúsculas si son públicas y globales
const API_BASE_URL = 'https://api.example.com';
```

### Nombres Privados
```dart
// Prefijo _ para miembros privados
class MyClass {
  int _privateField = 0;
  String publicField = '';

  void _privateMethod() {}
  void publicMethod() {}
}
```

---

## Organización de Imports

### Orden de Imports

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:io';

// 2. Flutter SDK
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Packages externos (alfabético)
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 4. Imports relativos del proyecto (alfabético)
import '../../../core/database/app_database.dart';
import '../../domain/entities/reminder.dart';
import '../providers/reminders_provider.dart';
```

### Export Barrel Files

Evitar usar archivos barrel (exports múltiples) excepto para simplificar imports de entities:

```dart
// ✅ Bueno: import directo
import 'package:app_watch/features/reminders/domain/entities/reminder.dart';

// ❌ Evitar: barrel file
import 'package:app_watch/features/reminders/domain/entities/entities.dart';
```

---

## Estructura de Clases

### Orden de Miembros

```dart
class MyWidget extends StatelessWidget {
  // 1. Campos públicos
  final String title;
  final VoidCallback? onTap;

  // 2. Campos privados
  final int _count = 0;

  // 3. Constructor
  const MyWidget({
    required this.title,
    this.onTap,
    super.key,
  });

  // 4. Named constructors
  MyWidget.empty({super.key}) : title = '', onTap = null;

  // 5. Getters y setters
  bool get isEmpty => title.isEmpty;

  // 6. Métodos públicos
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  void doSomething() {}

  // 7. Métodos privados
  void _helperMethod() {}

  // 8. Métodos estáticos
  static MyWidget create() => MyWidget.empty();
}
```

---

## Comentarios y Documentación

### Documentación Pública

```dart
/// Crea un nuevo recordatorio en la base de datos.
///
/// El [reminder] debe tener un título válido. Retorna el ID
/// del recordatorio creado.
///
/// Lanza [DatabaseException] si hay un error de persistencia.
Future<int> createReminder(Reminder reminder) async {
  // ...
}
```

### Comentarios Inline

Usar solo cuando sea necesario explicar lógica compleja:

```dart
// Bueno: explica el "por qué"
// Usamos un delay para evitar rebuild durante dispose
await Future.delayed(const Duration(milliseconds: 100));

// Malo: explica el "qué" (obvio)
// Incrementa el contador
counter++;
```

### TODOs

```dart
// TODO(username): Descripción de lo que falta
// TODO(juan): Implementar cache para mejorar performance

// TODO con issue/ticket
// TODO(#123): Refactorizar cuando se complete feature X
```

---

## Formateo

### Líneas Largas

Limitar a 80-100 caracteres. Flutter permite hasta 80 por defecto.

```dart
// ✅ Bueno
final reminder = Reminder(
  id: 1,
  title: 'Tomar vitaminas',
  description: 'Una cápsula después del desayuno',
);

// ❌ Malo
final reminder = Reminder(id: 1, title: 'Tomar vitaminas', description: 'Una cápsula después del desayuno');
```

### Trailing Commas

Siempre usar trailing commas en listas de parámetros:

```dart
// ✅ Bueno: permite formateo automático
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Hello'),
      Button('Click me'),
    ], // <- trailing comma
  );
}

// ❌ Malo
Widget build(BuildContext context) {
  return Column(
    children: [
      Text('Hello'),
      Button('Click me')
    ] // <- sin trailing comma
  );
}
```

---

## Manejo de Null Safety

### Null-aware Operators

```dart
// ✅ Usar ?? para valores por defecto
final name = user?.name ?? 'Guest';

// ✅ Usar ?. para acceso seguro
final length = list?.length;

// ✅ Usar ! solo cuando estés 100% seguro
final value = nullableValue!; // Evitar en lo posible

// ❌ Evitar checks manuales innecesarios
if (value != null) {
  useValue(value);
}
// ✅ Mejor
value?.let((it) => useValue(it));
```

### Late y Required

```dart
// ✅ Usar late para inicialización diferida
class MyClass {
  late final Database database;

  Future<void> init() async {
    database = await openDatabase();
  }
}

// ✅ Usar required en constructores
class MyWidget extends StatelessWidget {
  final String title;
  final int? count; // nullable explícito

  const MyWidget({
    required this.title, // requerido
    this.count, // opcional
  });
}
```

---

## Uso de Freezed

### Entities Inmutables

```dart
@freezed
class Reminder with _$Reminder {
  const factory Reminder({
    required int id,
    required String title,
    String? description,
    required DateTime scheduledTime,
    @Default(false) bool isCompleted,
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
}
```

### Unions para Estados

```dart
@freezed
class LoadingState<T> with _$LoadingState<T> {
  const factory LoadingState.initial() = _Initial;
  const factory LoadingState.loading() = _Loading;
  const factory LoadingState.data(T data) = _Data<T>;
  const factory LoadingState.error(String message) = _Error;
}

// Uso con pattern matching
state.when(
  initial: () => const CircularProgressIndicator(),
  loading: () => const CircularProgressIndicator(),
  data: (data) => ListView(children: data),
  error: (msg) => Text('Error: $msg'),
);
```

---

## Riverpod Providers

### Nomenclatura

```dart
// Provider de estado simple
final counterProvider = StateProvider<int>((ref) => 0);

// Provider de datos asíncronos
final remindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.remindersDao.getAllReminders();
});

// Provider con notifier
final remindersNotifierProvider =
    StateNotifierProvider<RemindersNotifier, List<Reminder>>((ref) {
  return RemindersNotifier(ref);
});

// Provider de servicio
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
```

### Family y AutoDispose

```dart
// Family para parámetros dinámicos
final reminderProvider = FutureProvider.family<Reminder, int>((ref, id) async {
  final db = ref.watch(databaseProvider);
  return db.remindersDao.getById(id);
});

// AutoDispose para providers temporales
final searchResultsProvider =
    FutureProvider.autoDispose.family<List<Food>, String>((ref, query) async {
  // ...
});
```

---

## Testing

### Nombres de Tests

```dart
void main() {
  group('ReminderRepository', () {
    test('should create reminder successfully', () async {
      // Arrange
      final repository = ReminderRepository(mockDb);
      final reminder = Reminder(/*...*/);

      // Act
      final result = await repository.create(reminder);

      // Assert
      expect(result, isA<int>());
      expect(result, greaterThan(0));
    });

    test('should throw exception when title is empty', () async {
      // ...
    });
  });
}
```

### Mocks

```dart
// Usar mockito
class MockDatabase extends Mock implements AppDatabase {}

// Setup en setUp()
void main() {
  late MockDatabase mockDb;
  late ReminderRepository repository;

  setUp(() {
    mockDb = MockDatabase();
    repository = ReminderRepository(mockDb);
  });

  test('test case', () {
    when(mockDb.remindersDao.getAll())
        .thenAnswer((_) async => []);
    // ...
  });
}
```

---

## Control de Versiones (Git)

### Commits

```
feat: agregar búsqueda de alimentos con IA
fix: corregir crash al eliminar recordatorio
refactor: extraer lógica de notificaciones a service
docs: actualizar README con instrucciones de instalación
test: agregar unit tests para FitnessRepository
chore: actualizar dependencias
```

### Branches

```
main         - producción estable
develop      - desarrollo activo
feature/xxx  - nuevas features
fix/xxx      - bug fixes
refactor/xxx - refactorizaciones
```

---

## Performance

### Evitar Rebuilds Innecesarios

```dart
// ✅ Bueno: usar const constructors
const Text('Hello');
const SizedBox(height: 16);

// ✅ Bueno: extraer widgets
class _MyStaticWidget extends StatelessWidget {
  const _MyStaticWidget();
  @override
  Widget build(BuildContext context) => Container();
}

// ❌ Malo: builders inline
ListView.builder(
  itemBuilder: (context, index) {
    return Column( // Este Column se recrea cada vez
      children: [
        Container(), // Estos también
        Container(),
      ],
    );
  },
);
```

### Keys Cuando Sea Necesario

```dart
// Usar keys en listas que pueden reordenarse
ListView(
  children: items.map((item) {
    return ItemWidget(
      key: ValueKey(item.id), // <- key basada en ID
      item: item,
    );
  }).toList(),
);
```

---

## Error Handling

### Try-Catch

```dart
Future<void> saveReminder(Reminder reminder) async {
  try {
    await _db.remindersDao.insert(reminder);
  } on DriftException catch (e) {
    debugPrint('Database error: $e');
    rethrow; // Re-lanzar si no podemos manejar
  } catch (e, stackTrace) {
    debugPrint('Unexpected error: $e\n$stackTrace');
    // Manejar error genérico
  }
}
```

### Result Pattern

```dart
// Usar sealed class para result
@freezed
class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(String error) = Failure<T>;
}

// Uso
Future<Result<Reminder>> getReminder(int id) async {
  try {
    final reminder = await _db.remindersDao.getById(id);
    return Result.success(reminder);
  } catch (e) {
    return Result.failure(e.toString());
  }
}
```

---

## Formato Automático

Configurar VSCode/Android Studio para formatear al guardar:

```json
// .vscode/settings.json
{
  "editor.formatOnSave": true,
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": false
  }
}
```

Ejecutar manualmente:
```bash
dart format .
```
