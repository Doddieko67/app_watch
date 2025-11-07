import '../repositories/reminder_repository.dart';

/// Use Case: Eliminar Recordatorio
///
/// Elimina un recordatorio (soft delete)
class DeleteReminder {
  final ReminderRepository _repository;

  DeleteReminder(this._repository);

  /// Ejecuta el caso de uso
  ///
  /// Returns: true si se eliminó correctamente
  Future<bool> call(int reminderId) async {
    return await _repository.deleteReminder(reminderId);
  }
}
