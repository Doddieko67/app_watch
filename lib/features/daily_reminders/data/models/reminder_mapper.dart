import 'dart:convert';

import 'package:drift/drift.dart' as drift;

import '../../../../core/database/app_database.dart';
import '../../domain/entities/reminder_entity.dart';

/// Mapper para convertir entre Reminder (Drift) y ReminderEntity (Domain)
class ReminderMapper {
  /// Convierte de Reminder (Drift) a ReminderEntity (Domain)
  static ReminderEntity toEntity(Reminder reminder) {
    return ReminderEntity(
      id: reminder.id,
      title: reminder.title,
      description: reminder.description,
      recurrenceType: _stringToRecurrenceType(reminder.recurrenceType),
      recurrenceDays: reminder.recurrenceDays != null
          ? List<int>.from(jsonDecode(reminder.recurrenceDays!))
          : null,
      customIntervalDays: reminder.customIntervalDays,
      startDate: reminder.startDate,
      scheduledTime: reminder.scheduledTime,
      nextOccurrence: reminder.nextOccurrence,
      priority: Priority.fromValue(reminder.priority),
      isCompleted: reminder.isCompleted,
      isActive: reminder.isActive,
      tags: reminder.tags != null
          ? List<String>.from(jsonDecode(reminder.tags!))
          : null,
      createdAt: reminder.createdAt,
      updatedAt: reminder.updatedAt,
      deletedAt: reminder.deletedAt,
      notificationId: reminder.notificationId,
    );
  }

  /// Convierte de ReminderEntity (Domain) a RemindersCompanion (Drift)
  static RemindersCompanion toCompanion(ReminderEntity entity) {
    return RemindersCompanion(
      id: drift.Value(entity.id),
      title: drift.Value(entity.title),
      description: entity.description != null
          ? drift.Value(entity.description!)
          : const drift.Value.absent(),
      recurrenceType: drift.Value(_recurrenceTypeToString(entity.recurrenceType)),
      recurrenceDays: entity.recurrenceDays != null
          ? drift.Value(jsonEncode(entity.recurrenceDays))
          : const drift.Value.absent(),
      customIntervalDays: entity.customIntervalDays != null
          ? drift.Value(entity.customIntervalDays!)
          : const drift.Value.absent(),
      startDate: entity.startDate != null
          ? drift.Value(entity.startDate!)
          : const drift.Value.absent(),
      scheduledTime: drift.Value(entity.scheduledTime),
      nextOccurrence: drift.Value(entity.nextOccurrence),
      priority: drift.Value(entity.priority.value),
      isCompleted: drift.Value(entity.isCompleted),
      isActive: drift.Value(entity.isActive),
      tags: entity.tags != null
          ? drift.Value(jsonEncode(entity.tags))
          : const drift.Value.absent(),
      createdAt: drift.Value(entity.createdAt),
      updatedAt: drift.Value(entity.updatedAt),
      deletedAt: entity.deletedAt != null
          ? drift.Value(entity.deletedAt!)
          : const drift.Value.absent(),
      notificationId: entity.notificationId != null
          ? drift.Value(entity.notificationId!)
          : const drift.Value.absent(),
    );
  }

  /// Convierte de ReminderEntity (Domain) a RemindersCompanion para inserción
  static RemindersCompanion toCompanionForInsert(ReminderEntity entity) {
    return RemindersCompanion.insert(
      title: entity.title,
      description: entity.description != null
          ? drift.Value(entity.description!)
          : const drift.Value.absent(),
      recurrenceType: _recurrenceTypeToString(entity.recurrenceType),
      recurrenceDays: entity.recurrenceDays != null
          ? drift.Value(jsonEncode(entity.recurrenceDays))
          : const drift.Value.absent(),
      customIntervalDays: entity.customIntervalDays != null
          ? drift.Value(entity.customIntervalDays!)
          : const drift.Value.absent(),
      startDate: entity.startDate != null
          ? drift.Value(entity.startDate!)
          : const drift.Value.absent(),
      scheduledTime: entity.scheduledTime,
      nextOccurrence: entity.nextOccurrence,
      priority: drift.Value(entity.priority.value),
      isCompleted: drift.Value(entity.isCompleted),
      isActive: drift.Value(entity.isActive),
      tags: entity.tags != null
          ? drift.Value(jsonEncode(entity.tags))
          : const drift.Value.absent(),
      createdAt: drift.Value(entity.createdAt),
      updatedAt: drift.Value(entity.updatedAt),
      deletedAt: entity.deletedAt != null
          ? drift.Value(entity.deletedAt!)
          : const drift.Value.absent(),
      notificationId: entity.notificationId != null
          ? drift.Value(entity.notificationId!)
          : const drift.Value.absent(),
    );
  }

  // Helpers privados

  static RecurrenceType _stringToRecurrenceType(String value) {
    switch (value) {
      case 'daily':
        return RecurrenceType.daily;
      case 'weekly':
        return RecurrenceType.weekly;
      case 'custom':
        return RecurrenceType.custom;
      default:
        return RecurrenceType.daily;
    }
  }

  static String _recurrenceTypeToString(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return 'daily';
      case RecurrenceType.weekly:
        return 'weekly';
      case RecurrenceType.custom:
        return 'custom';
    }
  }
}
