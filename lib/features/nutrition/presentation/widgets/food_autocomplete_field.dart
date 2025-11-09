import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/food_item_entity.dart';
import '../providers/nutrition_providers.dart';

/// Widget de autocompletar para nombres de alimentos
/// Muestra alimentos recientes/frecuentes y permite seleccionar para pre-llenar valores
class FoodAutocompleteField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final Function(FoodItemEntity?)? onFoodSelected;

  const FoodAutocompleteField({
    super.key,
    required this.controller,
    this.onFoodSelected,
  });

  @override
  ConsumerState<FoodAutocompleteField> createState() =>
      _FoodAutocompleteFieldState();
}

class _FoodAutocompleteFieldState extends ConsumerState<FoodAutocompleteField> {
  @override
  Widget build(BuildContext context) {
    final recentFoodsAsync = ref.watch(recentFoodsProvider);

    return recentFoodsAsync.when(
      data: (foods) {
        return Autocomplete<FoodItemEntity>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<FoodItemEntity>.empty();
            }
            return foods.where((food) {
              return food.name
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          displayStringForOption: (FoodItemEntity option) => option.name,
          onSelected: (FoodItemEntity selection) {
            widget.controller.text = selection.name;
            widget.onFoodSelected?.call(selection);
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
                labelText: 'Nombre del Alimento',
                hintText: 'Ej: Pechuga de pollo',
                prefixIcon: Icon(Icons.restaurant),
                helperText: 'Escribe para ver alimentos recientes',
              ),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (String value) {
                onFieldSubmitted();
              },
            );
          },
          optionsViewBuilder: (
            BuildContext context,
            AutocompleteOnSelected<FoodItemEntity> onSelected,
            Iterable<FoodItemEntity> options,
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
                      final FoodItemEntity option = options.elementAt(index);
                      return ListTile(
                        leading: const Icon(Icons.restaurant, size: 20),
                        title: Text(option.name),
                        subtitle: Text(
                          '${option.quantity} ${option.unit} • ${option.calories.toStringAsFixed(0)} kcal',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: Text(
                          'P:${option.protein.toStringAsFixed(0)}g',
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
          labelText: 'Nombre del Alimento',
          hintText: 'Ej: Pechuga de pollo',
          prefixIcon: Icon(Icons.restaurant),
          helperText: 'Cargando alimentos...',
        ),
        textCapitalization: TextCapitalization.words,
      ),
      error: (error, stack) => TextField(
        controller: widget.controller,
        decoration: const InputDecoration(
          labelText: 'Nombre del Alimento',
          hintText: 'Ej: Pechuga de pollo',
          prefixIcon: Icon(Icons.restaurant),
        ),
        textCapitalization: TextCapitalization.words,
      ),
    );
  }
}
