# 🧪 Estrategia de Testing

## Pirámide de Testing

```
        /\
       /  \
      / E2E\        Integration Tests (pocos)
     /------\
    /        \
   / Widget  \      Widget Tests (algunos)
  /------------\
 /              \
/   Unit Tests   \   Unit Tests (muchos)
------------------
```

**Objetivo:** 70% Unit, 20% Widget, 10% Integration

---

## Unit Tests

### Qué Testear

- **Use Cases:** Toda la lógica de negocio
- **Repositories:** Implementaciones de repositorios
- **Services:** Servicios como AiService, NotificationService
- **Utils:** Funciones de utilidad, extensiones
- **Providers:** Lógica en Notifiers

### Setup Básico

```dart
// test/unit/features/reminders/domain/usecases/create_reminder_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'create_reminder_test.mocks.dart';

@GenerateMocks([ReminderRepository])
void main() {
  late CreateReminder useCase;
  late MockReminderRepository mockRepository;

  setUp(() {
    mockRepository = MockReminderRepository();
    useCase = CreateReminder(mockRepository);
  });

  group('CreateReminder', () {
    final testReminder = Reminder(
      id: 1,
      title: 'Test Reminder',
      scheduledTime: DateTime(2025, 11, 6, 9, 0),
    );

    test('should create reminder successfully', () async {
      // Arrange
      when(mockRepository.create(any))
          .thenAnswer((_) async => 1);

      // Act
      final result = await useCase(testReminder);

      // Assert
      expect(result, 1);
      verify(mockRepository.create(testReminder)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw exception when title is empty', () async {
      // Arrange
      final invalidReminder = testReminder.copyWith(title: '');

      // Act & Assert
      expect(
        () => useCase(invalidReminder),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(mockRepository.create(any));
    });

    test('should throw exception when repository fails', () async {
      // Arrange
      when(mockRepository.create(any))
          .thenThrow(DatabaseException('Connection error'));

      // Act & Assert
      expect(
        () => useCase(testReminder),
        throwsA(isA<DatabaseException>()),
      );
    });
  });
}
```

### Generar Mocks

```bash
# Instalar build_runner y mockito
flutter pub add --dev build_runner mockito

# Generar mocks
flutter pub run build_runner build --delete-conflicting-outputs
```

### Test de Repositories

```dart
// test/unit/features/reminders/data/repositories/reminder_repository_test.dart

void main() {
  late ReminderRepositoryImpl repository;
  late MockReminderDao mockDao;

  setUp(() {
    mockDao = MockReminderDao();
    repository = ReminderRepositoryImpl(mockDao);
  });

  group('ReminderRepository', () {
    test('should return list of reminders', () async {
      // Arrange
      final testReminders = [
        ReminderData(id: 1, title: 'Test 1', /*...*/),
        ReminderData(id: 2, title: 'Test 2', /*...*/),
      ];
      when(mockDao.getAllReminders())
          .thenAnswer((_) async => testReminders);

      // Act
      final result = await repository.getAll();

      // Assert
      expect(result, isA<List<Reminder>>());
      expect(result.length, 2);
      expect(result[0].title, 'Test 1');
    });

    test('should convert DTO to Entity correctly', () async {
      // Arrange
      final dto = ReminderData(
        id: 1,
        title: 'Test',
        scheduledTime: DateTime(2025, 11, 6),
        priority: 2,
      );
      when(mockDao.getById(1)).thenAnswer((_) async => dto);

      // Act
      final result = await repository.getById(1);

      // Assert
      expect(result.id, dto.id);
      expect(result.title, dto.title);
      expect(result.priority, Priority.medium);
    });
  });
}
```

---

## Widget Tests

### Qué Testear

- **Widgets complejos:** Cards, formularios, listas
- **Interacciones:** Taps, scrolls, inputs
- **Estados:** Loading, error, success
- **Navegación:** Botones que navegan

