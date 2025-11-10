import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/meal_entity.dart';
import '../providers/nutrition_providers.dart';
import 'add_food_item_screen.dart';
import 'edit_food_item_screen.dart';
import 'edit_meal_screen.dart';

class MealDetailScreen extends ConsumerWidget {
  final int mealId;

  const MealDetailScreen({
    super.key,
    required this.mealId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealAsync = ref.watch(mealByIdProvider(mealId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Comida'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditMeal(context, ref, mealAsync.value),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteMeal(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddFood(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Agregar Alimento'),
      ),
      body: mealAsync.when(
        data: (meal) {
          if (meal == null) {
            return const Center(
              child: Text('Comida no encontrada'),
            );
          }
          return _buildMealDetail(context, meal, ref);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Future<void> _navigateToAddFood(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddFoodItemScreen(mealId: mealId),
      ),
    );

    // Si se guardó el alimento, refrescar el provider
    if (result == true) {
      ref.invalidate(mealByIdProvider(mealId));
    }
  }

  Future<void> _navigateToEditMeal(BuildContext context, WidgetRef ref, MealEntity? meal) async {
    if (meal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: comida no encontrada')),
      );
      return;
    }

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => EditMealScreen(meal: meal),
      ),
    );

    // Si se guardó la edición, refrescar el provider
    if (result == true) {
      ref.invalidate(mealByIdProvider(mealId));
    }
  }

  Future<void> _navigateToEditFoodItem(
    BuildContext context,
    WidgetRef ref,
    dynamic foodItem,
  ) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => EditFoodItemScreen(foodItem: foodItem),
      ),
    );

    // Si se guardó la edición, refrescar el provider
    if (result == true) {
      ref.invalidate(mealByIdProvider(mealId));
    }
  }

  Widget _buildMealDetail(BuildContext context, MealEntity meal, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getMealTypeColor(meal.mealType).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getMealTypeIcon(meal.mealType),
                        color: _getMealTypeColor(meal.mealType),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getMealTypeName(meal.mealType),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd/MM/yyyy HH:mm').format(meal.date),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (meal.notes != null && meal.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Notas:',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meal.notes!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Nutritional Summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen Nutricional',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutrientCard(
                      context,
                      'Calorías',
                      meal.totalCalories.toStringAsFixed(0),
                      'kcal',
                      Colors.orange,
                      Icons.local_fire_department,
                    ),
                    _buildNutrientCard(
                      context,
                      'Proteína',
                      meal.totalProtein.toStringAsFixed(1),
                      'g',
                      Colors.red,
                      Icons.fitness_center,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNutrientCard(
                      context,
                      'Carbos',
                      meal.totalCarbs.toStringAsFixed(1),
                      'g',
                      Colors.blue,
                      Icons.grain,
                    ),
                    _buildNutrientCard(
                      context,
                      'Grasas',
                      meal.totalFats.toStringAsFixed(1),
                      'g',
                      Colors.amber,
                      Icons.water_drop,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Food Items
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Alimentos (${meal.foodItems.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...meal.foodItems.map((foodItem) => _buildFoodItemCard(context, ref, foodItem)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientCard(
    BuildContext context,
    String label,
    String value,
    String unit,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              unit,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodItemNutrient(BuildContext context, String text, Color color) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildFoodItemCard(BuildContext context, WidgetRef ref, dynamic foodItem) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToEditFoodItem(context, ref, foodItem),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      foodItem.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${foodItem.quantity.toStringAsFixed(0)}${foodItem.unit}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.edit,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFoodItemNutrient(
                    context,
                    '${foodItem.calories.toStringAsFixed(0)} kcal',
                    Colors.orange,
                  ),
                  _buildFoodItemNutrient(
                    context,
                    'P: ${foodItem.protein.toStringAsFixed(1)}g',
                    Colors.red,
                  ),
                  _buildFoodItemNutrient(
                    context,
                    'C: ${foodItem.carbs.toStringAsFixed(1)}g',
                    Colors.blue,
                  ),
                  _buildFoodItemNutrient(
                    context,
                    'G: ${foodItem.fats.toStringAsFixed(1)}g',
                    Colors.amber,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.blue;
      case 'snack':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getMealTypeIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  String _getMealTypeName(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'Desayuno';
      case 'lunch':
        return 'Almuerzo';
      case 'dinner':
        return 'Cena';
      case 'snack':
        return 'Snack';
      default:
        return mealType;
    }
  }

  Future<void> _deleteMeal(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Comida'),
        content: const Text('¿Estás seguro de que deseas eliminar esta comida?'),
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

    if (confirm == true && context.mounted) {
      try {
        final deleteMeal = ref.read(deleteMealProvider);
        await deleteMeal(mealId);

        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Comida eliminada')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }
}
