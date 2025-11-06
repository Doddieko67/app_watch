# 📊 Exportación e Importación de Datos

## Formato JSON

### Estructura Completa

```json
{
  "version": "1.0.0",
  "exported_at": "2025-11-06T10:30:00.000Z",
  "app_info": {
    "app_version": "1.0.0",
    "platform": "android",
    "device_info": "Samsung Galaxy S23"
  },
  "data": {
    "reminders": [
      {
        "id": 1,
        "title": "Tomar vitamina D",
        "description": "Una cápsula después del desayuno",
        "recurrenceType": "daily",
        "scheduledTime": "2025-11-06T09:00:00.000Z",
        "priority": 2,
        "tags": ["salud", "vitaminas"],
        "createdAt": "2025-11-01T10:00:00.000Z",
        "updatedAt": "2025-11-05T15:30:00.000Z"
      }
    ],
    "workouts": [
      {
        "id": 1,
        "name": "Push Day",
        "split": "push",
        "date": "2025-11-05T18:00:00.000Z",
        "durationMinutes": 75,
        "exercises": [
          {
            "name": "Bench Press",
            "sets": 4,
            "reps": 8,
            "weight": 80.0,
            "notes": "Buen progreso"
          }
        ]
      }
    ],
    "meals": [
      {
        "id": 1,
        "date": "2025-11-06T08:00:00.000Z",
        "mealType": "breakfast",
        "totalCalories": 520,
        "totalProtein": 35,
        "totalCarbs": 60,
        "totalFats": 15,
        "foodItems": [
          {
            "name": "Huevos revueltos",
            "quantity": 150,
            "unit": "g",
            "calories": 220,
            "protein": 18,
            "carbs": 2,
            "fats": 15,
            "source": "ai"
          }
        ]
      }
    ],
    "sleepRecords": [
      {
        "id": 1,
        "date": "2025-11-05T00:00:00.000Z",
        "plannedBedtime": "2025-11-05T23:00:00.000Z",
        "plannedWakeup": "2025-11-06T07:00:00.000Z",
        "actualBedtime": "2025-11-05T23:15:00.000Z",
        "actualWakeup": "2025-11-06T07:10:00.000Z",
        "sleepQuality": 4,
        "notes": "Buen descanso"
      }
    ],
    "studySessions": [
      {
        "id": 1,
        "date": "2025-11-06T00:00:00.000Z",
        "startTime": "2025-11-06T09:00:00.000Z",
        "endTime": "2025-11-06T11:00:00.000Z",
        "durationMinutes": 120,
        "subject": "Flutter",
        "notes": "Clean Architecture"
      }
    ],
    "nutritionGoals": {
      "dailyCalories": 2500,
      "dailyProtein": 180,
      "dailyCarbs": 280,
      "dailyFats": 70
    },
    "sleepSchedule": {
      "defaultBedtime": "23:00",
      "defaultWakeup": "07:00",
      "preSleepNotificationMinutes": 30
    }
  },
  "statistics": {
    "totalReminders": 15,
    "totalWorkouts": 48,
    "totalMeals": 312,
    "totalSleepRecords": 104
  }
}
```

---

## Implementación del Service