### Setup Básico

```dart
// test/widget/features/reminders/presentation/widgets/reminder_card_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  group('ReminderCard', () {
    final testReminder = Reminder(
      id: 1,
      title: 'Test Reminder',
      description: 'Test description',
      scheduledTime: DateTime(2025, 11, 6, 9, 0),
      priority: Priority.high,
      isCompleted: false,
    );

    testWidgets('should display reminder title and description',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        createTestWidget(ReminderCard(reminder: testReminder)),
      );

      // Assert
      expect(find.text('Test Reminder'), findsOneWidget);
      expect(find.text('Test description'), findsOneWidget);
    });

    testWidgets('should show high priority badge',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(ReminderCard(reminder: testReminder)),
      );

      // Assert
      expect(find.byType(PriorityBadge), findsOneWidget);
      final badge = tester.widget<PriorityBadge>(
        find.byType(PriorityBadge),
      );
      expect(badge.priority, Priority.high);
    });

    testWidgets('should call onTap when tapped',
        (WidgetTester tester) async {
      // Arrange
      bool wasTapped = false;
      final card = ReminderCard(
        reminder: testReminder,
        onTap: () => wasTapped = true,
      );

      // Act
      await tester.pumpWidget(createTestWidget(card));
      await tester.tap(find.byType(ReminderCard));
      await tester.pumpAndSettle();

      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets('should show completed state',
        (WidgetTester tester) async {
      // Arrange
      final completedReminder = testReminder.copyWith(isCompleted: true);

      // Act
      await tester.pumpWidget(
        createTestWidget(ReminderCard(reminder: completedReminder)),
      );

      // Assert
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
```

### Test de Formularios

```dart
testWidgets('should validate empty title', (WidgetTester tester) async {
  // Arrange
  await tester.pumpWidget(createTestWidget(const ReminderFormScreen()));

  // Act
  await tester.tap(find.byType(ElevatedButton)); // Save button
  await tester.pumpAndSettle();

  // Assert
  expect(find.text('El título no puede estar vacío'), findsOneWidget);
});

testWidgets('should submit form with valid data',
    (WidgetTester tester) async {
  // Arrange
  bool formSubmitted = false;
  await tester.pumpWidget(
    createTestWidget(
      ReminderFormScreen(
        onSubmit: (reminder) => formSubmitted = true,
      ),
    ),
  );

  // Act
  await tester.enterText(
    find.byType(TextField).first,
    'New Reminder',
  );
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();

  // Assert
  expect(formSubmitted, isTrue);
});
```

### Test de Listas

```dart
testWidgets('should display list of reminders',
    (WidgetTester tester) async {
  // Arrange
  final reminders = List.generate(
    10,
    (i) => Reminder(
      id: i,
      title: 'Reminder $i',
      scheduledTime: DateTime.now(),
    ),
  );

  // Act
  await tester.pumpWidget(
    createTestWidget(RemindersList(reminders: reminders)),
  );

  // Assert
  expect(find.byType(ReminderCard), findsNWidgets(10));
});

testWidgets('should scroll list', (WidgetTester tester) async {
  // Arrange
  final reminders = List.generate(50, (i) => /*...*/);
  await tester.pumpWidget(
    createTestWidget(RemindersList(reminders: reminders)),
  );

  // Act
  await tester.drag(
    find.byType(ListView),
    const Offset(0, -500),
  );
  await tester.pumpAndSettle();

  // Assert
  expect(find.text('Reminder 0'), findsNothing); // Scrolled out
  expect(find.text('Reminder 20'), findsOneWidget); // Visible
});
```

---

## Integration Tests

### Qué Testear

- **Flujos completos:** Crear recordatorio → recibir notificación
- **Navegación entre pantallas**
- **Interacción con base de datos real**
- **Casos de uso end-to-end**

### Setup

