import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/app_database.dart';

/// Result of import operation
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

/// Service for exporting and importing app data
class ExportImportService {
  final AppDatabase _db;

  ExportImportService(this._db);

  /// Export all data to JSON string
  Future<String> exportToJson() async {
    final reminders = await _db.getAllReminders();
    final workouts = await _db.getAllWorkouts();
    final meals = await _db.getAllMeals();
    final sleepRecords = await _db.getAllSleepRecords();
    final studySessions = await _db.getAllStudySessions();
    final nutritionGoals = await _db.getActiveNutritionGoal();
    final sleepSchedule = await _db.getActiveSleepSchedule();

    final packageInfo = await PackageInfo.fromPlatform();

    final exportData = {
      'version': '1.0.0',
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'app_info': {
        'app_version': packageInfo.version,
        'platform': Platform.operatingSystem,
      },
      'data': {
        'reminders': reminders.map((r) => _reminderToJson(r)).toList(),
        'workouts': workouts.map((w) => _workoutToJson(w)).toList(),
        'meals': meals.map((m) => _mealToJson(m)).toList(),
        'sleepRecords': sleepRecords.map((s) => _sleepRecordToJson(s)).toList(),
        'studySessions': studySessions.map((s) => _studySessionToJson(s)).toList(),
        'nutritionGoals': nutritionGoals != null ? _nutritionGoalsToJson(nutritionGoals) : null,
        'sleepSchedule': sleepSchedule != null ? _sleepScheduleToJson(sleepSchedule) : null,
      },
      'statistics': {
        'totalReminders': reminders.length,
        'totalWorkouts': workouts.length,
        'totalMeals': meals.length,
        'totalSleepRecords': sleepRecords.length,
        'totalStudySessions': studySessions.length,
      },
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Export and save to file
  Future<File> exportToFile() async {
    final json = await exportToJson();
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
    final file = File('${directory.path}/app_watch_backup_$timestamp.json');

    await file.writeAsString(json);
    return file;
  }

  /// Share export file
  Future<void> shareExport() async {
    final file = await exportToFile();
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'App Watch - Backup de datos',
      text: 'Backup de datos de App Watch generado el ${DateTime.now().toString().split('.')[0]}',
    );
  }

  /// Import from JSON string
  Future<ImportResult> importFromJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate version
      final version = data['version'] as String?;
      if (version == null || !_isVersionCompatible(version)) {
        return ImportResult.error('Versión incompatible: $version');
      }

      final imported = data['data'] as Map<String, dynamic>;
      int totalImported = 0;

      // Import reminders
      if (imported.containsKey('reminders') && imported['reminders'] != null) {
        final reminders = (imported['reminders'] as List)
            .map((r) => _jsonToReminderCompanion(r))
            .toList();
        for (final reminder in reminders) {
          await _db.insertReminder(reminder);
          totalImported++;
        }
      }

      // Import workouts (Note: would need to handle exercises separately in real implementation)
      if (imported.containsKey('workouts') && imported['workouts'] != null) {
        final workouts = (imported['workouts'] as List)
            .map((w) => _jsonToWorkoutCompanion(w))
            .toList();
        for (final workout in workouts) {
          await _db.insertWorkout(workout);
          totalImported++;
        }
      }

      // Import meals (Note: would need to handle food items separately in real implementation)
      if (imported.containsKey('meals') && imported['meals'] != null) {
        final meals = (imported['meals'] as List)
            .map((m) => _jsonToMealCompanion(m))
            .toList();
        for (final meal in meals) {
          await _db.insertMeal(meal);
          totalImported++;
        }
      }

      // Import sleep records
      if (imported.containsKey('sleepRecords') && imported['sleepRecords'] != null) {
        final records = (imported['sleepRecords'] as List)
            .map((s) => _jsonToSleepRecordCompanion(s))
            .toList();
        for (final record in records) {
          await _db.insertSleepRecord(record);
          totalImported++;
        }
      }

      // Import study sessions
      if (imported.containsKey('studySessions') && imported['studySessions'] != null) {
        final sessions = (imported['studySessions'] as List)
            .map((s) => _jsonToStudySessionCompanion(s))
            .toList();
        for (final session in sessions) {
          await _db.insertStudySession(session);
          totalImported++;
        }
      }

      return ImportResult.success(totalImported);
    } catch (e, stackTrace) {
      print('Error importing data: $e\n$stackTrace');
      return ImportResult.error(e.toString());
    }
  }

  /// Import from file
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

  /// Check if version is compatible
  bool _isVersionCompatible(String version) {
    final parts = version.split('.');
    final major = int.tryParse(parts[0]) ?? 0;
    // Accept version 1.x.x for now
    return major == 1;
  }

  // JSON conversion methods

  Map<String, dynamic> _reminderToJson(Reminder r) {
    return {
      'title': r.title,
      'description': r.description,
      'recurrenceType': r.recurrenceType,
      'scheduledTime': r.scheduledTime.toIso8601String(),
      'priority': r.priority,
      'tags': r.tags,
      'isCompleted': r.isCompleted,
      'createdAt': r.createdAt.toIso8601String(),
      'updatedAt': r.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _workoutToJson(Workout w) {
    return {
      'name': w.name,
      'split': w.split,
      'date': w.date.toIso8601String(),
      'durationMinutes': w.durationMinutes,
      'notes': w.notes,
      'createdAt': w.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _mealToJson(Meal m) {
    return {
      'date': m.date.toIso8601String(),
      'mealType': m.mealType,
      'totalCalories': m.totalCalories,
      'totalProtein': m.totalProtein,
      'totalCarbs': m.totalCarbs,
      'totalFats': m.totalFats,
      'notes': m.notes,
      'createdAt': m.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _sleepRecordToJson(SleepRecord s) {
    return {
      'date': s.date.toIso8601String(),
      'plannedBedtime': s.plannedBedtime.toIso8601String(),
      'plannedWakeup': s.plannedWakeup.toIso8601String(),
      'actualBedtime': s.actualBedtime?.toIso8601String(),
      'actualWakeup': s.actualWakeup?.toIso8601String(),
      'sleepQuality': s.sleepQuality,
      'notes': s.notes,
      'createdAt': s.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _studySessionToJson(StudySession s) {
    return {
      'date': s.date.toIso8601String(),
      'startTime': s.startTime.toIso8601String(),
      'endTime': s.endTime?.toIso8601String(),
      'durationMinutes': s.durationMinutes,
      'subject': s.subject,
      'notes': s.notes,
      'createdAt': s.createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _nutritionGoalsToJson(NutritionGoal g) {
    return {
      'dailyCalories': g.dailyCalories,
      'dailyProtein': g.dailyProtein,
      'dailyCarbs': g.dailyCarbs,
      'dailyFats': g.dailyFats,
    };
  }

  Map<String, dynamic> _sleepScheduleToJson(SleepSchedule s) {
    return {
      'defaultBedtime': s.defaultBedtime,
      'defaultWakeup': s.defaultWakeup,
      'preSleepNotificationMinutes': s.preSleepNotificationMinutes,
    };
  }

  RemindersCompanion _jsonToReminderCompanion(Map<String, dynamic> json) {
    final scheduledTime = DateTime.parse(json['scheduledTime'] as String);
    return RemindersCompanion.insert(
      title: json['title'] as String,
      description: Value(json['description'] as String?),
      recurrenceType: json['recurrenceType'] as String,
      scheduledTime: scheduledTime,
      nextOccurrence: scheduledTime, // Use same as scheduledTime for import
      priority: Value(json['priority'] as int? ?? 1),
      tags: Value(json['tags'] as String?),
      isCompleted: Value(json['isCompleted'] as bool? ?? false),
      createdAt: Value(DateTime.parse(json['createdAt'] as String)),
      updatedAt: Value(DateTime.parse(json['updatedAt'] as String)),
    );
  }

  WorkoutsCompanion _jsonToWorkoutCompanion(Map<String, dynamic> json) {
    return WorkoutsCompanion.insert(
      name: json['name'] as String,
      split: json['split'] as String,
      date: DateTime.parse(json['date'] as String),
      durationMinutes: Value(json['durationMinutes'] as int? ?? 0),
      notes: Value(json['notes'] as String?),
      createdAt: Value(DateTime.parse(json['createdAt'] as String)),
    );
  }

  MealsCompanion _jsonToMealCompanion(Map<String, dynamic> json) {
    return MealsCompanion.insert(
      date: DateTime.parse(json['date'] as String),
      mealType: json['mealType'] as String,
      totalCalories: json['totalCalories'] as double,
      totalProtein: json['totalProtein'] as double,
      totalCarbs: json['totalCarbs'] as double,
      totalFats: json['totalFats'] as double,
      notes: Value(json['notes'] as String?),
      createdAt: Value(DateTime.parse(json['createdAt'] as String)),
    );
  }

  SleepRecordsCompanion _jsonToSleepRecordCompanion(Map<String, dynamic> json) {
    return SleepRecordsCompanion.insert(
      date: DateTime.parse(json['date'] as String),
      plannedBedtime: DateTime.parse(json['plannedBedtime'] as String),
      plannedWakeup: DateTime.parse(json['plannedWakeup'] as String),
      actualBedtime: json['actualBedtime'] != null
          ? Value(DateTime.parse(json['actualBedtime'] as String))
          : const Value.absent(),
      actualWakeup: json['actualWakeup'] != null
          ? Value(DateTime.parse(json['actualWakeup'] as String))
          : const Value.absent(),
      sleepQuality: Value(json['sleepQuality'] as int? ?? 3),
      notes: Value(json['notes'] as String?),
      createdAt: Value(DateTime.parse(json['createdAt'] as String)),
    );
  }

  StudySessionsCompanion _jsonToStudySessionCompanion(Map<String, dynamic> json) {
    return StudySessionsCompanion.insert(
      date: DateTime.parse(json['date'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? Value(DateTime.parse(json['endTime'] as String))
          : const Value.absent(),
      durationMinutes: Value(json['durationMinutes'] as int? ?? 0),
      subject: Value(json['subject'] as String),
      notes: Value(json['notes'] as String?),
      createdAt: Value(DateTime.parse(json['createdAt'] as String)),
    );
  }
}
