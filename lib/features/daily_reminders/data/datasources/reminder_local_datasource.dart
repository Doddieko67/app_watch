import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/reminder_entity.dart';
import '../models/reminder_mapper.dart';

/// Local Data Source para Recordatorios
///
/// Maneja las operaciones de base de datos para recordatorios
class ReminderLocalDataSource {
  final AppDatabase _database;

  ReminderLocalDataSource(this._database);

  /// Obtiene todos los recordatorios
  Future<List<ReminderEntity>> getAllReminders() async {
    final reminders = await _database.getAllReminders();
    return reminders.map((r) => ReminderMapper.toEntity(r)).toList();
  }

  /// Obtiene un recordatorio por su ID
  Future<ReminderEntity?> getReminderById(int id) async {
    final reminder = await _database.getReminderById(id);
    return reminder != null ? ReminderMapper.toEntity(reminder) : null;
  }

  /// Obtiene los recordatorios activos (no eliminados)
  Future<List<ReminderEntity>> getActiveReminders() async {
    final query = _database.select(_database.reminders)
      ..where((r) => (r.deletedAt.isNull()) & (r.isActive.equals(true)))
      ..orderBy([
        (r) => OrderingTerm.desc(r.priority),
        (r) => OrderingTerm.asc(r.nextOccurrence),
      ]);

    final reminders = await query.get();
    return reminders.map((r) => ReminderMapper.toEntity(r)).toList();
  }

  /// Obtiene los recordatorios pendientes (no completados)
  Future<List<ReminderEntity>> getPendingReminders() async {
    final query = _database.select(_database.reminders)
      ..where((r) =>
          (r.deletedAt.isNull()) &
          (r.isActive.equals(true)) &
          (r.isCompleted.equals(false)))
      ..orderBy([
        (r) => OrderingTerm.asc(r.nextOccurrence),
      ]);

    final reminders = await query.get();
    return reminders.map((r) => ReminderMapper.toEntity(r)).toList();
  }

  /// Obtiene los recordatorios completados
  Future<List<ReminderEntity>> getCompletedReminders() async {
    final query = _database.select(_database.reminders)
      ..where((r) =>
          (r.deletedAt.isNull()) &
          (r.isActive.equals(true)) &
          (r.isCompleted.equals(true)))
      ..orderBy([
        (r) => OrderingTerm.desc(r.updatedAt),
      ]);

    final reminders = await query.get();
    return reminders.map((r) => ReminderMapper.toEntity(r)).toList();
  }

  /// Obtiene los recordatorios por prioridad
  Future<List<ReminderEntity>> getRemindersByPriority(Priority priority) async {
    final query = _database.select(_database.reminders)
      ..where((r) =>
          (r.deletedAt.isNull()) &
          (r.isActive.equals(true)) &
          (r.priority.equals(priority.value)))
      ..orderBy([
        (r) => OrderingTerm.asc(r.nextOccurrence),
      ]);

    final reminders = await query.get();
    return reminders.map((r) => ReminderMapper.toEntity(r)).toList();
  }

  /// Obtiene los recordatorios por tag
  Future<List<ReminderEntity>> getRemindersByTag(String tag) async {
    final query = _database.select(_database.reminders)
      ..where((r) =>
          (r.deletedAt.isNull()) &
          (r.isActive.equals(true)) &
          (r.tags.contains('"$tag"')))
      ..orderBy([
        (r) => OrderingTerm.asc(r.nextOccurrence),
      ]);

    final reminders = await query.get();
    return reminders.map((r) => ReminderMapper.toEntity(r)).toList();
  }

  /// Obtiene los recordatorios de hoy
  Future<List<ReminderEntity>> getTodayReminders() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = _database.select(_database.reminders)
      ..where((r) =>
          (r.deletedAt.isNull()) &
          (r.isActive.equals(true)) &
          (r.nextOccurrence.isBiggerOrEqualValue(startOfDay)) &
          (r.nextOccurrence.isSmallerThanValue(endOfDay)))
      ..orderBy([
        (r) => OrderingTerm.asc(r.nextOccurrence),
      ]);

    final reminders = await query.get();
    return reminders.map((r) => ReminderMapper.toEntity(r)).toList();
  }

  /// Crea un nuevo recordatorio
  Future<int> createReminder(ReminderEntity reminder) async {
    final companion = ReminderMapper.toCompanionForInsert(reminder);
    return await _database.insertReminder(companion);
  }

  /// Actualiza un recordatorio existente
  Future<bool> updateReminder(ReminderEntity reminder) async {
    final driftReminder = Reminder(
      id: reminder.id,
      title: reminder.title,
      description: reminder.description,
      recurrenceType: _recurrenceTypeToString(reminder.recurrenceType),
      recurrenceDays: reminder.recurrenceDays != null
          ? _encodeIntList(reminder.recurrenceDays!)
          : null,
      scheduledTime: reminder.scheduledTime,
      nextOccurrence: reminder.nextOccurrence,
      priority: reminder.priority.value,
      isCompleted: reminder.isCompleted,
      isActive: reminder.isActive,
      tags: reminder.tags != null ? _encodeStringList(reminder.tags!) : null,
      createdAt: reminder.createdAt,
      updatedAt: reminder.updatedAt,
      deletedAt: reminder.deletedAt,
      syncStatus: 0,
      notificationId: reminder.notificationId,
    );

    return await _database.updateReminder(driftReminder);
  }

  /// Elimina un recordatorio (soft delete)
  Future<bool> deleteReminder(int id) async {
    final reminder = await _database.getReminderById(id);
    if (reminder == null) return false;

    final now = DateTime.now();
    final updated = reminder.copyWith(
      deletedAt: Value(now), // nullable field uses Value
      updatedAt: now,
    );

    return await _database.updateReminder(updated);
  }

  /// Marca un recordatorio como completado
  Future<bool> markAsCompleted(int id) async {
    final reminder = await _database.getReminderById(id);
    if (reminder == null) return false;

    final updated = reminder.copyWith(
      isCompleted: true,
      updatedAt: DateTime.now(),
    );

    return await _database.updateReminder(updated);
  }

  /// Marca un recordatorio como no completado
  Future<bool> markAsNotCompleted(int id) async {
    final reminder = await _database.getReminderById(id);
    if (reminder == null) return false;

    final updated = reminder.copyWith(
      isCompleted: false,
      updatedAt: DateTime.now(),
    );

    return await _database.updateReminder(updated);
  }

  // Helpers privados

  String _recurrenceTypeToString(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return 'daily';
      case RecurrenceType.weekly:
        return 'weekly';
      case RecurrenceType.custom:
        return 'custom';
    }
  }

  String _encodeIntList(List<int> list) {
    return '[${list.join(',')}]';
  }

  String _encodeStringList(List<String> list) {
    return '["${list.join('","')}"]';
  }
}
