import '../entities/sleep_record_entity.dart';
import '../entities/sleep_schedule_entity.dart';
import '../entities/study_session_entity.dart';

/// Repository para operaciones de sueño y estudio
abstract class SleepStudyRepository {
  // ==================== SLEEP SCHEDULE ====================

  /// Crea o actualiza el horario de sueño activo
  Future<SleepScheduleEntity> configureSleepSchedule({
    required DateTime defaultBedtime,
    required DateTime defaultWakeup,
    required int preSleepNotificationMinutes,
    required bool enableOptimalStudyTime,
  });

  /// Obtiene el horario de sueño activo
  Future<SleepScheduleEntity?> getActiveSleepSchedule();

  /// Actualiza un horario de sueño
  Future<SleepScheduleEntity> updateSleepSchedule(SleepScheduleEntity schedule);

  // ==================== SLEEP RECORDS ====================

  /// Crea un nuevo registro de sueño planificado
  Future<SleepRecordEntity> createSleepRecord({
    required DateTime date,
    required DateTime plannedBedtime,
    required DateTime plannedWakeup,
    String? notes,
  });

  /// Actualiza los tiempos reales de un registro de sueño
  Future<SleepRecordEntity> logActualSleep({
    required int recordId,
    required DateTime actualBedtime,
    required DateTime actualWakeup,
    int? sleepQuality,
    String? notes,
  });

  /// Obtiene un registro de sueño por ID
  Future<SleepRecordEntity?> getSleepRecordById(int id);

  /// Obtiene el registro de sueño para una fecha específica
  Future<SleepRecordEntity?> getSleepRecordByDate(DateTime date);

  /// Obtiene todos los registros de sueño en un rango de fechas
  Future<List<SleepRecordEntity>> getSleepRecordsByDateRange(
    DateTime start,
    DateTime end,
  );

  /// Actualiza un registro de sueño
  Future<SleepRecordEntity> updateSleepRecord(SleepRecordEntity record);

  /// Elimina un registro de sueño (soft delete)
  Future<void> deleteSleepRecord(int id);

  // ==================== STUDY SESSIONS ====================

  /// Inicia una nueva sesión de estudio
  Future<StudySessionEntity> startStudySession({
    required DateTime startTime,
    String? subject,
  });

  /// Finaliza una sesión de estudio en progreso
  Future<StudySessionEntity> endStudySession({
    required int sessionId,
    required DateTime endTime,
    String? notes,
  });

  /// Crea una sesión de estudio completa (ya finalizada)
  Future<StudySessionEntity> createStudySession({
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    String? subject,
    String? notes,
  });

  /// Obtiene una sesión de estudio por ID
  Future<StudySessionEntity?> getStudySessionById(int id);

  /// Obtiene todas las sesiones de estudio para una fecha
  Future<List<StudySessionEntity>> getStudySessionsByDate(DateTime date);

  /// Obtiene todas las sesiones de estudio en un rango de fechas
  Future<List<StudySessionEntity>> getStudySessionsByDateRange(
    DateTime start,
    DateTime end,
  );

  /// Obtiene la sesión de estudio actualmente en progreso
  Future<StudySessionEntity?> getActiveStudySession();

  /// Actualiza una sesión de estudio
  Future<StudySessionEntity> updateStudySession(StudySessionEntity session);

  /// Elimina una sesión de estudio (soft delete)
  Future<void> deleteStudySession(int id);

  // ==================== STATISTICS ====================

  /// Obtiene estadísticas de sueño
  Future<SleepStats> getSleepStats(DateTime start, DateTime end);

  /// Obtiene estadísticas de estudio
  Future<StudyStats> getStudyStats(DateTime start, DateTime end);
}

/// Estadísticas de sueño para un período
class SleepStats {
  final int totalRecords;
  final int completeRecords;
  final double averagePlannedHours;
  final double? averageActualHours;
  final double? averageSleepQuality;
  final int recordsMetPlan;
  final List<SleepRecordEntity> records;

  const SleepStats({
    required this.totalRecords,
    required this.completeRecords,
    required this.averagePlannedHours,
    this.averageActualHours,
    this.averageSleepQuality,
    required this.recordsMetPlan,
    required this.records,
  });

  double get completionRate =>
      totalRecords > 0 ? (completeRecords / totalRecords) * 100 : 0;

  double get planComplianceRate =>
      completeRecords > 0 ? (recordsMetPlan / completeRecords) * 100 : 0;
}

/// Estadísticas de estudio para un período
class StudyStats {
  final int totalSessions;
  final int totalMinutes;
  final double averageSessionMinutes;
  final Map<String, int> subjectMinutes; // minutos por materia
  final List<StudySessionEntity> sessions;

  const StudyStats({
    required this.totalSessions,
    required this.totalMinutes,
    required this.averageSessionMinutes,
    required this.subjectMinutes,
    required this.sessions,
  });

  double get totalHours => totalMinutes / 60.0;
  double get averageSessionHours => averageSessionMinutes / 60.0;

  String get mostStudiedSubject {
    if (subjectMinutes.isEmpty) return 'N/A';
    return subjectMinutes.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}
