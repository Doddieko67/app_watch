import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/sleep_record_entity.dart';
import '../../domain/entities/sleep_schedule_entity.dart';
import '../../domain/entities/study_session_entity.dart';
import '../../domain/repositories/sleep_study_repository.dart';
import '../models/sleep_record_model.dart';
import '../models/sleep_schedule_model.dart';
import '../models/study_session_model.dart';

/// DataSource local para operaciones de sueño y estudio con Drift
class SleepStudyLocalDataSource {
  final AppDatabase _database;

  SleepStudyLocalDataSource(this._database);

  // ==================== SLEEP SCHEDULE ====================

  Future<SleepScheduleEntity> configureSleepSchedule({
    required DateTime defaultBedtime,
    required DateTime defaultWakeup,
    required int preSleepNotificationMinutes,
    required bool enableOptimalStudyTime,
  }) async {
    // Desactivar horarios anteriores
    await _deactivateOldSchedules();

    final companion = SleepSchedulesCompanion.insert(
      defaultBedtime: defaultBedtime,
      defaultWakeup: defaultWakeup,
      preSleepNotificationMinutes: Value(preSleepNotificationMinutes),
      enableOptimalStudyTime: Value(enableOptimalStudyTime),
      isActive: const Value(true),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final id = await _database.insertSleepSchedule(companion);
    final schedule = await (_database.select(_database.sleepSchedules)
          ..where((s) => s.id.equals(id)))
        .getSingle();

    return SleepScheduleModel.toEntity(schedule);
  }

  Future<SleepScheduleEntity?> getActiveSleepSchedule() async {
    final schedule = await _database.getActiveSleepSchedule();
    return schedule != null ? SleepScheduleModel.toEntity(schedule) : null;
  }

  Future<SleepScheduleEntity> updateSleepSchedule(
    SleepScheduleEntity schedule,
  ) async {
    final companion = SleepScheduleModel.toCompanion(
      schedule.copyWith(updatedAt: DateTime.now()),
      isUpdate: true,
    );

    await _database
        .into(_database.sleepSchedules)
        .insertOnConflictUpdate(companion);

    final updated = await (_database.select(_database.sleepSchedules)
          ..where((s) => s.id.equals(schedule.id)))
        .getSingle();

    return SleepScheduleModel.toEntity(updated);
  }

  Future<void> _deactivateOldSchedules() async {
    await (_database.update(_database.sleepSchedules)
          ..where((s) => s.isActive.equals(true)))
        .write(const SleepSchedulesCompanion(isActive: Value(false)));
  }

  // ==================== SLEEP RECORDS ====================

  Future<SleepRecordEntity> createSleepRecord({
    required DateTime date,
    required DateTime plannedBedtime,
    required DateTime plannedWakeup,
    String? notes,
  }) async {
    final companion = SleepRecordsCompanion.insert(
      date: date,
      plannedBedtime: plannedBedtime,
      plannedWakeup: plannedWakeup,
      notes: Value(notes),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final id = await _database.insertSleepRecord(companion);
    final record = await _database.getSleepRecordById(id);

    return SleepRecordModel.toEntity(record!);
  }

  Future<SleepRecordEntity> logActualSleep({
    required int recordId,
    required DateTime actualBedtime,
    required DateTime actualWakeup,
    int? sleepQuality,
    String? notes,
  }) async {
    final record = await _database.getSleepRecordById(recordId);
    if (record == null) {
      throw Exception('Sleep record not found');
    }

    final entity = SleepRecordModel.toEntity(record);
    final updated = entity.copyWith(
      actualBedtime: actualBedtime,
      actualWakeup: actualWakeup,
      sleepQuality: sleepQuality,
      notes: notes ?? entity.notes,
      updatedAt: DateTime.now(),
    );

    final companion = SleepRecordModel.toCompanion(updated, isUpdate: true);
    await _database
        .into(_database.sleepRecords)
        .insertOnConflictUpdate(companion);

    final result = await _database.getSleepRecordById(recordId);
    return SleepRecordModel.toEntity(result!);
  }

  Future<SleepRecordEntity?> getSleepRecordById(int id) async {
    final record = await _database.getSleepRecordById(id);
    return record != null ? SleepRecordModel.toEntity(record) : null;
  }

  Future<SleepRecordEntity?> getSleepRecordByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final record = await (_database.select(_database.sleepRecords)
          ..where((r) =>
              r.date.isBiggerOrEqualValue(startOfDay) &
              r.date.isSmallerThanValue(endOfDay) &
              r.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();

    return record != null ? SleepRecordModel.toEntity(record) : null;
  }

  Future<List<SleepRecordEntity>> getSleepRecordsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final records = await (_database.select(_database.sleepRecords)
          ..where((r) =>
              r.date.isBiggerOrEqualValue(start) &
              r.date.isSmallerOrEqualValue(end) &
              r.deletedAt.isNull())
          ..orderBy([(r) => OrderingTerm.desc(r.date)]))
        .get();

    return records.map(SleepRecordModel.toEntity).toList();
  }

  Future<SleepRecordEntity> updateSleepRecord(SleepRecordEntity record) async {
    final companion = SleepRecordModel.toCompanion(
      record.copyWith(updatedAt: DateTime.now()),
      isUpdate: true,
    );

    await _database
        .into(_database.sleepRecords)
        .insertOnConflictUpdate(companion);

    final updated = await _database.getSleepRecordById(record.id);
    return SleepRecordModel.toEntity(updated!);
  }

  Future<void> deleteSleepRecord(int id) async {
    await (_database.update(_database.sleepRecords)
          ..where((r) => r.id.equals(id)))
        .write(SleepRecordsCompanion(deletedAt: Value(DateTime.now())));
  }

  // ==================== STUDY SESSIONS ====================

  Future<StudySessionEntity> startStudySession({
    required DateTime startTime,
    String? subject,
  }) async {
    final companion = StudySessionsCompanion.insert(
      date: DateTime(startTime.year, startTime.month, startTime.day),
      startTime: startTime,
      subject: Value(subject),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final id = await _database.insertStudySession(companion);
    final session = await _database.getStudySessionById(id);

    return StudySessionModel.toEntity(session!);
  }

  Future<StudySessionEntity> endStudySession({
    required int sessionId,
    required DateTime endTime,
    String? notes,
  }) async {
    final session = await _database.getStudySessionById(sessionId);
    if (session == null) {
      throw Exception('Study session not found');
    }

    final durationMinutes = endTime.difference(session.startTime).inMinutes;

    final entity = StudySessionModel.toEntity(session);
    final updated = entity.copyWith(
      endTime: endTime,
      durationMinutes: durationMinutes,
      notes: notes ?? entity.notes,
      updatedAt: DateTime.now(),
    );

    final companion = StudySessionModel.toCompanion(updated, isUpdate: true);
    await _database
        .into(_database.studySessions)
        .insertOnConflictUpdate(companion);

    final result = await _database.getStudySessionById(sessionId);
    return StudySessionModel.toEntity(result!);
  }

  Future<StudySessionEntity> createStudySession({
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    String? subject,
    String? notes,
  }) async {
    final durationMinutes = endTime.difference(startTime).inMinutes;

    final companion = StudySessionsCompanion.insert(
      date: date,
      startTime: startTime,
      endTime: Value(endTime),
      durationMinutes: Value(durationMinutes),
      subject: Value(subject),
      notes: Value(notes),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    final id = await _database.insertStudySession(companion);
    final session = await _database.getStudySessionById(id);

    return StudySessionModel.toEntity(session!);
  }

  Future<StudySessionEntity?> getStudySessionById(int id) async {
    final session = await _database.getStudySessionById(id);
    return session != null ? StudySessionModel.toEntity(session) : null;
  }

  Future<List<StudySessionEntity>> getStudySessionsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final sessions = await (_database.select(_database.studySessions)
          ..where((s) =>
              s.date.isBiggerOrEqualValue(startOfDay) &
              s.date.isSmallerThanValue(endOfDay) &
              s.deletedAt.isNull())
          ..orderBy([(s) => OrderingTerm.desc(s.startTime)]))
        .get();

    return sessions.map(StudySessionModel.toEntity).toList();
  }

  Future<List<StudySessionEntity>> getStudySessionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final sessions = await (_database.select(_database.studySessions)
          ..where((s) =>
              s.date.isBiggerOrEqualValue(start) &
              s.date.isSmallerOrEqualValue(end) &
              s.deletedAt.isNull())
          ..orderBy([(s) => OrderingTerm.desc(s.date)]))
        .get();

    return sessions.map(StudySessionModel.toEntity).toList();
  }

  Future<StudySessionEntity?> getActiveStudySession() async {
    final session = await (_database.select(_database.studySessions)
          ..where((s) => s.endTime.isNull() & s.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();

    return session != null ? StudySessionModel.toEntity(session) : null;
  }

  Future<StudySessionEntity> updateStudySession(
    StudySessionEntity session,
  ) async {
    final companion = StudySessionModel.toCompanion(
      session.copyWith(updatedAt: DateTime.now()),
      isUpdate: true,
    );

    await _database
        .into(_database.studySessions)
        .insertOnConflictUpdate(companion);

    final updated = await _database.getStudySessionById(session.id);
    return StudySessionModel.toEntity(updated!);
  }

  Future<void> deleteStudySession(int id) async {
    await (_database.update(_database.studySessions)
          ..where((s) => s.id.equals(id)))
        .write(StudySessionsCompanion(deletedAt: Value(DateTime.now())));
  }

  // ==================== STATISTICS ====================

  Future<SleepStats> getSleepStats(DateTime start, DateTime end) async {
    final records = await getSleepRecordsByDateRange(start, end);

    final completeRecords =
        records.where((r) => r.isComplete).toList();

    final totalRecords = records.length;
    final completedCount = completeRecords.length;

    final avgPlannedHours = totalRecords > 0
        ? records.map((r) => r.plannedHours).reduce((a, b) => a + b) /
            totalRecords
        : 0.0;

    final avgActualHours = completedCount > 0
        ? completeRecords
                .map((r) => r.actualHours!)
                .reduce((a, b) => a + b) /
            completedCount
        : null;

    final recordsWithQuality =
        completeRecords.where((r) => r.sleepQuality != null).toList();
    final avgQuality = recordsWithQuality.isNotEmpty
        ? recordsWithQuality
                .map((r) => r.sleepQuality!.toDouble())
                .reduce((a, b) => a + b) /
            recordsWithQuality.length
        : null;

    final metPlanCount =
        completeRecords.where((r) => r.metPlan == true).length;

    return SleepStats(
      totalRecords: totalRecords,
      completeRecords: completedCount,
      averagePlannedHours: avgPlannedHours,
      averageActualHours: avgActualHours,
      averageSleepQuality: avgQuality,
      recordsMetPlan: metPlanCount,
      records: records,
    );
  }

  Future<StudyStats> getStudyStats(DateTime start, DateTime end) async {
    final sessions = await getStudySessionsByDateRange(start, end);

    final totalSessions = sessions.length;
    final totalMinutes =
        sessions.fold<int>(0, (sum, s) => sum + s.calculatedDuration);

    final avgMinutes =
        totalSessions > 0 ? totalMinutes / totalSessions : 0.0;

    // Agrupar por materia
    final subjectMinutes = <String, int>{};
    for (final session in sessions) {
      final subject = session.subject ?? 'Sin materia';
      subjectMinutes[subject] =
          (subjectMinutes[subject] ?? 0) + session.calculatedDuration;
    }

    return StudyStats(
      totalSessions: totalSessions,
      totalMinutes: totalMinutes,
      averageSessionMinutes: avgMinutes,
      subjectMinutes: subjectMinutes,
      sessions: sessions,
    );
  }
}
