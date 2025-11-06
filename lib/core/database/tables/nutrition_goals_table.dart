import 'package:drift/drift.dart';

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
