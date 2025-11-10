import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/reminder_entity.dart';
import '../providers/reminder_providers.dart';

/// Widget de tarjeta de recordatorio
///
/// Muestra la información de un recordatorio en formato de tarjeta con swipe actions
class ReminderCard extends ConsumerStatefulWidget {
  final ReminderEntity reminder;
  final VoidCallback? onTap;

  const ReminderCard({
    required this.reminder,
    this.onTap,
    super.key,
  });

  @override
  ConsumerState<ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends ConsumerState<ReminderCard> {
  bool _isTogglingCompletion = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = _getPriorityColor(context, widget.reminder.priority);
    final isOverdue =
        widget.reminder.isOverdue && !widget.reminder.isCompleted;

    return Slidable(
      key: ValueKey(widget.reminder.id),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _toggleCompletion(),
            backgroundColor: theme.colorScheme.tertiary,
            foregroundColor: theme.colorScheme.onTertiary,
            icon: widget.reminder.isCompleted ? Icons.undo : Icons.check,
            label: widget.reminder.isCompleted ? 'Deshacer' : 'Completar',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Eliminar Recordatorio'),
                  content: const Text(
                      '¿Estás seguro de que quieres eliminar este recordatorio?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                      ),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                _deleteReminder();
              }
            },
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            icon: Icons.delete,
            label: 'Eliminar',
          ),
        ],
      ),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: isOverdue
            ? theme.colorScheme.errorContainer.withOpacity(0.2)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isOverdue
              ? BorderSide(color: theme.colorScheme.error, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: título y checkbox
                Row(
                  children: [
                    // Checkbox con loading state
                    if (_isTogglingCompletion)
                      const SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else
                      Checkbox(
                        value: widget.reminder.isCompleted,
                        onChanged: (_) => _toggleCompletion(),
                      ),
                    const SizedBox(width: 8),
                    // Título mejorado
                    Expanded(
                      child: Text(
                        widget.reminder.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: widget.reminder.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: widget.reminder.isCompleted
                              ? theme.colorScheme.onSurface.withOpacity(0.5)
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    // Indicador de prioridad más grande
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: priorityColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),

                // Descripción (si existe)
                if (widget.reminder.description != null &&
                    widget.reminder.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 56),
                    child: Text(
                      widget.reminder.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Footer: hora destacada y otros detalles
                Padding(
                  padding: const EdgeInsets.only(left: 56),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hora destacada con background
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat('HH:mm')
                                  .format(widget.reminder.scheduledTime),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Otros detalles
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Recurrencia
                          _buildChip(
                            context,
                            Icons.repeat,
                            widget.reminder.recurrenceType == RecurrenceType.custom
                                ? 'Cada ${widget.reminder.customIntervalDays ?? 1} día${(widget.reminder.customIntervalDays ?? 1) > 1 ? 's' : ''}'
                                : widget.reminder.recurrenceType.displayName,
                          ),
                          // Estado vencido más prominente
                          if (isOverdue)
                            _buildChip(
                              context,
                              Icons.warning_amber,
                              'Vencido',
                              color: theme.colorScheme.error,
                            ),
                          // Tags
                          if (widget.reminder.tags != null)
                            ...widget.reminder.tags!.map((tag) => _buildChip(
                                  context,
                                  Icons.label,
                                  tag,
                                )),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleCompletion() async {
    setState(() {
      _isTogglingCompletion = true;
    });

    try {
      if (widget.reminder.isCompleted) {
        await ref
            .read(markReminderAsNotCompletedProvider)
            .call(widget.reminder.id);
      } else {
        await ref
            .read(markReminderAsCompletedProvider)
            .call(widget.reminder.id);
      }
      // Refrescar la lista
      ref.read(refreshRemindersProvider.notifier).refresh();
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingCompletion = false;
        });
      }
    }
  }

  Future<void> _deleteReminder() async {
    try {
      await ref.read(deleteReminderProvider).call(widget.reminder.id);
      ref.read(refreshRemindersProvider.notifier).refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recordatorio eliminado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildChip(
    BuildContext context,
    IconData icon,
    String label, {
    Color? color,
  }) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.secondary.withOpacity(0.1);
    final textColor = color ?? theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(BuildContext context, Priority priority) {
    final theme = Theme.of(context);
    switch (priority) {
      case Priority.low:
        return theme.colorScheme.tertiary;
      case Priority.medium:
        return theme.colorScheme.secondary;
      case Priority.high:
        return theme.colorScheme.error;
    }
  }
}
