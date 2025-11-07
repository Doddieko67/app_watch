import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/sleep_schedule_entity.dart';

/// Mapper para convertir entre SleepSchedule (Drift) y SleepScheduleEntity (Domain)
class SleepScheduleModel {
  /// Convierte de SleepSchedule (Drift) a SleepScheduleEntity (Domain)
  static SleepScheduleEntity toEntity(SleepSchedule data) {
    return SleepScheduleEntity(
      id: data.id,
      defaultBedtime: data.defaultBedtime,
      defaultWakeup: data.defaultWakeup,
      preSleepNotificationMinutes: data.preSleepNotificationMinutes,
      enableOptimalStudyTime: data.enableOptimalStudyTime,
      isActive: data.isActive,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  /// Convierte de SleepScheduleEntity (Domain) a SleepSchedulesCompanion (Drift insert/update)
  static SleepSchedulesCompanion toCompanion(
    SleepScheduleEntity entity, {
    bool isUpdate = false,
  }) {
    return SleepSchedulesCompanion.insert(
      id: isUpdate ? Value(entity.id) : const Value.absent(),
      defaultBedtime: entity.defaultBedtime,
      defaultWakeup: entity.defaultWakeup,
      preSleepNotificationMinutes: Value(entity.preSleepNotificationMinutes),
      enableOptimalStudyTime: Value(entity.enableOptimalStudyTime),
      isActive: Value(entity.isActive),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }
}
