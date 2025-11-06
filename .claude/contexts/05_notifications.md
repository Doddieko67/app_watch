# 🔔 Sistema de Notificaciones

## Visión General

Sistema completo de notificaciones locales usando `flutter_local_notifications` y `timezone` para:
- Recordatorios recurrentes de tareas
- Alertas de sueño (pre-dormir y despertar)
- Sugerencias de horarios de estudio óptimos
- Recordatorios de comidas (opcional)

---

## Tipos de Notificaciones

### 1. Recordatorios de Tareas

**Características:**
- Recurrencia: diaria, semanal, personalizada
- Horario específico configurado por el usuario
- Soporte para múltiples notificaciones por día
- Reprogramación automática después de marcar como completado

**Canales Android:**
```dart
const AndroidNotificationChannel remindersChannel = AndroidNotificationChannel(
  'reminders_channel',
  'Recordatorios',
  description: 'Notificaciones de tareas y recordatorios diarios',
  importance: Importance.high,
  playSound: true,
  enableVibration: true,
);
```

### 2. Notificaciones de Sueño

**Pre-Dormir:**
- Se dispara 30 minutos antes de la hora configurada de dormir
- Mensaje: "Es hora de prepararte para dormir 😴"

**Despertar:**
- Se dispara a la hora configurada de despertar
- Mensaje: "Buenos días! Es hora de levantarse ☀️"

**Canales Android:**
```dart
const AndroidNotificationChannel sleepChannel = AndroidNotificationChannel(
  'sleep_channel',
  'Sueño y Descanso',
  description: 'Recordatorios de horarios de sueño',
  importance: Importance.high,
  playSound: true,
  enableVibration: true,
);
```

### 3. Hora Óptima de Estudio

**Características:**
- Se calcula dinámicamente basándose en:
  - Hora de despertar
  - Tiempo de descanso
  - Sesiones de estudio previas
- Solo se activa si el usuario lo habilita en configuración

**Cálculo:**
```
Hora óptima = hora_despertar + 1-2 horas (ventana de máxima concentración)
```

**Canales Android:**
```dart
const AndroidNotificationChannel studyChannel = AndroidNotificationChannel(
  'study_channel',
  'Estudio',
  description: 'Recordatorios de sesiones de estudio',
  importance: Importance.defaultImportance,
  playSound: false,
  enableVibration: true,
);
```

---

## Implementación

### Service Principal

```dart
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    // Configuración Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración iOS
    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    final settings = InitializationSettings(
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
    final location = tz.getLocation('America/Mexico_City'); // Ajustar según zona
    tz.setLocalLocation(location);
  }

  Future<void> _createNotificationChannels() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(remindersChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(sleepChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(studyChannel);
  }

  /// Programar notificación de recordatorio
  Future<void> scheduleReminder(Reminder reminder) async {
    final notificationId = reminder.id; // Usar ID de DB como notification ID

    final androidDetails = AndroidNotificationDetails(
      remindersChannel.id,
      remindersChannel.name,
      channelDescription: remindersChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(
        reminder.description ?? '',
        contentTitle: reminder.title,
      ),
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Programar según tipo de recurrencia
    switch (reminder.recurrenceType) {
      case 'daily':
        await _scheduleDailyNotification(
          notificationId,
          reminder.title,
          reminder.description ?? '',
          reminder.scheduledTime,
          details,
        );
        break;

      case 'weekly':
        await _scheduleWeeklyNotification(
          notificationId,
          reminder.title,
          reminder.description ?? '',
          reminder.scheduledTime,
          reminder.recurrenceDays,
          details,
        );
        break;

      case 'custom':
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
    // Programar notificación para cada día de la semana especificado
    for (final weekday in weekdays) {
      final scheduledDate = _nextInstanceOfWeekday(
        scheduledTime,
        weekday,
      );

      await _notifications.zonedSchedule(
        id + weekday, // ID único por día
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

  /// Programar notificaciones de sueño
  Future<void> scheduleSleepNotifications(SleepSchedule schedule) async {
    // Pre-dormir (30 min antes)
    final preSleepTime = schedule.defaultBedtime.subtract(
      Duration(minutes: schedule.preSleepNotificationMinutes),
    );

    await _scheduleDailyNotification(
      9998, // ID fijo para pre-sueño
      'Hora de prepararte para dormir',
      'En ${schedule.preSleepNotificationMinutes} minutos deberías estar durmiendo 😴',
      preSleepTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          sleepChannel.id,
          sleepChannel.name,
          channelDescription: sleepChannel.description,
          importance: Importance.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );

    // Despertar
    await _scheduleDailyNotification(
      9999, // ID fijo para despertar
      'Buenos días',
      'Es hora de levantarse y comenzar el día ☀️',
      schedule.defaultWakeup,
      NotificationDetails(
        android: AndroidNotificationDetails(
          sleepChannel.id,
          sleepChannel.name,
          channelDescription: sleepChannel.description,
          importance: Importance.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  /// Cancelar notificación específica
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Obtener notificaciones pendientes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
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

  void _onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) {
    // Handler para iOS legacy
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Navegar a la pantalla correspondiente según el payload
    final payload = response.payload;
    if (payload != null) {
      // Parsear payload y navegar
      // Ejemplo: "reminder:123" -> Abrir reminder con ID 123
    }
  }
}
```