```dart
class ExportService {
  final AppDatabase _db;

  ExportService(this._db);

  /// Exportar todos los datos a JSON
  Future<String> exportToJson() async {
    final reminders = await _db.remindersDao.getAllReminders();
    final workouts = await _db.workoutsDao.getAllWorkoutsWithExercises();
    final meals = await _db.mealsDao.getAllMealsWithFoodItems();
    final sleepRecords = await _db.sleepRecordsDao.getAllRecords();
    final studySessions = await _db.studySessionsDao.getAllSessions();
    final nutritionGoals = await _db.nutritionGoalsDao.getActiveGoal();
    final sleepSchedule = await _db.sleepSchedulesDao.getActiveSchedule();

    final exportData = {
      'version': '1.0.0',
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'app_info': {
        'app_version': await _getAppVersion(),
        'platform': Platform.operatingSystem,
      },
      'data': {
        'reminders': reminders.map((r) => r.toJson()).toList(),
        'workouts': workouts.map((w) => w.toJson()).toList(),
        'meals': meals.map((m) => m.toJson()).toList(),
        'sleepRecords': sleepRecords.map((s) => s.toJson()).toList(),
        'studySessions': studySessions.map((s) => s.toJson()).toList(),
        'nutritionGoals': nutritionGoals?.toJson(),
        'sleepSchedule': sleepSchedule?.toJson(),
      },
      'statistics': {
        'totalReminders': reminders.length,
        'totalWorkouts': workouts.length,
        'totalMeals': meals.length,
        'totalSleepRecords': sleepRecords.length,
      },
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Exportar y guardar en archivo
  Future<File> exportToFile() async {
    final json = await exportToJson();
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${directory.path}/app_watch_backup_$timestamp.json');

    await file.writeAsString(json);
    return file;
  }

  /// Compartir exportación
  Future<void> shareExport() async {
    final file = await exportToFile();
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'App Watch - Backup de datos',
      text: 'Backup de datos de App Watch',
    );
  }

  /// Importar desde JSON string
  Future<ImportResult> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validar versión
      final version = data['version'] as String?;
      if (version == null || !_isVersionCompatible(version)) {
        return ImportResult.error('Versión incompatible: $version');
      }

      final imported = data['data'] as Map<String, dynamic>;
      int totalImported = 0;

      // Importar reminders
      if (imported.containsKey('reminders')) {
        final reminders = (imported['reminders'] as List)
            .map((r) => Reminder.fromJson(r))
            .toList();
        await _db.remindersDao.insertAll(reminders);
        totalImported += reminders.length;
      }

      // Importar workouts
      if (imported.containsKey('workouts')) {
        final workouts = (imported['workouts'] as List)
            .map((w) => WorkoutWithExercises.fromJson(w))
            .toList();
        for (final workout in workouts) {
          await _db.workoutsDao.insertWorkoutWithExercises(workout);
        }
        totalImported += workouts.length;
      }

      // Importar meals
      if (imported.containsKey('meals')) {
        final meals = (imported['meals'] as List)
            .map((m) => MealWithFoodItems.fromJson(m))
            .toList();
        for (final meal in meals) {
          await _db.mealsDao.insertMealWithFoodItems(meal);
        }
        totalImported += meals.length;
      }

      // Importar sleep records
      if (imported.containsKey('sleepRecords')) {
        final records = (imported['sleepRecords'] as List)
            .map((s) => SleepRecord.fromJson(s))
            .toList();
        await _db.sleepRecordsDao.insertAll(records);
        totalImported += records.length;
      }

      // Importar study sessions
      if (imported.containsKey('studySessions')) {
        final sessions = (imported['studySessions'] as List)
            .map((s) => StudySession.fromJson(s))
            .toList();
        await _db.studySessionsDao.insertAll(sessions);
        totalImported += sessions.length;
      }

      // Importar goals y schedules
      if (imported.containsKey('nutritionGoals') && imported['nutritionGoals'] != null) {
        final goals = NutritionGoals.fromJson(imported['nutritionGoals']);
        await _db.nutritionGoalsDao.insert(goals);
      }

      if (imported.containsKey('sleepSchedule') && imported['sleepSchedule'] != null) {
        final schedule = SleepSchedule.fromJson(imported['sleepSchedule']);
        await _db.sleepSchedulesDao.insert(schedule);
      }

      return ImportResult.success(totalImported);
    } catch (e, stackTrace) {
      debugPrint('Error importing data: $e\n$stackTrace');
      return ImportResult.error(e.toString());
    }
  }

  /// Importar desde archivo
  Future<ImportResult> importFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return ImportResult.error('Archivo no encontrado');
      }

      final jsonString = await file.readAsString();
      return await importFromJson(jsonString);
    } catch (e) {
      return ImportResult.error(e.toString());
    }
  }

  /// Validar compatibilidad de versiones
  bool _isVersionCompatible(String version) {
    final parts = version.split('.');
    final major = int.tryParse(parts[0]) ?? 0;

    // Solo aceptar versiones 1.x.x por ahora
    return major == 1;
  }

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}

/// Resultado de la importación
class ImportResult {
  final bool success;
  final int itemsImported;
  final String? errorMessage;

  ImportResult.success(this.itemsImported)
      : success = true,
        errorMessage = null;

  ImportResult.error(this.errorMessage)
      : success = false,
        itemsImported = 0;
}
```

