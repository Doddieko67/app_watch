import 'package:flutter/material.dart';

import '../../domain/entities/reminder_entity.dart';

/// Widget para seleccionar la prioridad de un recordatorio
class PrioritySelector extends StatelessWidget {
  final Priority selectedPriority;
  final ValueChanged<Priority> onPriorityChanged;

  const PrioritySelector({
    required this.selectedPriority,
    required this.onPriorityChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prioridad',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: Priority.values.map((priority) {
            final isSelected = priority == selectedPriority;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _PriorityOption(
                  priority: priority,
                  isSelected: isSelected,
                  onTap: () => onPriorityChanged(priority),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PriorityOption extends StatelessWidget {
  final Priority priority;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriorityOption({
    required this.priority,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getPriorityColor(context, priority);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              _getPriorityIcon(priority),
              color: color,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              priority.displayName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? color : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
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

  IconData _getPriorityIcon(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Icons.flag_outlined;
      case Priority.medium:
        return Icons.flag;
      case Priority.high:
        return Icons.priority_high;
    }
  }
}