---

## Permisos

### Android

En `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>

    <application>
        <!-- Receiver para notificaciones después de reinicio -->
        <receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
            android:exported="false">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
            </intent-filter>
        </receiver>
    </application>
</manifest>
```

### iOS

En `ios/Runner/Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

---

## Gestión de Notificaciones Perdidas

Si el usuario desactiva una notificación o la app estaba cerrada:

```dart
class NotificationManager {
  final AppDatabase _db;
  final NotificationService _notificationService;

  /// Reprogramar todas las notificaciones activas
  Future<void> rescheduleAllActiveNotifications() async {
    // Recordatorios
    final activeReminders = await _db.remindersDao.getActiveReminders();
    for (final reminder in activeReminders) {
      await _notificationService.scheduleReminder(reminder);
    }

    // Sueño
    final activeSleepSchedule = await _db.sleepSchedulesDao.getActiveSchedule();
    if (activeSleepSchedule != null) {
      await _notificationService.scheduleSleepNotifications(activeSleepSchedule);
    }
  }

  /// Sincronizar notificaciones con la base de datos
  Future<void> syncNotifications() async {
    final pending = await _notificationService.getPendingNotifications();
    final pendingIds = pending.map((n) => n.id).toSet();

    // Encontrar recordatorios que deberían tener notificación pero no la tienen
    final reminders = await _db.remindersDao.getActiveReminders();
    for (final reminder in reminders) {
      if (!pendingIds.contains(reminder.id)) {
        // Reprogramar
        await _notificationService.scheduleReminder(reminder);
      }
    }
  }
}
```

---

## Testing de Notificaciones

```dart
// En development, mostrar notificación inmediata para probar
Future<void> testNotification() async {
  await _notifications.show(
    0,
    'Test Notification',
    'Esta es una notificación de prueba',
    NotificationDetails(
      android: AndroidNotificationDetails(
        remindersChannel.id,
        remindersChannel.name,
        channelDescription: remindersChannel.description,
      ),
    ),
  );
}
```

---

## Consideraciones

### Android 12+ (API 31+)
- Requiere permiso explícito `SCHEDULE_EXACT_ALARM`
- Solicitar en primera ejecución
- Manejar caso de denegación (usar `AndroidScheduleMode.inexact`)

### iOS
- Solicitar permisos en primera ejecución
- Las notificaciones no se muestran si la app está en foreground (configurable)

### Batería
- Usar `AndroidScheduleMode.exactAllowWhileIdle` para permitir notificaciones incluso en modo ahorro
- Minimizar notificaciones frecuentes innecesarias

### Timezone
- Configurar correctamente la zona horaria del usuario
- Actualizar si el usuario viaja
- Manejar cambios de horario de verano

---

## Métricas de Éxito

- 🎯 **Tasa de entrega:** >99% de notificaciones programadas se entregan
- ⏰ **Precisión:** ±2 minutos del horario programado
- 🔋 **Impacto en batería:** <1% de consumo diario
- 👤 **Tasa de cancelación:** <20% de usuarios desactivan notificaciones
