import 'package:flutter/material.dart';

import '../../domain/entities/reminder_entity.dart';

/// Widget para seleccionar la recurrencia de un recordatorio
class RecurrencePicker extends StatelessWidget {
  final RecurrenceType selectedRecurrenceType;
  final List<int>? selectedDays;
  final ValueChanged<RecurrenceType> onRecurrenceTypeChanged;
  final ValueChanged<List<int>>? onDaysChanged;

  const RecurrencePicker({
    required this.selectedRecurrenceType,
    this.selectedDays,
    required this.onRecurrenceTypeChanged,
    this.onDaysChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recurrencia',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        // Selector de tipo de recurrencia
        SegmentedButton<RecurrenceType>(
          segments: [
            ButtonSegment(
              value: RecurrenceType.daily,
              label: Text(RecurrenceType.daily.displayName),
              icon: const Icon(Icons.today),
            ),
            ButtonSegment(
              value: RecurrenceType.weekly,
              label: Text(RecurrenceType.weekly.displayName),
              icon: const Icon(Icons.calendar_view_week),
            ),
            ButtonSegment(
              value: RecurrenceType.custom,
              label: Text(RecurrenceType.custom.displayName),
              icon: const Icon(Icons.event),
            ),
          ],
          selected: {selectedRecurrenceType},
          onSelectionChanged: (Set<RecurrenceType> newSelection) {
            onRecurrenceTypeChanged(newSelection.first);
          },
        ),
        // Selector de días (solo para weekly)
        if (selectedRecurrenceType == RecurrenceType.weekly) ...[
          const SizedBox(height: 16),
          Text(
            'Días de la semana',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          _WeekdaySelector(
            selectedDays: selectedDays ?? [],
            onDaysChanged: onDaysChanged,
          ),
        ],
      ],
    );
  }
}

class _WeekdaySelector extends StatelessWidget {
  final List<int> selectedDays;
  final ValueChanged<List<int>>? onDaysChanged;

  const _WeekdaySelector({
    required this.selectedDays,
    this.onDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        final weekday = index + 1; // 1=Lunes, 7=Domingo
        final isSelected = selectedDays.contains(weekday);
        final dayName = _getWeekdayName(weekday);

        return FilterChip(
          label: Text(dayName),
          selected: isSelected,
          onSelected: (selected) {
            if (onDaysChanged != null) {
              final newDays = [...selectedDays];
              if (selected) {
                newDays.add(weekday);
              } else {
                newDays.remove(weekday);
              }
              newDays.sort();
              onDaysChanged!(newDays);
            }
          },
          selectedColor: theme.colorScheme.primary.withOpacity(0.2),
          checkmarkColor: theme.colorScheme.primary,
        );
      }),
    );
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Lun';
      case 2:
        return 'Mar';
      case 3:
        return 'Mié';
      case 4:
        return 'Jue';
      case 5:
        return 'Vie';
      case 6:
        return 'Sáb';
      case 7:
        return 'Dom';
      default:
        return '';
    }
  }
}
