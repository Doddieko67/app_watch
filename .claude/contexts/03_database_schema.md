# 🗄️ Esquemas de Base de Datos (Drift)

## 1. Reminders Table

```dart
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();

  // Recurrencia
  TextColumn get recurrenceType => text()(); // daily, weekly, custom
  TextColumn get recurrenceDays => text().nullable()(); // JSON: [1,2,3] (lunes, martes...)

  // Horarios
  DateTimeColumn get scheduledTime => dateTime()();
  DateTimeColumn get nextOccurrence => dateTime()();

  // Prioridad y estado
  IntColumn get priority => integer().withDefault(const Constant(1))(); // 1=baja, 2=media, 3=alta
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // Tags
  TextColumn get tags => text().nullable()(); // JSON: ["vitaminas", "salud"]

  // Metadatos de sincronización
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))(); // 0=synced, 1=pending, 2=conflict

  // Notificaciones
  IntColumn get notificationId => integer().nullable()();
}
```

---

## 2. Workouts & Exercises Tables

### Workouts Table

```dart
class Workouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // "Push Day", "Full Body"

  /// Grupos musculares trabajados (JSON array: ["chest", "triceps", "shoulders"])
  TextColumn get muscleGroups => text()();

  DateTimeColumn get date => dateTime()();
  IntColumn get durationMinutes => integer().nullable()();
  TextColumn get notes => text().nullable()();

  // Metadatos
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}
```

**Muscle Groups disponibles:**
- `chest`, `back`, `shoulders`, `biceps`, `triceps`, `forearms`
- `abs`, `quads`, `hamstrings`, `glutes`, `calves`, `cardio`

### Exercises Table

```dart
class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutId => integer().references(Workouts, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text()(); // "Bench Press", "Squat"
  IntColumn get sets => integer()();
  IntColumn get reps => integer()();
  RealColumn get weight => real()(); // kg
  TextColumn get notes => text().nullable()();

  // Metadatos
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}
```

### SavedExercises Table

```dart
class SavedExercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// Últimos valores usados (para autocompletado inteligente)
  IntColumn get lastSets => integer().withDefault(const Constant(3))();
  IntColumn get lastReps => integer().withDefault(const Constant(10))();
  RealColumn get lastWeight => real().withDefault(const Constant(0.0))();

  /// Categoría opcional para organización
  TextColumn get category => text().nullable()();

  /// Número de veces usado
  IntColumn get usageCount => integer().withDefault(const Constant(0))();

  /// Última vez usado
  DateTimeColumn get lastUsed => dateTime().withDefault(currentDateAndTime)();

  // Metadatos
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}
```

### SavedWorkouts Table

```dart
class SavedWorkouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// Grupos musculares trabajados (JSON array: ["chest", "triceps"])
  TextColumn get muscleGroups => text()();

  /// Ejercicios del template (JSON array de objetos con name, sets, reps, weight, notes)
  TextColumn get exercises => text().withDefault(const Constant('[]'))();

  /// Duración promedio en minutos
  IntColumn get avgDurationMinutes => integer().nullable()();

  /// Notas sobre el workout template
  TextColumn get notes => text().nullable()();

  /// Número de veces usado
  IntColumn get usageCount => integer().withDefault(const Constant(0))();

  /// Última vez usado
  DateTimeColumn get lastUsed => dateTime().withDefault(currentDateAndTime)();

  // Metadatos
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}
```

**Formato JSON de `exercises` en SavedWorkouts:**
```json
[
  {
    "name": "Bench Press",
    "sets": 3,
    "reps": 10,
    "weight": 80.0,
    "notes": "Explosivo en la subida"
  },
  {
    "name": "Incline Dumbbell Press",
    "sets": 3,
    "reps": 12,
    "weight": 30.0,
    "notes": null
  }
]
```

---

## 3. Nutrition Tables

### Meals Table

```dart
class Meals extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get mealType => text()(); // "breakfast", "lunch", "dinner", "snack"

  // Totales calculados
  RealColumn get totalCalories => real()();
  RealColumn get totalProtein => real()();
  RealColumn get totalCarbs => real()();
  RealColumn get totalFats => real()();

  TextColumn get notes => text().nullable()();

  // Metadatos
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}
```

### FoodItems Table

```dart
class FoodItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get mealId => integer().references(Meals, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text()();
  RealColumn get quantity => real()(); // gramos o unidades
  TextColumn get unit => text()(); // "g", "ml", "unidad"

  // Macros
  RealColumn get calories => real()();
  RealColumn get protein => real()();
  RealColumn get carbs => real()();
  RealColumn get fats => real()();

  // Fuente de datos
  TextColumn get source => text()(); // "ai", "cache", "local_db", "manual"
  TextColumn get aiResponse => text().nullable()(); // JSON completo de Gemini para cache

  // Metadatos
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}
```

### NutritionGoals Table

