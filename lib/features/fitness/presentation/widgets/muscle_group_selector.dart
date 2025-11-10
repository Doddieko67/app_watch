import 'package:flutter/material.dart';

import '../../domain/entities/workout_entity.dart';

/// Widget para seleccionar múltiples grupos musculares
class MuscleGroupSelector extends StatelessWidget {
  final List<MuscleGroup> selectedGroups;
  final ValueChanged<List<MuscleGroup>> onChanged;

  const MuscleGroupSelector({
    super.key,
    required this.selectedGroups,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.fitness_center,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Grupos Musculares',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MuscleGroup.values.map((group) {
                final isSelected = selectedGroups.contains(group);
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(group.emoji),
                      const SizedBox(width: 4),
                      Text(group.displayName),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newGroups = List<MuscleGroup>.from(selectedGroups);
                    if (selected) {
                      newGroups.add(group);
                    } else {
                      newGroups.remove(group);
                    }
                    onChanged(newGroups);
                  },
                  selectedColor: theme.colorScheme.primaryContainer,
                  checkmarkColor: theme.colorScheme.onPrimaryContainer,
                );
              }).toList(),
            ),
            if (selectedGroups.isEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Selecciona al menos un grupo muscular',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
