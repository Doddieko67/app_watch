import 'package:drift/drift.dart';

import 'meals_table.dart';

class FoodItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get mealId =>
      integer().references(Meals, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text()();
  RealColumn get quantity => real()(); // gramos o unidades
  TextColumn get unit => text()(); // "g", "ml", "unidad"

  // Macros
  RealColumn get calories => real()();
  RealColumn get protein => real()();
  RealColumn get carbs => real()();
  RealColumn get fats => real()();

  // Fuente de datos
  TextColumn get source =>
      text()(); // "ai", "cache", "local_db", "manual"
  TextColumn get aiResponse =>
      text().nullable()(); // JSON completo de Gemini para cache

  // Metadatos
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}
