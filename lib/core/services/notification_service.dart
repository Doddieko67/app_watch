import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/daily_reminders/domain/entities/reminder_entity.dart'
    hide Priority;

/// Servicio de Notificaciones Locales
///
/// Maneja todas las notificaciones de la aplicación
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) return;

    // Configuración Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Crear canales de Android
    await _createNotificationChannels();

    // Configurar timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Mexico_City'));

    _initialized = true;
  }

  Future<void> _createNotificationChannels() async {
    const remindersChannel = AndroidNotificationChannel(
      'reminders_channel',
      'Recordatorios',
      description: 'Notificaciones de tareas y recordatorios diarios',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(remindersChannel);
  }

  /// Programar notificación de recordatorio
  Future<void> scheduleReminder(ReminderEntity reminder) async {
    if (!_initialized) await initialize();

    final notificationId = reminder.id;

    const androidDetails = AndroidNotificationDetails(
      'reminders_channel',
      'Recordatorios',
      channelDescription: 'Notificaciones de tareas y recordatorios diarios',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Programar según tipo de recurrencia
    switch (reminder.recurrenceType) {
      case RecurrenceType.daily:
        await _scheduleDailyNotification(
          notificationId,
          reminder.title,
          reminder.description ?? '',
          reminder.scheduledTime,
          details,
        );
        break;

      case RecurrenceType.weekly:
        await _scheduleWeeklyNotification(
          notificationId,
          reminder.title,
          reminder.description ?? '',
          reminder.scheduledTime,
          reminder.recurrenceDays ?? [],
          details,
        );
        break;

      case RecurrenceType.custom:
        await _scheduleCustomNotification(
          notificationId,
          reminder.title,
          reminder.description ?? '',
          reminder.nextOccurrence,
          details,
        );
        break;
    }
  }

  Future<void> _scheduleDailyNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
    NotificationDetails details,
  ) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(scheduledTime),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleWeeklyNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
    List<int> weekdays,
    NotificationDetails details,
  ) async {
    if (weekdays.isEmpty) {
      // Si no hay días específicos, usar diario
      await _scheduleDailyNotification(id, title, body, scheduledTime, details);
      return;
    }

    // Programar notificación para cada día de la semana especificado
    for (var i = 0; i < weekdays.length; i++) {
      final weekday = weekdays[i];
      final scheduledDate = _nextInstanceOfWeekday(
        scheduledTime,
        weekday,
      );

      await _notifications.zonedSchedule(
        id + i, // ID único por día
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> _scheduleCustomNotification(
    int id,
    String title,
    String body,
    DateTime nextOccurrence,
    NotificationDetails details,
  ) async {
    final scheduledDate = tz.TZDateTime.from(nextOccurrence, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancelar notificación específica
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancelar todas las notificaciones de un recordatorio (incluye las semanales)
  Future<void> cancelReminderNotifications(ReminderEntity reminder) async {
    await _notifications.cancel(reminder.id);

    // Si es semanal, cancelar todas las notificaciones de los días
    if (reminder.recurrenceType == RecurrenceType.weekly &&
        reminder.recurrenceDays != null) {
      for (var i = 0; i < reminder.recurrenceDays!.length; i++) {
        await _notifications.cancel(reminder.id + i);
      }
    }
  }

  /// Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Obtener notificaciones pendientes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Mostrar notificación inmediata (para testing)
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      'reminders_channel',
      'Recordatorios',
      channelDescription: 'Notificaciones de tareas y recordatorios diarios',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details);
  }

  // Helpers

  tz.TZDateTime _nextInstanceOfTime(DateTime scheduledTime) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  tz.TZDateTime _nextInstanceOfWeekday(DateTime scheduledTime, int weekday) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(scheduledTime);

    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // TODO: Navegar a la pantalla correspondiente según el payload
    final payload = response.payload;
    if (payload != null) {
      // Parsear payload y navegar
      // Ejemplo: "reminder:123" -> Abrir reminder con ID 123
    }
  }

  /// Solicitar permisos de notificación (iOS)
  Future<bool?> requestPermissions() async {
    if (!_initialized) await initialize();

    return await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
}
