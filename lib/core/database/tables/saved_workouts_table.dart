import 'package:drift/drift.dart';

/// Tabla para workouts guardados/templates
///
/// Permite guardar plantillas de entrenamientos para reutilizar
@DataClassName('SavedWorkoutData')
class SavedWorkouts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// Grupos musculares trabajados (JSON array: ["chest", "triceps"])
  TextColumn get muscleGroups => text()();

  /// Duración promedio en minutos
  IntColumn get avgDurationMinutes => integer().nullable()();

  /// Notas sobre el workout template
  TextColumn get notes => text().nullable()();

  /// Número de veces usado
  IntColumn get usageCount => integer().withDefault(const Constant(0))();

  /// Última vez usado
  DateTimeColumn get lastUsed => dateTime().withDefault(currentDateAndTime)();

  /// Timestamps
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Estado de sincronización (0 = synced, 1 = pending, 2 = conflict)
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}
