import '../entities/reminder_entity.dart';

/// Repository Interface para Recordatorios
///
/// Define los métodos necesarios para manejar recordatorios
/// siguiendo los principios de Clean Architecture
abstract class ReminderRepository {
  /// Obtiene todos los recordatorios
  Future<List<ReminderEntity>> getAllReminders();

  /// Obtiene un recordatorio por su ID
  Future<ReminderEntity?> getReminderById(int id);

  /// Obtiene los recordatorios activos (no eliminados)
  Future<List<ReminderEntity>> getActiveReminders();

  /// Obtiene los recordatorios pendientes (no completados)
  Future<List<ReminderEntity>> getPendingReminders();

  /// Obtiene los recordatorios completados
  Future<List<ReminderEntity>> getCompletedReminders();

  /// Obtiene los recordatorios por prioridad
  Future<List<ReminderEntity>> getRemindersByPriority(Priority priority);

  /// Obtiene los recordatorios por tag
  Future<List<ReminderEntity>> getRemindersByTag(String tag);

  /// Obtiene los recordatorios de hoy
  Future<List<ReminderEntity>> getTodayReminders();

  /// Crea un nuevo recordatorio
  Future<int> createReminder(ReminderEntity reminder);

  /// Actualiza un recordatorio existente
  Future<bool> updateReminder(ReminderEntity reminder);

  /// Elimina un recordatorio (soft delete)
  Future<bool> deleteReminder(int id);

  /// Marca un recordatorio como completado
  Future<bool> markAsCompleted(int id);

  /// Marca un recordatorio como no completado
  Future<bool> markAsNotCompleted(int id);

  /// Calcula la próxima ocurrencia de un recordatorio
  DateTime calculateNextOccurrence(ReminderEntity reminder);
}
