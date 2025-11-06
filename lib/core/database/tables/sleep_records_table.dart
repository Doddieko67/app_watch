import 'package:drift/drift.dart';

@TableIndex(name: 'sleep_records_date_idx', columns: {#date})
class SleepRecords extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get date => dateTime()();
  DateTimeColumn get plannedBedtime => dateTime()();
  DateTimeColumn get plannedWakeup => dateTime()();

  DateTimeColumn get actualBedtime => dateTime().nullable()();
  DateTimeColumn get actualWakeup => dateTime().nullable()();

  IntColumn get sleepQuality => integer().nullable()(); // 1-5
  TextColumn get notes => text().nullable()();

  // Metadatos
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncStatus => integer().withDefault(const Constant(0))();
}
