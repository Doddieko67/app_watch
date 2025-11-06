import 'package:drift/drift.dart';

@TableIndex(name: 'meals_date_idx', columns: {#date})
class Meals extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get mealType =>
      text()(); // "breakfast", "lunch", "dinner", "snack"

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
