import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder_entity.freezed.dart';

/// Entity de Recordatorio
///
/// Representa un recordatorio en el dominio de la aplicación
@freezed
class ReminderEntity with _$ReminderEntity {
  const factory ReminderEntity({
    required int id,
    required String title,
    String? description,
    required RecurrenceType recurrenceType,
    List<int>? recurrenceDays, // Para recurrencia semanal: 1=Lunes, 7=Domingo
    required DateTime scheduledTime,
    required DateTime nextOccurrence,
    required Priority priority,
    required bool isCompleted,
    required bool isActive,
    List<String>? tags,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
    int? notificationId,
  }) = _ReminderEntity;

  const ReminderEntity._();

  /// Verifica si el recordatorio está vencido
  bool get isOverdue {
    if (isCompleted) return false;
    return DateTime.now().isAfter(nextOccurrence);
  }

  /// Verifica si el recordatorio es de hoy
  bool get isToday {
    final now = DateTime.now();
    final occurrence = nextOccurrence;
    return occurrence.year == now.year &&
        occurrence.month == now.month &&
        occurrence.day == now.day;
  }

  /// Obtiene el color asociado a la prioridad
  String get priorityColor {
    switch (priority) {
      case Priority.low:
        return '#4CAF50'; // Verde
      case Priority.medium:
        return '#FF9800'; // Naranja
      case Priority.high:
        return '#F44336'; // Rojo
    }
  }
}

/// Enum de Tipo de Recurrencia
enum RecurrenceType {
  daily,
  weekly,
  custom;

  String get displayName {
    switch (this) {
      case RecurrenceType.daily:
        return 'Diario';
      case RecurrenceType.weekly:
        return 'Semanal';
      case RecurrenceType.custom:
        return 'Personalizado';
    }
  }
}

/// Enum de Prioridad
enum Priority {
  low,
  medium,
  high;

  int get value {
    switch (this) {
      case Priority.low:
        return 1;
      case Priority.medium:
        return 2;
      case Priority.high:
        return 3;
    }
  }

  static Priority fromValue(int value) {
    switch (value) {
      case 1:
        return Priority.low;
      case 2:
        return Priority.medium;
      case 3:
        return Priority.high;
      default:
        return Priority.medium;
    }
  }

  String get displayName {
    switch (this) {
      case Priority.low:
        return 'Baja';
      case Priority.medium:
        return 'Media';
      case Priority.high:
        return 'Alta';
    }
  }
}
