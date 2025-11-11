import 'package:drift/drift.dart';

/// Tabla de comidas - registra comidas por fecha/hora sin tipo específico
@TableIndex(name: 'meals_date_idx', columns: {#date})
class Meals extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()(); // Fecha y hora de la comida

  // Totales calculados automáticamente desde food_items
  RealColumn get totalCalories => real()();
  RealColumn get totalProtein => real()();
  RealColumn get totalCarbs => real()();
  RealColumn get totalFats => real()();

  TextColumn get notes => text().nullable()(); // Notas opcionales

  // Metadatos
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}
