import '../repositories/reminder_repository.dart';

/// Use Case: Marcar Recordatorio como Completado
class MarkReminderAsCompleted {
  final ReminderRepository _repository;

  MarkReminderAsCompleted(this._repository);

  /// Ejecuta el caso de uso
  ///
  /// Returns: true si se marcó correctamente
  Future<bool> call(int reminderId) async {
    return await _repository.markAsCompleted(reminderId);
  }
}

/// Use Case: Marcar Recordatorio como No Completado
class MarkReminderAsNotCompleted {
  final ReminderRepository _repository;

  MarkReminderAsNotCompleted(this._repository);

  /// Ejecuta el caso de uso
  ///
  /// Returns: true si se marcó correctamente
  Future<bool> call(int reminderId) async {
    return await _repository.markAsNotCompleted(reminderId);
  }
}
