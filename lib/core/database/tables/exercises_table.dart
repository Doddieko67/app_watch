import 'package:drift/drift.dart';

import 'workouts_table.dart';

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutId =>
      integer().references(Workouts, #id, onDelete: KeyAction.cascade)();

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
