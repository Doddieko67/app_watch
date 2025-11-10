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

        // Calcular próxima ocurrencia y reprogramar notificación
        // IMPORTANTE: Se mantiene marcado (isCompleted = true) hasta la próxima ocurrencia
        final nextOccurrence = calculateNextOccurrence(reminder);
        final updated = reminder.copyWith(
          nextOccurrence: nextOccurrence,
          // NO cambiamos isCompleted aquí - se mantiene true hasta que llegue nextOccurrence
          updatedAt: DateTime.now(),
        );
        await _localDataSource.updateReminder(updated);

        // Reprogramar notificación para la próxima ocurrencia
        await _notificationService.scheduleReminder(updated);
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
    final startDate = reminder.startDate;

    // Si hay fecha de inicio y es en el futuro, usar esa como primera ocurrencia
    if (startDate != null) {
      final startDateTime = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );

      // Si la fecha de inicio es en el futuro, esa es la próxima ocurrencia
      if (startDateTime.isAfter(now)) {
        return startDateTime;
      }
    }

    switch (reminder.recurrenceType) {
      case RecurrenceType.daily:
        return _calculateNextDaily(now, scheduledTime, startDate);

      case RecurrenceType.weekly:
        return _calculateNextWeekly(
            now, scheduledTime, reminder.recurrenceDays ?? [], startDate);

      case RecurrenceType.custom:
        return _calculateNextCustom(
            now, scheduledTime, reminder.customIntervalDays ?? 1, startDate);
    }
  }

  // Helpers privados

  /// Calcula la próxima ocurrencia para recurrencia diaria
  DateTime _calculateNextDaily(DateTime now, DateTime scheduledTime, DateTime? startDate) {
    var nextOccurrence = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    // Si ya pasó hoy, programar para mañana
    if (nextOccurrence.isBefore(now)) {
      nextOccurrence = nextOccurrence.add(const Duration(days: 1));
    }

    // Si hay fecha de inicio, asegurarse de que no sea antes
    if (startDate != null) {
      final startDateTime = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );
      if (nextOccurrence.isBefore(startDateTime)) {
        return startDateTime;
      }
    }

    return nextOccurrence;
  }

  /// Calcula la próxima ocurrencia para recurrencia semanal
  DateTime _calculateNextWeekly(
    DateTime now,
    DateTime scheduledTime,
    List<int> weekdays,
    DateTime? startDate,
  ) {
    if (weekdays.isEmpty) {
      // Si no hay días específicos, usar diario
      return _calculateNextDaily(now, scheduledTime, startDate);
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

    // Si hay startDate, buscar desde esa fecha
    if (startDate != null) {
      final startDateTime = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );
      if (startDateTime.isAfter(now)) {
        nextOccurrence = startDateTime;
      }
    }

    // Buscar el próximo día de la semana válido
    for (var i = 0; i < 14; i++) { // Buscar hasta 2 semanas adelante
      final candidateDate = nextOccurrence.add(Duration(days: i));
      final candidateWeekday = candidateDate.weekday;

      // Si es un día válido y es en el futuro (o igual a startDate)
      bool isAfterStart = startDate == null ||
          !candidateDate.isBefore(DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
            scheduledTime.hour,
            scheduledTime.minute,
          ));

      if (sortedWeekdays.contains(candidateWeekday) &&
          candidateDate.isAfter(now) &&
          isAfterStart) {
        return candidateDate;
      }
    }

    // Si no encontramos ninguno (no debería pasar), usar el próximo día válido
    return nextOccurrence.add(const Duration(days: 7));
  }

  /// Calcula la próxima ocurrencia para recurrencia custom (cada X días)
  DateTime _calculateNextCustom(
    DateTime now,
    DateTime scheduledTime,
    int intervalDays,
    DateTime? startDate,
  ) {
    var nextOccurrence = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    // Si ya pasó hoy, programar para el próximo intervalo
    if (nextOccurrence.isBefore(now)) {
      nextOccurrence = nextOccurrence.add(Duration(days: intervalDays));
    }

    // Si hay fecha de inicio, calcular desde ahí
    if (startDate != null) {
      final startDateTime = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );

      // Si la próxima ocurrencia es antes de startDate
      if (nextOccurrence.isBefore(startDateTime)) {
        return startDateTime;
      }

      // Calcular cuántos intervalos han pasado desde startDate
      final daysSinceStart = nextOccurrence.difference(startDateTime).inDays;
      final intervalsElapsed = (daysSinceStart / intervalDays).floor();

      // Próxima ocurrencia basada en intervalos desde startDate
      return startDateTime.add(Duration(days: (intervalsElapsed + 1) * intervalDays));
    }

    return nextOccurrence;
  }
}
