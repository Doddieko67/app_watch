import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/sleep_record_entity.dart';

/// Mapper para convertir entre SleepRecord (Drift) y SleepRecordEntity (Domain)
class SleepRecordModel {
  /// Convierte de SleepRecord (Drift) a SleepRecordEntity (Domain)
  static SleepRecordEntity toEntity(SleepRecord data) {
    return SleepRecordEntity(
      id: data.id,
      date: data.date,
      plannedBedtime: data.plannedBedtime,
      plannedWakeup: data.plannedWakeup,
      actualBedtime: data.actualBedtime,
      actualWakeup: data.actualWakeup,
      sleepQuality: data.sleepQuality,
      notes: data.notes,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      deletedAt: data.deletedAt,
    );
  }

  /// Convierte de SleepRecordEntity (Domain) a SleepRecordsCompanion (Drift insert/update)
  static SleepRecordsCompanion toCompanion(
    SleepRecordEntity entity, {
    bool isUpdate = false,
  }) {
    return SleepRecordsCompanion.insert(
      id: isUpdate ? Value(entity.id) : const Value.absent(),
      date: entity.date,
      plannedBedtime: entity.plannedBedtime,
      plannedWakeup: entity.plannedWakeup,
      actualBedtime: Value(entity.actualBedtime),
      actualWakeup: Value(entity.actualWakeup),
      sleepQuality: Value(entity.sleepQuality),
      notes: Value(entity.notes),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      deletedAt: Value(entity.deletedAt),
      syncStatus: const Value(0),
    );
  }
}