---

## UI de Exportación/Importación

```dart
class ExportImportWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportService = ref.watch(exportServiceProvider);

    return Column(
      children: [
        // Exportar
        ListTile(
          leading: const Icon(Icons.upload_file),
          title: const Text('Exportar datos'),
          subtitle: const Text('Crear backup de todos tus datos'),
          onTap: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exportar datos'),
                content: const Text(
                  '¿Deseas crear un backup de todos tus datos?\n\n'
                  'Esto incluye:\n'
                  '• Recordatorios\n'
                  '• Entrenamientos\n'
                  '• Comidas\n'
                  '• Registros de sueño\n'
                  '• Sesiones de estudio',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Exportar'),
                  ),
                ],
              ),
            );

            if (result == true && context.mounted) {
              await _exportData(context, exportService);
            }
          },
        ),

        const Divider(),

        // Importar
        ListTile(
          leading: const Icon(Icons.download),
          title: const Text('Importar datos'),
          subtitle: const Text('Restaurar desde un backup'),
          onTap: () => _importData(context, exportService),
        ),

        const Divider(),

        // Compartir
        ListTile(
          leading: const Icon(Icons.share),
          title: const Text('Compartir backup'),
          subtitle: const Text('Exportar y compartir tus datos'),
          onTap: () async {
            try {
              await exportService.shareExport();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup compartido')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Future<void> _exportData(BuildContext context, ExportService service) async {
    try {
      final file = await service.exportToFile();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup guardado: ${file.path}'),
            action: SnackBarAction(
              label: 'Compartir',
              onPressed: () => service.shareExport(),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e')),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context, ExportService service) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        if (context.mounted) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Importar datos'),
              content: const Text(
                '¿Estás seguro de que deseas importar este backup?\n\n'
                'Esto agregará los datos al contenido existente.\n'
                'No se eliminarán datos actuales.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Importar'),
                ),
              ],
            ),
          );

          if (confirm == true && context.mounted) {
            final importResult = await service.importFromFile(
              result.files.single.path!,
            );

            if (context.mounted) {
              if (importResult.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Importados ${importResult.itemsImported} elementos',
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${importResult.errorMessage}'),
                  ),
                );
              }
            }
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al importar: $e')),
        );
      }
    }
  }
}
```

---

## Backup Automático

```dart
class AutoBackupService {
  final ExportService _exportService;
  final SharedPreferences _prefs;

  Future<void> scheduleAutoBackup() async {
    final frequency = _prefs.getString('backup_frequency') ?? 'never';

    if (frequency == 'never') return;

    final lastBackup = _prefs.getString('last_backup_date');
    final lastBackupDate = lastBackup != null
        ? DateTime.parse(lastBackup)
        : null;

    final now = DateTime.now();
    bool shouldBackup = false;

    if (lastBackupDate == null) {
      shouldBackup = true;
    } else {
      shouldBackup = switch (frequency) {
        'daily' => now.difference(lastBackupDate).inDays >= 1,
        'weekly' => now.difference(lastBackupDate).inDays >= 7,
        _ => false,
      };
    }

    if (shouldBackup) {
      await _performBackup();
    }
  }

  Future<void> _performBackup() async {
    try {
      await _exportService.exportToFile();
      await _prefs.setString('last_backup_date', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Auto backup failed: $e');
    }
  }
}
```

---

## Consideraciones de Seguridad

⚠️ **Importante:**
- NO incluir API keys en la exportación
- Advertir al usuario sobre compartir backups (contienen datos personales)
- Validar estructura JSON antes de importar
- Manejar datos corruptos sin crashear la app
- Opción de encriptar backup (feature futura)
