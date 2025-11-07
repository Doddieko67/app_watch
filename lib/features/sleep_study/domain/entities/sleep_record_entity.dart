import 'package:freezed_annotation/freezed_annotation.dart';

part 'sleep_record_entity.freezed.dart';

/// Entity para un registro de sueño
@freezed
class SleepRecordEntity with _$SleepRecordEntity {
  const SleepRecordEntity._();

  const factory SleepRecordEntity({
    required int id,
    required DateTime date,
    required DateTime plannedBedtime,
    required DateTime plannedWakeup,
    DateTime? actualBedtime,
    DateTime? actualWakeup,
    int? sleepQuality, // 1-5
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _SleepRecordEntity;

  /// Calcula las horas dormidas planificadas
  double get plannedHours {
    return plannedWakeup.difference(plannedBedtime).inMinutes / 60.0;
  }

  /// Calcula las horas dormidas reales
  double? get actualHours {
    if (actualBedtime == null || actualWakeup == null) return null;
    return actualWakeup!.difference(actualBedtime!).inMinutes / 60.0;
  }

  /// Calcula la diferencia entre horas planificadas y reales
  double? get hoursDifference {
    if (actualHours == null) return null;
    return actualHours! - plannedHours;
  }

  /// Indica si el registro está completo (tiene datos reales)
  bool get isComplete => actualBedtime != null && actualWakeup != null;

  /// Indica si cumplió con el plan (diferencia < 30 minutos)
  bool? get metPlan {
    if (hoursDifference == null) return null;
    return hoursDifference!.abs() < 0.5; // menos de 30 minutos de diferencia
  }
}
