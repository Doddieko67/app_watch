import '../entities/reminder_entity.dart';
import '../repositories/reminder_repository.dart';

/// Use Case: Actualizar Recordatorio
///
/// Actualiza un recordatorio existente
class UpdateReminder {
  final ReminderRepository _repository;

  UpdateReminder(this._repository);

  /// Ejecuta el caso de uso
  ///
  /// Returns: true si se actualizó correctamente
  Future<bool> call(ReminderEntity reminder) async {
    // Recalcular la próxima ocurrencia si cambió el horario o recurrencia
    final nextOccurrence = _repository.calculateNextOccurrence(reminder);

    // Actualizar el recordatorio con la próxima ocurrencia calculada
    final reminderWithUpdates = reminder.copyWith(
      nextOccurrence: nextOccurrence,
      updatedAt: DateTime.now(),
    );

    return await _repository.updateReminder(reminderWithUpdates);
  }
}
