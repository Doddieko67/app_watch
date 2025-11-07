import '../entities/reminder_entity.dart';
import '../repositories/reminder_repository.dart';

/// Use Case: Obtener Todos los Recordatorios
class GetAllReminders {
  final ReminderRepository _repository;

  GetAllReminders(this._repository);

  Future<List<ReminderEntity>> call() async {
    return await _repository.getAllReminders();
  }
}

/// Use Case: Obtener Recordatorios Activos
class GetActiveReminders {
  final ReminderRepository _repository;

  GetActiveReminders(this._repository);

  Future<List<ReminderEntity>> call() async {
    return await _repository.getActiveReminders();
  }
}

/// Use Case: Obtener Recordatorios Pendientes
class GetPendingReminders {
  final ReminderRepository _repository;

  GetPendingReminders(this._repository);

  Future<List<ReminderEntity>> call() async {
    return await _repository.getPendingReminders();
  }
}

/// Use Case: Obtener Recordatorios Completados
class GetCompletedReminders {
  final ReminderRepository _repository;

  GetCompletedReminders(this._repository);

  Future<List<ReminderEntity>> call() async {
    return await _repository.getCompletedReminders();
  }
}

/// Use Case: Obtener Recordatorios de Hoy
class GetTodayReminders {
  final ReminderRepository _repository;

  GetTodayReminders(this._repository);

  Future<List<ReminderEntity>> call() async {
    return await _repository.getTodayReminders();
  }
}

/// Use Case: Obtener Recordatorios por Prioridad
class GetRemindersByPriority {
  final ReminderRepository _repository;

  GetRemindersByPriority(this._repository);

  Future<List<ReminderEntity>> call(Priority priority) async {
    return await _repository.getRemindersByPriority(priority);
  }
}

/// Use Case: Obtener Recordatorios por Tag
class GetRemindersByTag {
  final ReminderRepository _repository;

  GetRemindersByTag(this._repository);

  Future<List<ReminderEntity>> call(String tag) async {
    return await _repository.getRemindersByTag(tag);
  }
}
