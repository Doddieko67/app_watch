import 'package:drift/drift.dart';

/// Tabla para almacenar ejercicios guardados/frecuentes
/// Permite autocompletar y pre-llenar valores al crear ejercicios
@DataClassName('SavedExerciseData')
class SavedExercises extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Nombre del ejercicio (único)
  TextColumn get name => text().unique()();

  /// Últimos valores usados (para pre-llenar)
  IntColumn get lastSets => integer().withDefault(const Constant(3))();
  IntColumn get lastReps => integer().withDefault(const Constant(10))();
  RealColumn get lastWeight => real().withDefault(const Constant(0))();

  /// Metadata para ordenar y filtrar
  DateTimeColumn get lastUsed => dateTime()();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();

  /// Categoría opcional (ej: "Push", "Pull", "Legs")
  TextColumn get category => text().nullable()();

  /// Timestamps estándar
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}
