import '../entities/reminder_entity.dart';
import '../repositories/reminder_repository.dart';

/// Use Case: Crear Recordatorio
///
/// Crea un nuevo recordatorio en el sistema
class CreateReminder {
  final ReminderRepository _repository;

  CreateReminder(this._repository);

  /// Ejecuta el caso de uso
  ///
  /// Returns: ID del recordatorio creado
  Future<int> call(ReminderEntity reminder) async {
    // Calcular la próxima ocurrencia
    final nextOccurrence = _repository.calculateNextOccurrence(reminder);

    // Crear el recordatorio con la próxima ocurrencia calculada
    final reminderWithNextOccurrence = reminder.copyWith(
      nextOccurrence: nextOccurrence,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await _repository.createReminder(reminderWithNextOccurrence);
  }
}
