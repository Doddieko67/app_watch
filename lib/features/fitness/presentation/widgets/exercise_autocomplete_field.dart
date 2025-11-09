import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../providers/fitness_providers.dart';

/// Widget de autocompletar para nombres de ejercicios
/// Muestra ejercicios guardados y permite seleccionar para pre-llenar valores
class ExerciseAutocompleteField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final Function(SavedExerciseData?)? onExerciseSelected;

  const ExerciseAutocompleteField({
    super.key,
    required this.controller,
    this.onExerciseSelected,
  });

  @override
  ConsumerState<ExerciseAutocompleteField> createState() =>
      _ExerciseAutocompleteFieldState();
}

class _ExerciseAutocompleteFieldState
    extends ConsumerState<ExerciseAutocompleteField> {
  @override
  Widget build(BuildContext context) {
    final savedExercisesAsync = ref.watch(savedExercisesProvider);

    return savedExercisesAsync.when(
      data: (exercises) {
        return Autocomplete<SavedExerciseData>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<SavedExerciseData>.empty();
            }
            return exercises.where((SavedExerciseData exercise) {
              return exercise.name
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            }).cast<SavedExerciseData>();
          },
          displayStringForOption: (SavedExerciseData option) => option.name,
          onSelected: (SavedExerciseData selection) {
            widget.controller.text = selection.name;
            widget.onExerciseSelected?.call(selection);
          },
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController fieldTextEditingController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted,
          ) {
            // Sincronizar con el controller externo
            fieldTextEditingController.text = widget.controller.text;
            fieldTextEditingController.addListener(() {
              widget.controller.text = fieldTextEditingController.text;
            });

            return TextField(
              controller: fieldTextEditingController,
              focusNode: fieldFocusNode,
              decoration: const InputDecoration(
                labelText: 'Nombre del Ejercicio',
                hintText: 'Ej: Bench Press',
                prefixIcon: Icon(Icons.fitness_center),
                helperText: 'Escribe para ver ejercicios guardados',
              ),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (String value) {
                onFieldSubmitted();
              },
            );
          },
          optionsViewBuilder: (
            BuildContext context,
            AutocompleteOnSelected<SavedExerciseData> onSelected,
            Iterable<SavedExerciseData> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: options.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      final SavedExerciseData option = options.elementAt(index);
                      return ListTile(
                        leading: const Icon(Icons.fitness_center, size: 20),
                        title: Text(option.name),
                        subtitle: Text(
                          '${option.lastSets}×${option.lastReps} @ ${option.lastWeight}kg',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: Text(
                          '${option.usageCount}x',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        onTap: () {
                          onSelected(option);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => TextField(
        controller: widget.controller,
        decoration: const InputDecoration(
          labelText: 'Nombre del Ejercicio',
          hintText: 'Ej: Bench Press',
          prefixIcon: Icon(Icons.fitness_center),
          helperText: 'Cargando ejercicios...',
        ),
        textCapitalization: TextCapitalization.words,
      ),
      error: (error, stack) => TextField(
        controller: widget.controller,
        decoration: const InputDecoration(
          labelText: 'Nombre del Ejercicio',
          hintText: 'Ej: Bench Press',
          prefixIcon: Icon(Icons.fitness_center),
        ),
        textCapitalization: TextCapitalization.words,
      ),
    );
  }
}