```dart
class NutritionGoals extends Table {
  IntColumn get id => integer().autoIncrement()();

  RealColumn get dailyCalories => real()();
  RealColumn get dailyProtein => real()();
  RealColumn get dailyCarbs => real()();
  RealColumn get dailyFats => real()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // Metadatos
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

---

## 4. Sleep & Study Tables

### SleepRecords Table

```dart
class SleepRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get date => dateTime()();
  DateTimeColumn get plannedBedtime => dateTime()();
  DateTimeColumn get plannedWakeup => dateTime()();

  DateTimeColumn get actualBedtime => dateTime().nullable()();
  DateTimeColumn get actualWakeup => dateTime().nullable()();

  IntColumn get sleepQuality => integer().nullable()(); // 1-5
  TextColumn get notes => text().nullable()();

  // Metadatos
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}
```

### StudySessions Table

```dart
class StudySessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get date => dateTime()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();

  IntColumn get durationMinutes => integer().nullable()();
  TextColumn get subject => text().nullable()();
  TextColumn get notes => text().nullable()();

  // Metadatos
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}
```

### SleepSchedules Table

```dart
class SleepSchedules extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Configuración general
  DateTimeColumn get defaultBedtime => dateTime()();
  DateTimeColumn get defaultWakeup => dateTime()();
  IntColumn get preSleepNotificationMinutes => integer().withDefault(const Constant(30))();

  // Hora óptima de estudio
  BoolColumn get enableOptimalStudyTime => boolean().withDefault(const Constant(false))();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // Metadatos
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

---

## 5. Settings & Cache Tables

### AppSettings Table

```dart
class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get key => text().unique()();
  TextColumn get value => text()();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

**Configuraciones guardadas:**
- `theme_mode`: "light", "dark", "system"
- `primary_color`: Hex color code
- `gemini_api_key`: (cifrada)
- `nutrition_goals_active_id`: ID del goal activo
- `onboarding_completed`: "true"/"false"
- `backup_frequency`: "never", "daily", "weekly"

### AiCache Table

```dart
class AiCache extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get queryType => text()(); // "food_analysis", "workout_recommendation"
  TextColumn get queryInput => text()(); // Input del usuario
  TextColumn get queryHash => text().unique()(); // Hash del input para búsqueda rápida

  TextColumn get aiResponse => text()(); // Respuesta completa de Gemini (JSON)

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastUsed => dateTime().withDefault(currentDateAndTime)();
  IntColumn get useCount => integer().withDefault(const Constant(1))();
}
```

---

## Relaciones y Constraints

### Foreign Keys

- `Exercises.workoutId` → `Workouts.id` (CASCADE DELETE)
- `FoodItems.mealId` → `Meals.id` (CASCADE DELETE)

### Índices Recomendados

```dart
@TableIndex(name: 'reminders_next_occurrence_idx', columns: {#nextOccurrence})
@TableIndex(name: 'workouts_date_idx', columns: {#date})
@TableIndex(name: 'meals_date_idx', columns: {#date})
@TableIndex(name: 'sleep_records_date_idx', columns: {#date})
@TableIndex(name: 'ai_cache_hash_idx', columns: {#queryHash})
```

---

## Campos de Sincronización Futura

Todas las tablas principales incluyen:

```dart
DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
DateTimeColumn get deletedAt => dateTime().nullable()(); // Soft delete
IntColumn get syncStatus => integer().withDefault(const Constant(0))();
```

**Valores de syncStatus:**
- `0`: Sincronizado
- `1`: Pendiente de subir
- `2`: Pendiente de descargar
- `3`: Conflicto (requiere resolución manual)

---

## Migraciones

**Schema actual: v4**

Drift soporta migraciones automáticas. Para cada cambio de schema:

1. Incrementar `schemaVersion` en `AppDatabase`
2. Implementar migración en `MigrationStrategy`
3. Probar con database inspector

### Historial de Migraciones:

**v1 → v2:** Agregar tabla SavedExercises
```dart
if (from == 1 && to == 2) {
  await m.createTable(savedExercises);
}
```

**v2 → v3:** Agregar SavedWorkouts + cambiar split a muscleGroups
```dart
if (from == 2 && to == 3) {
  await m.createTable(savedWorkouts);
  await m.addColumn(workouts, workouts.muscleGroups);
  await customStatement('''
    UPDATE workouts
    SET muscle_groups = '["' || split || '"]'
    WHERE muscle_groups IS NULL OR muscle_groups = ''
  ''');
}
```

**v3 → v4:** Agregar columna exercises a SavedWorkouts
```dart
if (from == 3 && to == 4) {
  await m.addColumn(savedWorkouts, savedWorkouts.exercises);
}
```

---

## Resumen de Tablas

**Total: 13 tablas**

1. **Reminders** - Recordatorios diarios
2. **Workouts** - Entrenamientos realizados
3. **Exercises** - Ejercicios dentro de workouts
4. **SavedExercises** - Templates de ejercicios
5. **SavedWorkouts** - Templates de entrenamientos completos
6. **Meals** - Comidas registradas
7. **FoodItems** - Alimentos dentro de comidas
8. **NutritionGoals** - Objetivos nutricionales
9. **SleepRecords** - Registros de sueño
10. **StudySessions** - Sesiones de estudio
11. **SleepSchedules** - Horarios de sueño configurados
12. **AppSettings** - Configuración de la app
13. **AiCache** - Cache de respuestas de IA
