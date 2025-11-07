import 'package:freezed_annotation/freezed_annotation.dart';

part 'sleep_schedule_entity.freezed.dart';

/// Entity para la configuración de horario de sueño
@freezed
class SleepScheduleEntity with _$SleepScheduleEntity {
  const SleepScheduleEntity._();

  const factory SleepScheduleEntity({
    required int id,
    required DateTime defaultBedtime,
    required DateTime defaultWakeup,
    required int preSleepNotificationMinutes,
    required bool enableOptimalStudyTime,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SleepScheduleEntity;

  /// Calcula las horas de sueño objetivo
  double get targetSleepHours {
    return defaultWakeup.difference(defaultBedtime).inMinutes / 60.0;
  }

  /// Calcula la hora óptima de estudio (2-3 horas después de despertar)
  DateTime get optimalStudyTime {
    return defaultWakeup.add(const Duration(hours: 2, minutes: 30));
  }

  /// Obtiene la hora de notificación pre-sueño
  DateTime get preSleepNotificationTime {
    return defaultBedtime
        .subtract(Duration(minutes: preSleepNotificationMinutes));
  }
}
