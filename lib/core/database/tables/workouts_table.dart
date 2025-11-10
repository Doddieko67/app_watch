import 'package:drift/drift.dart';

@TableIndex(name: 'workouts_date_idx', columns: {#date})
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
