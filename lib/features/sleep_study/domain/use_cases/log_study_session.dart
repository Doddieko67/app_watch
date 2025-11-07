import '../entities/study_session_entity.dart';
import '../repositories/sleep_study_repository.dart';

/// Use case para registrar sesiones de estudio
class LogStudySession {
  final SleepStudyRepository _repository;

  LogStudySession(this._repository);

  /// Inicia una nueva sesión de estudio
  Future<StudySessionEntity> start({
    required DateTime startTime,
    String? subject,
  }) async {
    // Verificar que no haya otra sesión activa
    final activeSession = await _repository.getActiveStudySession();
    if (activeSession != null) {
      throw StateError('There is already an active study session');
    }

    return _repository.startStudySession(
      startTime: startTime,
      subject: subject,
    );
  }

  /// Finaliza una sesión de estudio en progreso
  Future<StudySessionEntity> end({
    required int sessionId,
    required DateTime endTime,
    String? notes,
  }) async {
    final session = await _repository.getStudySessionById(sessionId);
    if (session == null) {
      throw ArgumentError('Study session not found');
    }

    if (session.isComplete) {
      throw StateError('Study session is already complete');
    }

    if (endTime.isBefore(session.startTime)) {
      throw ArgumentError('End time must be after start time');
    }

    return _repository.endStudySession(
      sessionId: sessionId,
      endTime: endTime,
      notes: notes,
    );
  }

  /// Crea una sesión de estudio completa (pasada)
  Future<StudySessionEntity> createComplete({
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    String? subject,
    String? notes,
  }) async {
    if (endTime.isBefore(startTime)) {
      throw ArgumentError('End time must be after start time');
    }

    return _repository.createStudySession(
      date: date,
      startTime: startTime,
      endTime: endTime,
      subject: subject,
      notes: notes,
    );
  }
}
