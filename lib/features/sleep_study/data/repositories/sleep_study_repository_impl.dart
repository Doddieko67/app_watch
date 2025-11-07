import '../../domain/entities/sleep_record_entity.dart';
import '../../domain/entities/sleep_schedule_entity.dart';
import '../../domain/entities/study_session_entity.dart';
import '../../domain/repositories/sleep_study_repository.dart';
import '../datasources/sleep_study_local_datasource.dart';

/// Implementación del repositorio de sueño y estudio
class SleepStudyRepositoryImpl implements SleepStudyRepository {
  final SleepStudyLocalDataSource _localDataSource;

  SleepStudyRepositoryImpl(this._localDataSource);

  // ==================== SLEEP SCHEDULE ====================

  @override
  Future<SleepScheduleEntity> configureSleepSchedule({
    required DateTime defaultBedtime,
    required DateTime defaultWakeup,
    required int preSleepNotificationMinutes,
    required bool enableOptimalStudyTime,
  }) {
    return _localDataSource.configureSleepSchedule(
      defaultBedtime: defaultBedtime,
      defaultWakeup: defaultWakeup,
      preSleepNotificationMinutes: preSleepNotificationMinutes,
      enableOptimalStudyTime: enableOptimalStudyTime,
    );
  }

  @override
  Future<SleepScheduleEntity?> getActiveSleepSchedule() {
    return _localDataSource.getActiveSleepSchedule();
  }

  @override
  Future<SleepScheduleEntity> updateSleepSchedule(SleepScheduleEntity schedule) {
    return _localDataSource.updateSleepSchedule(schedule);
  }

  // ==================== SLEEP RECORDS ====================

  @override
  Future<SleepRecordEntity> createSleepRecord({
    required DateTime date,
    required DateTime plannedBedtime,
    required DateTime plannedWakeup,
    String? notes,
  }) {
    return _localDataSource.createSleepRecord(
      date: date,
      plannedBedtime: plannedBedtime,
      plannedWakeup: plannedWakeup,
      notes: notes,
    );
  }

  @override
  Future<SleepRecordEntity> logActualSleep({
    required int recordId,
    required DateTime actualBedtime,
    required DateTime actualWakeup,
    int? sleepQuality,
    String? notes,
  }) {
    return _localDataSource.logActualSleep(
      recordId: recordId,
      actualBedtime: actualBedtime,
      actualWakeup: actualWakeup,
      sleepQuality: sleepQuality,
      notes: notes,
    );
  }

  @override
  Future<SleepRecordEntity?> getSleepRecordById(int id) {
    return _localDataSource.getSleepRecordById(id);
  }

  @override
  Future<SleepRecordEntity?> getSleepRecordByDate(DateTime date) {
    return _localDataSource.getSleepRecordByDate(date);
  }

  @override
  Future<List<SleepRecordEntity>> getSleepRecordsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _localDataSource.getSleepRecordsByDateRange(start, end);
  }

  @override
  Future<SleepRecordEntity> updateSleepRecord(SleepRecordEntity record) {
    return _localDataSource.updateSleepRecord(record);
  }

  @override
  Future<void> deleteSleepRecord(int id) {
    return _localDataSource.deleteSleepRecord(id);
  }

  // ==================== STUDY SESSIONS ====================

  @override
  Future<StudySessionEntity> startStudySession({
    required DateTime startTime,
    String? subject,
  }) {
    return _localDataSource.startStudySession(
      startTime: startTime,
      subject: subject,
    );
  }

  @override
  Future<StudySessionEntity> endStudySession({
    required int sessionId,
    required DateTime endTime,
    String? notes,
  }) {
    return _localDataSource.endStudySession(
      sessionId: sessionId,
      endTime: endTime,
      notes: notes,
    );
  }

  @override
  Future<StudySessionEntity> createStudySession({
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    String? subject,
    String? notes,
  }) {
    return _localDataSource.createStudySession(
      date: date,
      startTime: startTime,
      endTime: endTime,
      subject: subject,
      notes: notes,
    );
  }

  @override
  Future<StudySessionEntity?> getStudySessionById(int id) {
    return _localDataSource.getStudySessionById(id);
  }

  @override
  Future<List<StudySessionEntity>> getStudySessionsByDate(DateTime date) {
    return _localDataSource.getStudySessionsByDate(date);
  }

  @override
  Future<List<StudySessionEntity>> getStudySessionsByDateRange(
    DateTime start,
    DateTime end,
  ) {
    return _localDataSource.getStudySessionsByDateRange(start, end);
  }

  @override
  Future<StudySessionEntity?> getActiveStudySession() {
    return _localDataSource.getActiveStudySession();
  }

  @override
  Future<StudySessionEntity> updateStudySession(StudySessionEntity session) {
    return _localDataSource.updateStudySession(session);
  }

  @override
  Future<void> deleteStudySession(int id) {
    return _localDataSource.deleteStudySession(id);
  }

  // ==================== STATISTICS ====================

  @override
  Future<SleepStats> getSleepStats(DateTime start, DateTime end) {
    return _localDataSource.getSleepStats(start, end);
  }

  @override
  Future<StudyStats> getStudyStats(DateTime start, DateTime end) {
    return _localDataSource.getStudyStats(start, end);
  }
}
