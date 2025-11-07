import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/notification_provider.dart';
import '../../data/datasources/reminder_local_datasource.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../domain/entities/reminder_entity.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/usecases/create_reminder.dart';
import '../../domain/usecases/delete_reminder.dart';
import '../../domain/usecases/get_reminders.dart';
import '../../domain/usecases/toggle_reminder_status.dart';
import '../../domain/usecases/update_reminder.dart';

part 'reminder_providers.g.dart';

// ========== Data Layer Providers ==========

/// Provider para ReminderLocalDataSource
@riverpod
ReminderLocalDataSource reminderLocalDataSource(
    ReminderLocalDataSourceRef ref) {
  final database = ref.watch(appDatabaseProvider);
  return ReminderLocalDataSource(database);
}

/// Provider para ReminderRepository
@riverpod
ReminderRepository reminderRepository(ReminderRepositoryRef ref) {
  final localDataSource = ref.watch(reminderLocalDataSourceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return ReminderRepositoryImpl(localDataSource, notificationService);
}

// ========== Use Cases Providers ==========

/// Provider para CreateReminder use case
@riverpod
CreateReminder createReminder(CreateReminderRef ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return CreateReminder(repository);
}

/// Provider para UpdateReminder use case
@riverpod
UpdateReminder updateReminder(UpdateReminderRef ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return UpdateReminder(repository);
}

/// Provider para DeleteReminder use case
@riverpod
DeleteReminder deleteReminder(DeleteReminderRef ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return DeleteReminder(repository);
}

/// Provider para GetAllReminders use case
@riverpod
GetAllReminders getAllReminders(GetAllRemindersRef ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return GetAllReminders(repository);
}

/// Provider para GetActiveReminders use case
@riverpod
GetActiveReminders getActiveReminders(GetActiveRemindersRef ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return GetActiveReminders(repository);
}

/// Provider para GetPendingReminders use case
@riverpod
GetPendingReminders getPendingReminders(GetPendingRemindersRef ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return GetPendingReminders(repository);
}

/// Provider para GetCompletedReminders use case
@riverpod
GetCompletedReminders getCompletedReminders(GetCompletedRemindersRef ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return GetCompletedReminders(repository);
}

/// Provider para GetTodayReminders use case
@riverpod
GetTodayReminders getTodayReminders(GetTodayRemindersRef ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return GetTodayReminders(repository);
}

/// Provider para MarkReminderAsCompleted use case
@riverpod
MarkReminderAsCompleted markReminderAsCompleted(
    MarkReminderAsCompletedRef ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return MarkReminderAsCompleted(repository);
}

/// Provider para MarkReminderAsNotCompleted use case
@riverpod
MarkReminderAsNotCompleted markReminderAsNotCompleted(
    MarkReminderAsNotCompletedRef ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  return MarkReminderAsNotCompleted(repository);
}

// ========== State Providers ==========

/// Enum para el filtro de recordatorios
enum ReminderFilter {
  all,
  pending,
  completed,
  today;

  String get displayName {
    switch (this) {
      case ReminderFilter.all:
        return 'Todos';
      case ReminderFilter.pending:
        return 'Pendientes';
      case ReminderFilter.completed:
        return 'Completados';
      case ReminderFilter.today:
        return 'Hoy';
    }
  }
}

/// Provider para el filtro actual
@riverpod
class CurrentReminderFilter extends _$CurrentReminderFilter {
  @override
  ReminderFilter build() => ReminderFilter.all;

  void setFilter(ReminderFilter filter) {
    state = filter;
  }
}

/// Provider que obtiene los recordatorios según el filtro actual
@riverpod
Future<List<ReminderEntity>> filteredReminders(FilteredRemindersRef ref) async {
  final filter = ref.watch(currentReminderFilterProvider);
  final repository = ref.watch(reminderRepositoryProvider);

  switch (filter) {
    case ReminderFilter.all:
      return await repository.getActiveReminders();
    case ReminderFilter.pending:
      return await repository.getPendingReminders();
    case ReminderFilter.completed:
      return await repository.getCompletedReminders();
    case ReminderFilter.today:
      return await repository.getTodayReminders();
  }
}

/// Provider para refrescar la lista de recordatorios
@riverpod
class RefreshReminders extends _$RefreshReminders {
  @override
  int build() => 0;

  void refresh() {
    state++;
    ref.invalidate(filteredRemindersProvider);
  }
}
