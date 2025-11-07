import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/reminder_entity.dart';
import '../providers/reminder_providers.dart';

/// Widget de tarjeta de recordatorio
///
/// Muestra la información de un recordatorio en formato de tarjeta
class ReminderCard extends ConsumerWidget {
  final ReminderEntity reminder;
  final VoidCallback? onTap;

  const ReminderCard({
    required this.reminder,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final priorityColor = _getPriorityColor(reminder.priority);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: título y checkbox
              Row(
                children: [
                  // Checkbox
                  Checkbox(
                    value: reminder.isCompleted,
                    onChanged: (value) async {
                      if (value == true) {
                        await ref
                            .read(markReminderAsCompletedProvider)
                            .call(reminder.id);
                      } else {
                        await ref
                            .read(markReminderAsNotCompletedProvider)
                            .call(reminder.id);
                      }
                      // Refrescar la lista
                      ref.read(refreshRemindersProvider.notifier).refresh();
                    },
                  ),
                  const SizedBox(width: 8),
                  // Título
                  Expanded(
                    child: Text(
                      reminder.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: reminder.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: reminder.isCompleted
                            ? theme.colorScheme.onSurface.withOpacity(0.5)
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  // Indicador de prioridad
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              // Descripción (si existe)
              if (reminder.description != null &&
                  reminder.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 56),
                  child: Text(
                    reminder.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Footer: hora, recurrencia y tags
              Padding(
                padding: const EdgeInsets.only(left: 56),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Hora
                    _buildChip(
                      context,
                      Icons.access_time,
                      DateFormat('HH:mm').format(reminder.scheduledTime),
                    ),
                    // Recurrencia
                    _buildChip(
                      context,
                      Icons.repeat,
                      reminder.recurrenceType.displayName,
                    ),
                    // Estado vencido
                    if (reminder.isOverdue && !reminder.isCompleted)
                      _buildChip(
                        context,
                        Icons.warning,
                        'Vencido',
                        color: theme.colorScheme.error,
                      ),
                    // Tags
                    if (reminder.tags != null)
                      ...reminder.tags!.map((tag) => _buildChip(
                            context,
                            Icons.label,
                            tag,
                          )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
    }
  }
}