```dart
// integration_test/app_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app_watch/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('complete reminder flow', (WidgetTester tester) async {
      // 1. Iniciar app
      app.main();
      await tester.pumpAndSettle();

      // 2. Navegar a Recordatorios
      await tester.tap(find.text('Recordatorios'));
      await tester.pumpAndSettle();

      // 3. Abrir formulario
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // 4. Llenar formulario
      await tester.enterText(
        find.byType(TextField).first,
        'Test Reminder',
      );
      await tester.tap(find.text('Alta')); // Priority
      await tester.pumpAndSettle();

      // 5. Guardar
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // 6. Verificar que aparece en lista
      expect(find.text('Test Reminder'), findsOneWidget);

      // 7. Marcar como completado
      await tester.tap(find.byIcon(Icons.check_circle_outline));
      await tester.pumpAndSettle();

      // 8. Verificar estado
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('nutrition AI flow', (WidgetTester tester) async {
      // 1. Iniciar app
      app.main();
      await tester.pumpAndSettle();

      // 2. Navegar a Nutrición
      await tester.tap(find.text('Nutrición'));
      await tester.pumpAndSettle();

      // 3. Agregar comida
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // 4. Ingresar alimento
      await tester.enterText(
        find.byType(TextField),
        'pollo 200g',
      );
      await tester.pumpAndSettle();

      // 5. Esperar análisis de IA
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // 6. Verificar resultado
      expect(find.textContaining('pollo'), findsOneWidget);
      expect(find.textContaining('cal'), findsOneWidget); // Calorías

      // 7. Guardar
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // 8. Verificar en lista
      expect(find.text('Desayuno'), findsOneWidget);
    });
  });
}
```

### Ejecutar Integration Tests

```bash
# Android
flutter test integration_test/app_test.dart

# Con device conectado
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart
```

---

## Test de Base de Datos

### Usar DB In-Memory

```dart
// test/helpers/test_database.dart

import 'package:drift/native.dart';
import 'package:app_watch/core/database/app_database.dart';

AppDatabase createTestDatabase() {
  return AppDatabase(NativeDatabase.memory());
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  test('should insert and retrieve reminder', () async {
    // Arrange
    final reminder = RemindersCompanion.insert(
      title: 'Test',
      scheduledTime: DateTime.now(),
      // ...
    );

    // Act
    final id = await db.remindersDao.insert(reminder);
    final retrieved = await db.remindersDao.getById(id);

    // Assert
    expect(retrieved.title, 'Test');
  });
}
```

---

## Coverage

### Generar Reporte

```bash
# Ejecutar tests con coverage
flutter test --coverage

# Generar reporte HTML (requiere lcov)
genhtml coverage/lcov.info -o coverage/html

# Abrir en navegador
open coverage/html/index.html
```

### Meta de Coverage

- **Unit tests:** >80%
- **Widget tests:** >60%
- **Overall:** >70%

---

## Golden Tests (Opcional)

Para comparar screenshots de widgets:

```dart
testWidgets('golden test for ReminderCard', (WidgetTester tester) async {
  await tester.pumpWidget(
    createTestWidget(ReminderCard(reminder: testReminder)),
  );

  await expectLater(
    find.byType(ReminderCard),
    matchesGoldenFile('goldens/reminder_card.png'),
  );
});
```

```bash
# Generar goldens
flutter test --update-goldens
```

---

## Continuous Integration

### GitHub Actions

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

---

## Best Practices

1. **Nombrar tests claramente:** `should_do_something_when_condition`
2. **AAA pattern:** Arrange, Act, Assert
3. **Un assert por test** (cuando sea posible)
4. **Tests independientes:** No depender del orden
5. **Usar setUp y tearDown** para setup común
6. **Mock solo lo necesario:** No mockear lo que puedes usar real
7. **Test edge cases:** Valores null, listas vacías, errores
8. **Mantener tests rápidos:** <1s por test de unit, <5s por widget test
