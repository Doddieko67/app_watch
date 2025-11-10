import 'package:drift/drift.dart';

@TableIndex(name: 'reminders_next_occurrence_idx', columns: {#nextOccurrence})
class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();

  // Recurrencia
  TextColumn get recurrenceType => text()(); // daily, weekly, custom
  TextColumn get recurrenceDays =>
      text().nullable()(); // JSON: [1,2,3] (lunes, martes...)
  IntColumn get customIntervalDays =>
      integer().nullable()(); // Para custom: cada X días

  // Horarios
  DateTimeColumn get scheduledTime => dateTime()();
  DateTimeColumn get nextOccurrence => dateTime()();

  // Prioridad y estado
  IntColumn get priority =>
      integer().withDefault(const Constant(1))(); // 1=baja, 2=media, 3=alta
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // Tags
  TextColumn get tags => text().nullable()(); // JSON: ["vitaminas", "salud"]

  // Metadatos de sincronización
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncStatus => integer().withDefault(
      const Constant(0))(); // 0=synced, 1=pending, 2=conflict

  // Notificaciones
  IntColumn get notificationId => integer().nullable()();
}
