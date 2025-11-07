import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/study_session_entity.dart';

/// Mapper para convertir entre StudySession (Drift) y StudySessionEntity (Domain)
class StudySessionModel {
  /// Convierte de StudySession (Drift) a StudySessionEntity (Domain)
  static StudySessionEntity toEntity(StudySession data) {
    return StudySessionEntity(
      id: data.id,
      date: data.date,
      startTime: data.startTime,
      endTime: data.endTime,
      durationMinutes: data.durationMinutes,
      subject: data.subject,
      notes: data.notes,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      deletedAt: data.deletedAt,
    );
  }

  /// Convierte de StudySessionEntity (Domain) a StudySessionsCompanion (Drift insert/update)
  static StudySessionsCompanion toCompanion(
    StudySessionEntity entity, {
    bool isUpdate = false,
  }) {
    return StudySessionsCompanion.insert(
      id: isUpdate ? Value(entity.id) : const Value.absent(),
      date: entity.date,
      startTime: entity.startTime,
      endTime: Value(entity.endTime),
      durationMinutes: Value(entity.durationMinutes),
      subject: Value(entity.subject),
      notes: Value(entity.notes),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
      deletedAt: Value(entity.deletedAt),
      syncStatus: const Value(0),
    );
  }
}
