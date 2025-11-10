import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../providers/fitness_providers.dart';

/// Widget de autocompletado para seleccionar workouts guardados
class WorkoutAutocompleteField extends ConsumerWidget {
  final TextEditingController controller;
  final Function(SavedWorkoutData) onWorkoutSelected;
  final String? hintText;

  const WorkoutAutocompleteField({
    super.key,
    required this.controller,
    required this.onWorkoutSelected,
    this.hintText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedWorkoutsAsync = ref.watch(savedWorkoutsProvider);

    return savedWorkoutsAsync.when(
      data: (savedWorkouts) {
        return Autocomplete<SavedWorkoutData>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              // Mostrar los últimos 5 workouts usados
              return savedWorkouts.take(5);
            }

            // Filtrar por nombre
            return savedWorkouts.where((workout) {
              return workout.name
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          displayStringForOption: (SavedWorkoutData option) => option.name,
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            // Sincronizar con el controller externo
            textEditingController.text = controller.text;
            textEditingController.selection = controller.selection;

            textEditingController.addListener(() {
              controller.text = textEditingController.text;
              controller.selection = textEditingController.selection;
            });

            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Nombre del Workout',
                hintText: hintText ?? 'Ej: Push Day, Full Body',
                prefixIcon: const Icon(Icons.fitness_center),
                suffixIcon: textEditingController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          textEditingController.clear();
                          controller.clear();
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (value) => onFieldSubmitted(),
            );
          },
          optionsViewBuilder: (
            BuildContext context,
            AutocompleteOnSelected<SavedWorkoutData> onSelected,
            Iterable<SavedWorkoutData> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 200,
                    maxWidth: 400,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final SavedWorkoutData option =
                          options.elementAt(index);
                      return ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(option.name),
                        subtitle: Text(
                          'Usado ${option.usageCount} veces',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onTap: () {
                          onSelected(option);
                          onWorkoutSelected(option);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
          onSelected: (SavedWorkoutData selection) {
            controller.text = selection.name;
            onWorkoutSelected(selection);
          },
        );
      },
      loading: () => TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Nombre del Workout',
          hintText: hintText ?? 'Ej: Push Day, Full Body',
          prefixIcon: const Icon(Icons.fitness_center),
          border: const OutlineInputBorder(),
          suffixIcon: const SizedBox(
            width: 20,
            height: 20,
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        enabled: false,
      ),
      error: (error, stack) => TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Nombre del Workout',
          hintText: hintText ?? 'Ej: Push Day, Full Body',
          prefixIcon: const Icon(Icons.fitness_center),
          border: const OutlineInputBorder(),
        ),
        textCapitalization: TextCapitalization.words,
      ),
    );
  }
}
