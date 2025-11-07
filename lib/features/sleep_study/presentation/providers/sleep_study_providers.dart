import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/datasources/sleep_study_local_datasource.dart';
import '../../data/repositories/sleep_study_repository_impl.dart';
import '../../domain/entities/sleep_record_entity.dart';
import '../../domain/entities/sleep_schedule_entity.dart';
import '../../domain/entities/study_session_entity.dart';
import '../../domain/repositories/sleep_study_repository.dart';
import '../../domain/use_cases/calculate_optimal_study_time.dart';
import '../../domain/use_cases/configure_sleep_schedule.dart';
import '../../domain/use_cases/get_sleep_stats.dart';
import '../../domain/use_cases/log_sleep_record.dart';
import '../../domain/use_cases/log_study_session.dart';

part 'sleep_study_providers.g.dart';

// ==================== DATA SOURCES ====================

@riverpod
SleepStudyLocalDataSource sleepStudyLocalDataSource(
  SleepStudyLocalDataSourceRef ref,
) {
  final database = ref.watch(appDatabaseProvider);
  return SleepStudyLocalDataSource(database);
}

// ==================== REPOSITORIES ====================

@riverpod
SleepStudyRepository sleepStudyRepository(SleepStudyRepositoryRef ref) {
  final localDataSource = ref.watch(sleepStudyLocalDataSourceProvider);
  return SleepStudyRepositoryImpl(localDataSource);
}

// ==================== USE CASES ====================

@riverpod
ConfigureSleepSchedule configureSleepSchedule(
  ConfigureSleepScheduleRef ref,
) {
  final repository = ref.watch(sleepStudyRepositoryProvider);
  return ConfigureSleepSchedule(repository);
}

@riverpod
LogSleepRecord logSleepRecord(LogSleepRecordRef ref) {
  final repository = ref.watch(sleepStudyRepositoryProvider);
  return LogSleepRecord(repository);
}

@riverpod
LogStudySession logStudySession(LogStudySessionRef ref) {
  final repository = ref.watch(sleepStudyRepositoryProvider);
  return LogStudySession(repository);
}

@riverpod
CalculateOptimalStudyTime calculateOptimalStudyTime(
  CalculateOptimalStudyTimeRef ref,
) {
  final repository = ref.watch(sleepStudyRepositoryProvider);
  return CalculateOptimalStudyTime(repository);
}

@riverpod
GetSleepStats getSleepStats(GetSleepStatsRef ref) {
  final repository = ref.watch(sleepStudyRepositoryProvider);
  return GetSleepStats(repository);
}

// ==================== STATE PROVIDERS ====================

/// Provider para el horario de sueño activo
@riverpod
Future<SleepScheduleEntity?> activeSleepSchedule(
  ActiveSleepScheduleRef ref,
) async {
  final repository = ref.watch(sleepStudyRepositoryProvider);
  return repository.getActiveSleepSchedule();
}

/// Provider para el registro de sueño de hoy
@riverpod
Future<SleepRecordEntity?> todaySleepRecord(
  TodaySleepRecordRef ref,
) async {
  final repository = ref.watch(sleepStudyRepositoryProvider);
  final today = DateTime.now();
  return repository.getSleepRecordByDate(today);
}

/// Provider para los registros de sueño de la semana
@riverpod
Future<List<SleepRecordEntity>> weeklySleepRecords(
  WeeklySleepRecordsRef ref,
) async {
  final repository = ref.watch(sleepStudyRepositoryProvider);
  final end = DateTime.now();
  final start = end.subtract(const Duration(days: 7));
  return repository.getSleepRecordsByDateRange(start, end);
}

/// Provider para la sesión de estudio activa
@riverpod
Future<StudySessionEntity?> activeStudySession(
  ActiveStudySessionRef ref,
) async {
  final repository = ref.watch(sleepStudyRepositoryProvider);
  return repository.getActiveStudySession();
}

/// Provider para las sesiones de estudio de hoy
@riverpod
Future<List<StudySessionEntity>> todayStudySessions(
  TodayStudySessionsRef ref,
) async {
  final repository = ref.watch(sleepStudyRepositoryProvider);
  final today = DateTime.now();
  return repository.getStudySessionsByDate(today);
}

/// Provider para las sesiones de estudio de la semana
@riverpod
Future<List<StudySessionEntity>> weeklyStudySessions(
  WeeklyStudySessionsRef ref,
) async {
  final repository = ref.watch(sleepStudyRepositoryProvider);
  final end = DateTime.now();
  final start = end.subtract(const Duration(days: 7));
  return repository.getStudySessionsByDateRange(start, end);
}

/// Provider para las estadísticas de sueño de la semana
@riverpod
Future<SleepStats> weeklySleepStats(WeeklySleepStatsRef ref) async {
  final repository = ref.watch(sleepStudyRepositoryProvider);
  final end = DateTime.now();
  final start = end.subtract(const Duration(days: 7));
  return repository.getSleepStats(start, end);
}

/// Provider para las estadísticas de estudio de la semana
@riverpod
Future<StudyStats> weeklyStudyStats(WeeklyStudyStatsRef ref) async {
  final repository = ref.watch(sleepStudyRepositoryProvider);
  final end = DateTime.now();
  final start = end.subtract(const Duration(days: 7));
  return repository.getStudyStats(start, end);
}

/// Provider para la hora óptima de estudio
@riverpod
Future<DateTime?> optimalStudyTime(OptimalStudyTimeRef ref) async {
  final useCase = ref.watch(calculateOptimalStudyTimeProvider);
  return useCase();
}
