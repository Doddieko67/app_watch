import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_session_entity.freezed.dart';

/// Entity para una sesión de estudio
@freezed
class StudySessionEntity with _$StudySessionEntity {
  const StudySessionEntity._();

  const factory StudySessionEntity({
    required int id,
    required DateTime date,
    required DateTime startTime,
    DateTime? endTime,
    int? durationMinutes,
    String? subject,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _StudySessionEntity;

  /// Calcula la duración en minutos
  int get calculatedDuration {
    if (durationMinutes != null) return durationMinutes!;
    if (endTime != null) {
      return endTime!.difference(startTime).inMinutes;
    }
    return 0;
  }

  /// Indica si la sesión está en progreso
  bool get isInProgress => endTime == null;

  /// Indica si la sesión está completa
  bool get isComplete => endTime != null;

  /// Formatea la duración como "1h 30m"
  String get formattedDuration {
    final hours = calculatedDuration ~/ 60;
    final minutes = calculatedDuration % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}
