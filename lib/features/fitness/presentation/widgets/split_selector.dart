import 'package:flutter/material.dart';

import '../../domain/entities/workout_entity.dart';

/// Widget para seleccionar el tipo de split de entrenamiento
class SplitSelector extends StatelessWidget {
  final WorkoutSplit? selectedSplit;
  final ValueChanged<WorkoutSplit> onSplitChanged;

  const SplitSelector({
    super.key,
    this.selectedSplit,
    required this.onSplitChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Entrenamiento',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: WorkoutSplit.values.map((split) {
            final isSelected = selectedSplit == split;
            final color = Color(
              int.parse(split.color.replaceFirst('#', '0xFF')),
            );

            return ChoiceChip(
              label: Text(split.displayName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onSplitChanged(split);
                }
              },
              selectedColor: color.withOpacity(0.3),
              backgroundColor: color.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected ? color : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? color : color.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
