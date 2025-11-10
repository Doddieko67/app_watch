import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/reminder_entity.dart';
import '../providers/reminder_providers.dart';
import '../widgets/priority_selector.dart';
import '../widgets/recurrence_picker.dart';

/// Pantalla de detalle de recordatorio
///
/// Permite crear o editar un recordatorio
class ReminderDetailScreen extends ConsumerStatefulWidget {
  final ReminderEntity? reminder;

  const ReminderDetailScreen({
    this.reminder,
    super.key,
  });

  @override
  ConsumerState<ReminderDetailScreen> createState() =>
      _ReminderDetailScreenState();
}

class _ReminderDetailScreenState extends ConsumerState<ReminderDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();

  late DateTime _selectedTime;
  DateTime? _selectedStartDate; // Fecha de inicio de recurrencia
  late Priority _selectedPriority;
  late RecurrenceType _selectedRecurrenceType;
  List<int> _selectedDays = [];
  int _customIntervalDays = 2; // Valor por defecto para custom
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.reminder != null) {
      // Modo edición
      final reminder = widget.reminder!;
      _titleController.text = reminder.title;
      _descriptionController.text = reminder.description ?? '';
      _tagsController.text = reminder.tags?.join(', ') ?? '';
      _selectedTime = reminder.scheduledTime;
      _selectedStartDate = reminder.startDate;
      _selectedPriority = reminder.priority;
      _selectedRecurrenceType = reminder.recurrenceType;
      _selectedDays = reminder.recurrenceDays ?? [];
      _customIntervalDays = reminder.customIntervalDays ?? 2;
    } else {
      // Modo creación
      _selectedTime = DateTime.now().add(const Duration(hours: 1));
      _selectedStartDate = null; // Por defecto, inicia hoy
      _selectedPriority = Priority.medium;
      _selectedRecurrenceType = RecurrenceType.daily;
      _selectedDays = [];
      _customIntervalDays = 2;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.reminder != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Recordatorio' : 'Nuevo Recordatorio'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteReminder,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                hintText: 'Ej: Tomar vitaminas',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un título';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Descripción
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Detalles adicionales...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Selector de hora
            _buildTimeSelector(theme),
            const SizedBox(height: 24),

            // Selector de prioridad
            PrioritySelector(
              selectedPriority: _selectedPriority,
              onPriorityChanged: (priority) {
                setState(() {
                  _selectedPriority = priority;
                });
              },
            ),
            const SizedBox(height: 24),

            // Selector de recurrencia
            RecurrencePicker(
              selectedRecurrenceType: _selectedRecurrenceType,
              selectedDays: _selectedDays,
              onRecurrenceTypeChanged: (type) {
                setState(() {
                  _selectedRecurrenceType = type;
                  if (type != RecurrenceType.weekly) {
                    _selectedDays = [];
                  }
                });
              },
              onDaysChanged: (days) {
                setState(() {
                  _selectedDays = days;
                });
              },
            ),

            // Si es custom, mostrar selector de intervalo
            if (_selectedRecurrenceType == RecurrenceType.custom) ...[
              const SizedBox(height: 16),
              _buildCustomIntervalSelector(theme),
            ],

            const SizedBox(height: 24),

            // Selector de fecha de inicio de recurrencia
            _buildStartDateSelector(theme),
            const SizedBox(height: 24),

            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (opcional)',
                hintText: 'salud, vitaminas, etc.',
                helperText: 'Separa los tags con comas',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: 32),

            // Botón de guardar
            FilledButton(
              onPressed: _isLoading ? null : _saveReminder,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Guardar Cambios' : 'Crear Recordatorio'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hora',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectTime,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Text(
                  DateFormat('HH:mm').format(_selectedTime),
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomIntervalSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repetir cada',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _customIntervalDays.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                label: '$_customIntervalDays día${_customIntervalDays > 1 ? 's' : ''}',
                onChanged: (value) {
                  setState(() {
                    _customIntervalDays = value.round();
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_customIntervalDays día${_customIntervalDays > 1 ? 's' : ''}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _customIntervalDays == 1
              ? 'Se repetirá cada día (igual que "Diario")'
              : 'Se repetirá cada $_customIntervalDays días',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildStartDateSelector(ThemeData theme) {
    final displayDate = _selectedStartDate ?? DateTime.now();
    final isToday = _selectedStartDate == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha de Inicio',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectStartDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isToday ? 'Hoy' : DateFormat('EEEE, d MMM y', 'es').format(displayDate),
                        style: theme.textTheme.titleMedium,
                      ),
                      if (!isToday)
                        Text(
                          'La recurrencia comenzará en esta fecha',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isToday
              ? 'La recurrencia comenzará hoy'
              : 'El primer recordatorio será el ${DateFormat('d MMM', 'es').format(displayDate)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedTime.year,
          _selectedTime.month,
          _selectedTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es'),
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
        );
      });
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Parsear tags
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      // Validar días seleccionados para recurrencia semanal
      if (_selectedRecurrenceType == RecurrenceType.weekly &&
          _selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecciona al menos un día de la semana'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final reminder = ReminderEntity(
        id: widget.reminder?.id ?? 0,
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        recurrenceType: _selectedRecurrenceType,
        recurrenceDays:
            _selectedRecurrenceType == RecurrenceType.weekly
                ? _selectedDays
                : null,
        customIntervalDays:
            _selectedRecurrenceType == RecurrenceType.custom
                ? _customIntervalDays
                : null,
        startDate: _selectedStartDate,
        scheduledTime: _selectedTime,
        nextOccurrence: _selectedTime,
        priority: _selectedPriority,
        isCompleted: widget.reminder?.isCompleted ?? false,
        isActive: true,
        tags: tags.isEmpty ? null : tags,
        createdAt: widget.reminder?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.reminder == null) {
        // Crear nuevo
        await ref.read(createReminderProvider).call(reminder);
      } else {
        // Actualizar existente
        await ref.read(updateReminderProvider).call(reminder);
      }

      if (mounted) {
        // Calcular próxima notificación para mostrar al usuario
        final nextNotification = reminder.nextOccurrence;
        final now = DateTime.now();
        final difference = nextNotification.difference(now);

        String timeUntilNotification;
        if (difference.inDays > 0) {
          timeUntilNotification = 'En ${difference.inDays} día${difference.inDays > 1 ? 's' : ''} a las ${DateFormat('HH:mm').format(nextNotification)}';
        } else if (difference.inHours > 0) {
          timeUntilNotification = 'En ${difference.inHours}h ${difference.inMinutes % 60}min';
        } else if (difference.inMinutes > 0) {
          timeUntilNotification = 'En ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
        } else {
          timeUntilNotification = DateFormat('EEEE d MMM, HH:mm').format(nextNotification);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.reminder == null
                  ? '✓ Recordatorio creado\nPróxima notificación: $timeUntilNotification'
                  : '✓ Recordatorio actualizado\nPróxima notificación: $timeUntilNotification',
            ),
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getHumanReadableError(e)),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteReminder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Recordatorio'),
        content:
            const Text('¿Estás seguro de que quieres eliminar este recordatorio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.reminder != null) {
      try {
        await ref.read(deleteReminderProvider).call(widget.reminder!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recordatorio eliminado')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  String _getHumanReadableError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('database') || errorString.contains('sql')) {
      return 'No se pudo guardar el recordatorio. Inténtalo de nuevo.';
    }
    if (errorString.contains('notification')) {
      return 'Recordatorio guardado, pero las notificaciones están deshabilitadas. Revisa la configuración.';
    }
    if (errorString.contains('permission')) {
      return 'No tienes permisos para crear notificaciones. Habilítalos en Configuración.';
    }

    return 'Algo salió mal. Por favor, inténtalo de nuevo.';
  }
}
