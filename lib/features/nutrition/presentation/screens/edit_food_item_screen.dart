import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/food_analysis_result.dart';
import '../../domain/entities/food_item_entity.dart';
import '../providers/nutrition_providers.dart';
import '../widgets/food_source_badge.dart';

class EditFoodItemScreen extends ConsumerStatefulWidget {
  final FoodItemEntity foodItem;

  const EditFoodItemScreen({
    super.key,
    required this.foodItem,
  });

  @override
  ConsumerState<EditFoodItemScreen> createState() =>
      _EditFoodItemScreenState();
}

class _EditFoodItemScreenState extends ConsumerState<EditFoodItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.foodItem.name);
    _quantityController =
        TextEditingController(text: widget.foodItem.quantity.toString());
    _caloriesController =
        TextEditingController(text: widget.foodItem.calories.toString());
    _proteinController =
        TextEditingController(text: widget.foodItem.protein.toString());
    _carbsController =
        TextEditingController(text: widget.foodItem.carbs.toString());
    _fatsController =
        TextEditingController(text: widget.foodItem.fats.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  Future<void> _saveFoodItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final repository = ref.read(nutritionRepositoryProvider);

      final updatedFoodItem = widget.foodItem.copyWith(
        name: _nameController.text.trim(),
        quantity: double.parse(_quantityController.text),
        calories: double.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        carbs: double.parse(_carbsController.text),
        fats: double.parse(_fatsController.text),
        updatedAt: DateTime.now(),
      );

      await repository.updateFoodItem(updatedFoodItem);

      // Recalcular totales de la comida
      await repository.recalculateMealTotals(widget.foodItem.mealId);

      if (mounted) {
        // Invalidar providers relevantes
        ref.invalidate(mealByIdProvider(widget.foodItem.mealId));
        ref.invalidate(todayMealsProvider);
        ref.invalidate(dailyNutritionSummaryProvider);

        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alimento actualizado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteFoodItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar alimento'),
        content:
            const Text('¿Estás seguro de que deseas eliminar este alimento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final repository = ref.read(nutritionRepositoryProvider);
        await repository.deleteFoodItem(widget.foodItem.id);

        // Recalcular totales de la comida
        await repository.recalculateMealTotals(widget.foodItem.mealId);

        if (mounted) {
          // Invalidar providers relevantes
          ref.invalidate(mealByIdProvider(widget.foodItem.mealId));
          ref.invalidate(todayMealsProvider);
          ref.invalidate(dailyNutritionSummaryProvider);

          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alimento eliminado')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Alimento'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteFoodItem,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Badge de source
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FoodSourceBadge(source: _convertToFoodAnalysisSource(widget.foodItem.source)),
                Text(
                  'Registrado: ${_formatDateTime(widget.foodItem.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Formulario editable
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información Nutricional',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nombre
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del alimento *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.restaurant),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Cantidad
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad (g) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.scale),
                      suffixText: 'g',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La cantidad es requerida';
                      }
                      final num = double.tryParse(value);
                      if (num == null || num <= 0) {
                        return 'Ingresa una cantidad válida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Calorías
                  TextFormField(
                    controller: _caloriesController,
                    decoration: const InputDecoration(
                      labelText: 'Calorías *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_fire_department),
                      suffixText: 'kcal',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Las calorías son requeridas';
                      }
                      final num = double.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Ingresa un valor válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Proteína
                  TextFormField(
                    controller: _proteinController,
                    decoration: const InputDecoration(
                      labelText: 'Proteína *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.fitness_center),
                      suffixText: 'g',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La proteína es requerida';
                      }
                      final num = double.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Ingresa un valor válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Carbohidratos
                  TextFormField(
                    controller: _carbsController,
                    decoration: const InputDecoration(
                      labelText: 'Carbohidratos *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.grain),
                      suffixText: 'g',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Los carbohidratos son requeridos';
                      }
                      final num = double.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Ingresa un valor válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Grasas
                  TextFormField(
                    controller: _fatsController,
                    decoration: const InputDecoration(
                      labelText: 'Grasas *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.water_drop),
                      suffixText: 'g',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Las grasas son requeridas';
                      }
                      final num = double.tryParse(value);
                      if (num == null || num < 0) {
                        return 'Ingresa un valor válido';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _saveFoodItem,
                    child: const Text('Guardar Cambios'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  FoodAnalysisSource _convertToFoodAnalysisSource(String source) {
    switch (source.toLowerCase()) {
      case 'cache':
        return FoodAnalysisSource.cache;
      case 'gemini':
      case 'ai':
        return FoodAnalysisSource.gemini;
      case 'local_db':
        return FoodAnalysisSource.localDb;
      case 'manual':
        return FoodAnalysisSource.manual;
      default:
        return FoodAnalysisSource.manual;
    }
  }
}
