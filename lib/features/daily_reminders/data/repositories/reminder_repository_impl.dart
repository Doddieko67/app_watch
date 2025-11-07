import '../../../../core/services/notification_service.dart';
import '../../domain/entities/reminder_entity.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/reminder_local_datasource.dart';

/// Implementación del ReminderRepository
///
/// Implementa los métodos definidos en la interfaz del repositorio
/// usando el local data source y el servicio de notificaciones
class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderLocalDataSource _localDataSource;
  final NotificationService _notificationService;

  ReminderRepositoryImpl(
    this._localDataSource,
    this._notificationService,
  );

  @override
  Future<List<ReminderEntity>> getAllReminders() async {
    return await _localDataSource.getAllReminders();
  }

  @override
  Future<ReminderEntity?> getReminderById(int id) async {
    return await _localDataSource.getReminderById(id);
  }

  @override
  Future<List<ReminderEntity>> getActiveReminders() async {
    return await _localDataSource.getActiveReminders();
  }

  @override
  Future<List<ReminderEntity>> getPendingReminders() async {
    return await _localDataSource.getPendingReminders();
  }

  @override
  Future<List<ReminderEntity>> getCompletedReminders() async {
    return await _localDataSource.getCompletedReminders();
  }

  @override
  Future<List<ReminderEntity>> getRemindersByPriority(
      Priority priority) async {
    return await _localDataSource.getRemindersByPriority(priority);
  }

  @override
  Future<List<ReminderEntity>> getRemindersByTag(String tag) async {
    return await _localDataSource.getRemindersByTag(tag);
  }

  @override
  Future<List<ReminderEntity>> getTodayReminders() async {
    return await _localDataSource.getTodayReminders();
  }

  @override
  Future<int> createReminder(ReminderEntity reminder) async {
    final id = await _localDataSource.createReminder(reminder);

    // Programar notificación si está activo
    if (reminder.isActive && !reminder.isCompleted) {
      final reminderWithId = reminder.copyWith(id: id);
      await _notificationService.scheduleReminder(reminderWithId);
    }

    return id;
  }

  @override
  Future<bool> updateReminder(ReminderEntity reminder) async {
    final result = await _localDataSource.updateReminder(reminder);

    if (result) {
      // Cancelar notificaciones anteriores
      await _notificationService.cancelReminderNotifications(reminder);

      // Reprogramar si está activo y no completado
      if (reminder.isActive && !reminder.isCompleted) {
        await _notificationService.scheduleReminder(reminder);
      }
    }

    return result;
  }

  @override
  Future<bool> deleteReminder(int id) async {
    // Obtener el recordatorio antes de eliminarlo para cancelar sus notificaciones
    final reminder = await _localDataSource.getReminderById(id);

    final result = await _localDataSource.deleteReminder(id);

    if (result && reminder != null) {
      // Cancelar todas las notificaciones del recordatorio
      await _notificationService.cancelReminderNotifications(reminder);
    }

    return result;
  }

  @override
  Future<bool> markAsCompleted(int id) async {
    final result = await _localDataSource.markAsCompleted(id);

    if (result) {
      // Obtener el recordatorio actualizado
      final reminder = await _localDataSource.getReminderById(id);

      if (reminder != null) {
        // Cancelar notificación actual
        await _notificationService.cancelReminderNotifications(reminder);

        // Si es recurrente, calcular la próxima ocurrencia y reprogramar
        if (reminder.recurrenceType != RecurrenceType.custom) {
          final nextOccurrence = calculateNextOccurrence(reminder);
          final updated = reminder.copyWith(
            nextOccurrence: nextOccurrence,
            isCompleted: false,
            updatedAt: DateTime.now(),
          );
          await _localDataSource.updateReminder(updated);

          // Reprogramar notificación para la próxima ocurrencia
          await _notificationService.scheduleReminder(updated);
        }
      }
    }

    return result;
  }

  @override
  Future<bool> markAsNotCompleted(int id) async {
    return await _localDataSource.markAsNotCompleted(id);
  }

  @override
  DateTime calculateNextOccurrence(ReminderEntity reminder) {
    final now = DateTime.now();
    final scheduledTime = reminder.scheduledTime;

    switch (reminder.recurrenceType) {
      case RecurrenceType.daily:
        return _calculateNextDaily(now, scheduledTime);

      case RecurrenceType.weekly:
        return _calculateNextWeekly(
            now, scheduledTime, reminder.recurrenceDays ?? []);

      case RecurrenceType.custom:
        // Para custom, usar la próxima ocurrencia tal como está
        return reminder.nextOccurrence;
    }
  }

  // Helpers privados

  /// Calcula la próxima ocurrencia para recurrencia diaria
  DateTime _calculateNextDaily(DateTime now, DateTime scheduledTime) {
    final nextOccurrence = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    // Si ya pasó hoy, programar para mañana
    if (nextOccurrence.isBefore(now)) {
      return nextOccurrence.add(const Duration(days: 1));
    }

    return nextOccurrence;
  }

  /// Calcula la próxima ocurrencia para recurrencia semanal
  DateTime _calculateNextWeekly(
    DateTime now,
    DateTime scheduledTime,
    List<int> weekdays,
  ) {
    if (weekdays.isEmpty) {
      // Si no hay días específicos, usar diario
      return _calculateNextDaily(now, scheduledTime);
    }

    // Ordenar los días de la semana
    final sortedWeekdays = [...weekdays]..sort();

    // Crear la fecha base con la hora del recordatorio
    var nextOccurrence = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    // Buscar el próximo día de la semana válido
    for (var i = 0; i < 7; i++) {
      final candidateDate = nextOccurrence.add(Duration(days: i));
      final candidateWeekday = candidateDate.weekday;

      // Si es un día válido y es en el futuro
      if (sortedWeekdays.contains(candidateWeekday) &&
          candidateDate.isAfter(now)) {
        return candidateDate;
      }
    }

    // Si no encontramos ninguno (no debería pasar), usar el próximo día válido
    return nextOccurrence.add(const Duration(days: 7));
  }
}
