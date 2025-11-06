import 'package:drift/drift.dart';

class SleepSchedules extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Configuración general
  DateTimeColumn get defaultBedtime => dateTime()();
  DateTimeColumn get defaultWakeup => dateTime()();
  IntColumn get preSleepNotificationMinutes =>
      integer().withDefault(const Constant(30))();

  // Hora óptima de estudio
  BoolColumn get enableOptimalStudyTime =>
      boolean().withDefault(const Constant(false))();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // Metadatos
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
