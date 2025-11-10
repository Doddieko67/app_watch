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
    ref.invalidate(todayRemindersProvider);
    ref.invalidate(pendingRemindersProvider);
  }
}

/// Provider que obtiene los recordatorios de hoy
@riverpod
Future<List<ReminderEntity>> todayReminders(TodayRemindersRef ref) async {
  final repository = ref.watch(reminderRepositoryProvider);
  return await repository.getTodayReminders();
}

/// Provider que obtiene los recordatorios pendientes
@riverpod
Future<List<ReminderEntity>> pendingReminders(PendingRemindersRef ref) async {
  final repository = ref.watch(reminderRepositoryProvider);
  return await repository.getPendingReminders();
}

// ========== Search and Sort Providers ==========

/// Enum para el ordenamiento de recordatorios
enum ReminderSortOrder {
  date,
  priority,
  alphabetical;

  String get displayName {
    switch (this) {
      case ReminderSortOrder.date:
        return 'Por fecha';
      case ReminderSortOrder.priority:
        return 'Por prioridad';
      case ReminderSortOrder.alphabetical:
        return 'Alfabético';
    }
  }
}

/// Provider para el query de búsqueda
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query.toLowerCase().trim();
  }

  void clear() {
    state = '';
  }
}

/// Provider para el ordenamiento actual
@riverpod
class CurrentSortOrder extends _$CurrentSortOrder {
  @override
  ReminderSortOrder build() => ReminderSortOrder.date;

  void setSortOrder(ReminderSortOrder order) {
    state = order;
  }
}

/// Provider que filtra y ordena recordatorios según búsqueda y ordenamiento
@riverpod
Future<List<ReminderEntity>> searchAndSortedReminders(
    SearchAndSortedRemindersRef ref) async {
  final reminders = await ref.watch(filteredRemindersProvider.future);
  final searchQuery = ref.watch(searchQueryProvider);
  final sortOrder = ref.watch(currentSortOrderProvider);

  // Filtrar por búsqueda
  var filtered = reminders;
  if (searchQuery.isNotEmpty) {
    filtered = reminders.where((reminder) {
      final titleMatch = reminder.title.toLowerCase().contains(searchQuery);
      final descriptionMatch = reminder.description
              ?.toLowerCase()
              .contains(searchQuery) ??
          false;
      final tagsMatch =
          reminder.tags?.any((tag) => tag.toLowerCase().contains(searchQuery)) ??
              false;
      return titleMatch || descriptionMatch || tagsMatch;
    }).toList();
  }

  // Ordenar
  switch (sortOrder) {
    case ReminderSortOrder.date:
      filtered.sort((a, b) => a.nextOccurrence.compareTo(b.nextOccurrence));
      break;
    case ReminderSortOrder.priority:
      filtered.sort((a, b) {
        // HIGH = 2, MEDIUM = 1, LOW = 0 (orden inverso para que HIGH sea primero)
        final priorityOrder = {
          Priority.high: 0,
          Priority.medium: 1,
          Priority.low: 2,
        };
        final priorityCompare =
            priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
        if (priorityCompare != 0) return priorityCompare;
        // Si tienen la misma prioridad, ordenar por fecha
        return a.nextOccurrence.compareTo(b.nextOccurrence);
      });
      break;
    case ReminderSortOrder.alphabetical:
      filtered.sort((a, b) => a.title.compareTo(b.title));
      break;
  }

  return filtered;
}
